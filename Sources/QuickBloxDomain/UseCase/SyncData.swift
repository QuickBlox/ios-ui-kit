//
//  SyncData.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import UIKit
import QuickBloxLog

public enum SyncState: Equatable {
    /// Sync process stages
    public enum Stage: String {
        /// The authorization to the remote source could not be completed.
        case unauthorized
        /// The connection to the remote source could not be completed.
        case disconnected
        /// Connecting to a remote source occurs automatically if you have previously authorized.
        case connecting
        /// Obtaining basic information about dialogues, followed by its replacement in the local
        /// source.
        case update
        /// Obtaining additional information such as participants, avatars, etc., followed by its
        /// replacement in the local source.
        case details
    }
    
    case syncing(stage: Stage, error: RepositoryException? = nil)
    case synced
}

/// This is a use case that describes the rules for synchronizing data between remote and local sources that are related to user dialogs.
///
/// During execution, the use case responds to establishing connection and receiving  ``RemoteDialogEvent`` (s) from the server by updating data in the local storage.
public class SyncData<DialogsRepo: DialogsRepositoryProtocol,
                      UsersRepo: UsersRepositoryProtocol,
                      MessagesRepo: MessagesRepositoryProtocol,
                      ConnectRepo: ConnectionRepositoryProtocol,
                      Pagination: PaginationProtocol>
where Pagination == DialogsRepo.PaginationItem,
      Pagination == UsersRepo.PaginationItem {
    private let dialogsRepo: DialogsRepo
    private let usersRepo: UsersRepo
    private let messagesRepo: MessagesRepo
    private let connectRepo: ConnectRepo
    
    public init(dialogsRepo: DialogsRepo,
                usersRepo: UsersRepo,
                messagesRepo: MessagesRepo,
                connectRepo: ConnectRepo) {
        self.dialogsRepo = dialogsRepo
        self.usersRepo = usersRepo
        self.messagesRepo = messagesRepo
        self.connectRepo = connectRepo
    }
    
    //FIXME: make a private
    let stateSubject =
    CurrentValueSubject<SyncState, Never>(.syncing(stage: .disconnected))
    
    private let eventsQueue = DispatchQueue(label: "sync.data.events.queue")
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var taskConnect: Task<Void, Never>?
    private var taskDisconnect: Task<Void, Never>?
    private var taskUpdate: Task<Void, Never>?
    private var taskEvents: Task<Void, Never>?
    
    /// Starts the process of synchronizing dialogs and related data between the remote and local sources.
    ///
    /// The sync process is divided into the following  stages:
    ///
    /// | Stage | Description |
    /// --- | ---
    /// `disconnected` | The authorization or connection to the remote source could not be completed.
    /// `connecting` | Connecting to a remote source occurs automatically if you have previously logged in.
    /// `update` | Obtaining basic information about dialogues, followed by its replacement in the local source.
    /// `details` | Obtaining additional information such as participants, avatars, etc., followed by its replacement in the local source.
    ///
    /// - Returns: a publisher that transmits a sequence of values representing the sync ``State``
    /// in real-time.
    public func execute() -> AnyPublisher<SyncState, Never> {
        processConnectionStates()
        
        processRemoteEvents()
        
        processAppStates()
        
        connect()
        
        return stateSubject.eraseToAnyPublisher()
    }
    
    deinit {
        taskConnect?.cancel()
        taskConnect = nil
        
        taskDisconnect?.cancel()
        taskDisconnect = nil
        
        taskUpdate?.cancel()
        taskUpdate = nil
        
        taskEvents?.cancel()
        taskEvents = nil
    }
    
    //MARK: Connection
    private func processConnectionStates() {
        let sub =
        connectRepo.statePublisher
            .receive(on: eventsQueue)
            .sink { [weak self] state in
                switch state {
                case .unauthorized:
                    prettyLog(state)
                    // cancel all active tasks
                    self?.taskUpdate?.cancel()
                    self?.taskConnect?.cancel()
                    self?.taskDisconnect?.cancel()
                    
                    Task { [weak self] in do {
                        try await self?.dialogsRepo.cleareAll()
                    } catch { prettyLog(error) } }
                    
                    self?.stateSubject.send(.syncing(stage: .unauthorized))
                case .authorized:
                    DispatchQueue.main.async {
                        if UIApplication.shared.applicationState == .background {
                            return
                        }
                        
                        self?.eventsQueue.async { [weak self] in
                            self?.taskDisconnect?.cancel()
                            self?.connect()
                        }
                    }
                case .disconnected(let error):
                    self?.taskUpdate?.cancel()
                    self?.stateSubject.send(.syncing(stage: .disconnected,
                                                     error: error))
                    Task { [weak self] in do {
                        try await self?.dialogsRepo.cleareAll()
                    } catch { prettyLog(error) } }
                case .connecting(let error):
                    self?.stateSubject.send(.syncing(stage: .connecting,
                                                     error: error))
                case .connected:
                    self?.stateSubject.send(.syncing(stage: .update))
                    self?.taskUpdate = Task { [weak self] in
                        await self?.updateInfo()
                        self?.taskUpdate = nil
                    }
                }
            }
        eventsQueue.async { [weak self] in
            self?.cancellables.insert(sub)
        }
    }
    
    //MARK: Sync Info
    private func processAppStates() {
        let subBackground =
        NotificationCenter.default
            .publisher(for: UIScene.didEnterBackgroundNotification)
            .receive(on: eventsQueue)
            .sink { [weak self] _ in
                self?.taskConnect?.cancel()
                self?.disconnect()
            }
        eventsQueue.async { [weak self] in
            self?.cancellables.insert(subBackground)
        }
        
        let subForeground =
        NotificationCenter.default
            .publisher(for: UIScene.willEnterForegroundNotification)
            .receive(on: eventsQueue)
            .sink { [weak self] _ in
                self?.taskDisconnect?.cancel()
                self?.connect()
            }
        eventsQueue.async { [weak self] in
            self?.cancellables.insert(subForeground)
        }
    }
    
    private func connect() {
        taskConnect = Task { [weak self] in
            do {
               let state = try await self?.connectRepo.checkConnection()
                
                if state == .disconnected() {
                    try Task.checkCancellation()
                    try await self?.connectRepo.connect()
                }
            } catch { prettyLog(error) }
            
            self?.taskConnect = nil
        }
    }
    
    private func disconnect() {
        taskDisconnect = Task { [weak self] in
            do {
                if self?.stateSubject.value == .syncing(stage: .unauthorized) ||
                    self?.stateSubject.value == .syncing(stage: .disconnected) {
                    return
                }
                try await self?.connectRepo.disconnect()
            } catch { prettyLog(error) }
            
            self?.taskDisconnect = nil
        }
    }
    
    //MARK: Sync Info
    private func updateInfo() async {
        do {
            var page = dialogsRepo.initialPagination
            var syncIds: Set<String> = []
            repeat {
                try Task.checkCancellation()
                let result = try await dialogsRepo.getDialogsFromRemote(for: page)
                try Task.checkCancellation()
                let usersIds = Set(result.usersIds)
                syncIds.formUnion(usersIds)
                for dialog in result.dialogs {
                    try Task.checkCancellation()
                    if dialog.type == .public {
                        continue
                    }
                    try await dialogsRepo.save(dialogToLocal: dialog)
    
                    let duration = UInt64(0.01 * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                }
                
                page = result.page
                page.next()
            } while page.hasNext
            
            try await sync(participants: Array(syncIds))
            
            stateSubject.send(.synced)
        } catch let exeption as RepositoryException {
            stateSubject.send(.syncing(stage: .update, error: exeption))
            prettyLog(exeption)
        } catch {
            let info = error.localizedDescription
            let exeption = RepositoryException.unexpected(info)
            stateSubject.send(.syncing(stage: .update, error: exeption))
            prettyLog(error)
        }
    }
    
    private func processRemoteEvents() {
        taskEvents = Task {  [weak self] in
            guard let eventsQueue = self?.eventsQueue else { return }
            let sub = await self?.dialogsRepo.remoteEventPublisher
                .receive(on: eventsQueue)
                .sink { event in
                    switch event {
                    case .create(let id, let isCurrent, let message):
                        Task { [weak self] in do {
                            if isCurrent {
                                try await self?.create(dialog: message)
                            } else {
                                try await self?.sync(dialog: id, newMessage: message)
                            }
                        } catch {
                            prettyLog(error)
                        } }
                    case .update(let message):
                        Task { [weak self] in do {
                            try await self?.sync(dialog: message.dialogId, newMessage: message)
                        } catch {
                            prettyLog(error)
                        } }
                    case .leave(let dialogId):
                        Task { [weak self] in do {
                            try await self?.dialogsRepo.delete(dialogFromLocal: dialogId)
                        } catch {
                            prettyLog(error)
                        } }
                    case .userLeave(let message):
                        Task { [weak self] in do {
                            guard let self = self else { return }
                            var dialog = try await self.dialogsRepo.get(dialogFromLocal: message.dialogId)
                            if dialog.type == .private {
                                try await self.dialogsRepo.delete(dialogFromLocal: message.dialogId)
                            } else {
                                dialog.participantsIds.removeAll(where: { $0 == message.userId })
                                try await self.dialogsRepo.update(dialogInLocal: dialog)
                                try await self.update(dialog: message)
                            }
                        } catch {
                            prettyLog(error)
                        } }
                    case .removed(let dialogId):
                        Task { [weak self] in do {
                            try await self?.dialogsRepo.delete(dialogFromLocal: dialogId)
                        } catch {
                            prettyLog(error)
                        } }
                    case .newMessage(let message):
                        Task { [weak self] in do {
                            try await self?.update(dialog: message)
                        } catch {
                            prettyLog(error)
                        } }
                    case .read(let messageID, let dialogID):
                        Task { [weak self] in do {
                            try await self?.update(byRead: messageID, dialogID: dialogID)
                        } catch {
                            prettyLog(error)
                        } }
                    case .delivered(let messageID, let dialogID):
                        Task { [weak self] in do {
                            try await self?.update(byDelivered: messageID, dialogID: dialogID)
                        } catch {
                            prettyLog(error)
                        } }
                    case .typing(let userID, let dialogID):
                        print("typing user: \(userID) in dialog: \(dialogID)")
                    case .stopTyping(let userID, let dialogID):
                        print("stopTyping user: \(userID) in dialog: \(dialogID)")
                    }
                }
            
            guard let sub = sub else {
                return
            }
            self?.eventsQueue.async { [weak self] in
                self?.cancellables.insert(sub)
            }
        }
    }
    
    typealias DialogItem = DialogsRepo.DialogEntityItem
    typealias MessageItem = DialogItem.MessageItem
    
    func create(dialog newMessage: MessageItem) async throws {
        if let dialog = try? await dialogsRepo.get(dialogFromLocal: newMessage.dialogId),
           dialog.isOwnedByCurrentUser == true,
           newMessage.isOwnedByCurrentUser != dialog.isOwnedByCurrentUser {
            return
        }
        var dialog = try await dialogsRepo.get(dialogFromRemote: newMessage.dialogId)
        if dialog.type != .private {
            dialog = update(dialog, lastMessage: newMessage)
        }
        try await dialogsRepo.save(dialogToLocal: dialog)
    }
    
    func update(dialog newMessage: MessageItem) async throws {
        guard var dialog = try? await dialogsRepo.get(dialogFromLocal: newMessage.dialogId) else {
            try await sync(dialog: newMessage.dialogId, newMessage: newMessage)
            return
        }
        
        dialog = update(dialog, lastMessage: newMessage)
        
        try await dialogsRepo.update(dialogInLocal: dialog)
    }
    
    private func update(_ dialog: DialogItem, lastMessage: MessageItem) -> DialogItem {
        var dialog = dialog
        
        if lastMessage.type == .system {
            return dialog
        }
        
        if dialog.lastMessage.id != lastMessage.id,
           lastMessage.isOwnedByCurrentUser == false {
            dialog.unreadMessagesCount += 1
        }
        
        dialog.lastMessage.id = lastMessage.id
        dialog.lastMessage.text = lastMessage.text
        dialog.lastMessage.dateSent = lastMessage.date
        dialog.lastMessage.userId = lastMessage.userId
        dialog.updatedAt = lastMessage.date
        dialog.messages = [lastMessage]
        
        return dialog
    }
    
    func update(byRead messageID: String, dialogID: String) async throws {
        var dialog = try await dialogsRepo.get(dialogFromLocal: dialogID)
        guard let index = dialog.messages.firstIndex(where: { $0.id == messageID }) else {
            return
        }
        if dialog.messages[index].isRead == true {
            return
        }
        dialog.messages[index].isRead = true
        
        try await dialogsRepo.update(dialogInLocal: dialog)
    }
    
    func update(byDelivered messageID: String, dialogID: String) async throws {
        var dialog = try await dialogsRepo.get(dialogFromLocal: dialogID)
        
        guard let index = dialog.messages.firstIndex(where: { $0.id == messageID }) else {
            return
        }
        if dialog.messages[index].isDelivered == true {
            return
        }
        dialog.messages[index].isDelivered = true
        try await dialogsRepo.update(dialogInLocal: dialog)
    }
    
    func sync(dialog dialogId: String, newMessage: MessageItem) async throws {
        var dialog = try await dialogsRepo.get(dialogFromRemote: dialogId)
        try await sync(participants: dialog.participantsIds)
        
        if dialog.type != .private {
            dialog = update(dialog, lastMessage: newMessage)
        }
        
        let saved = try? await dialogsRepo.get(dialogFromLocal: dialogId)
        if saved == nil {
            try await dialogsRepo.save(dialogToLocal: dialog)
        } else {
            try await dialogsRepo.update(dialogInLocal: dialog)
        }
    }
    
    func sync(participants ids: [String]) async throws {
        if ids.isEmpty { return }
        var page = usersRepo.initialPagination
        repeat {
            try Task.checkCancellation()
            
            let result = try await usersRepo.get(usersFromRemote: ids,
                                                 pagination: page)
            if result.users.isEmpty == false {
                try? await usersRepo.save(usersToLocal: result.users)
            }
            
            page = result.pagination
            page.next()
        } while page.hasNext
    }
}
