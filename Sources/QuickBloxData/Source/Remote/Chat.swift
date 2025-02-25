//
//  Chat.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import Combine
import QuickBloxDomain
import QuickBloxLog

private actor Chat {
    private let subject = PassthroughSubject<RemoteEvent, Never>()
    var eventPublisher: AnyPublisher<RemoteEvent, Never> {
        subject.eraseToAnyPublisher()
    }
    
    private let dialog: QBChatDialog
    
    var type: DialogType {
        return dialog.type.dialogType
    }
    
    var qbChat: QBChatDialog {
        return dialog
    }
    
    init(_ dialog: QBChatDialog) {
        self.dialog = dialog
    }
    
    func subscribe() async {
        await join(qbChat)
    }
    
    private func join(_ dialog: QBChatDialog) async {
        guard let id = dialog.id, dialog.type == .group else { return }
        do {
            try await dialog.joinAsync()
            try Task.checkCancellation()
        } catch {
            prettyLog(label: "Join to \(id)", error)
        }
    }
    
    func subscribeTyping() async {
        await subscribeTyping(qbChat)
    }
    
    func subscribeTyping(_ dialog: QBChatDialog) async {
        dialog.onUserIsTyping = { [weak self] userId in
            guard let self = self else { return }
            guard let dialogID = dialog.id else { return }
            if userId == QBSession.current.currentUserID { return }
            self.subject.send(RemoteEvent.typing(userId, dialogID: dialogID))
        }
        
        dialog.onUserStoppedTyping = { [weak self] userId in
            guard let self = self else { return }
            guard let dialogID = dialog.id else { return }
            if userId == QBSession.current.currentUserID { return }
            self.subject.send(RemoteEvent.stopTyping(userId, dialogID: dialogID))
        }
    }
    
    func sendTyping() {
        dialog.sendUserIsTyping()
    }
    
    func sendStopTyping() {
        dialog.sendUserStoppedTyping()
    }
    
    func send(_ message: QBChatMessage) async {
        guard let id = dialog.id, id == message.dialogID else { return }
        
        do {
            if dialog.type != .private {
                if dialog.isJoined() == false {
                    await join(dialog)
                    try Task.checkCancellation()
                }
                message.dateSent = Date()
                try await dialog.sendAsync(message)
                try Task.checkCancellation()
            } else {
                message.dateSent = Date()
                try await dialog.sendAsync(message)
                try Task.checkCancellation()
            }
        } catch {
            prettyLog(label: "Send to \(id)", error)
            return
        }
    }
    
    func unsubscribe() async {
        await leave()
        await unsubscribeTyping()
    }
    
    private func leave() async {
        guard let id = dialog.id, dialog.type == .group else { return }
        guard dialog.isJoined() else { return }
        do {
            try await dialog.leaveAsync()
        } catch {
            prettyLog(label: "Leave from \(id)", error)
        }
    }
    
    private func unsubscribeTyping() async {
        dialog.clearTypingStatusBlocks()
    }
}

private extension QBChatDialog {
    func joinAsync() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            if type == .private || type == .publicGroup || isJoined() == true {
                continuation.resume()
            } else {
                join { error in
                    if let error = error, error._code == -1006 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            continuation.resume()
                        }
                    } else if let error {
                        continuation.resume(throwing:error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    func leaveAsync() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            if type == .private || isJoined() == false {
                continuation.resume()
                return
            }
            
            leave { error in
                if let error = error, error._code == -1001 {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing:error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func sendAsync(_ message: QBChatMessage) async throws {
            return try await withCheckedThrowingContinuation{
                continuation in
                send(message) { (error) in
                    if let error = error {
                        prettyLog(error)
                        continuation.resume(throwing:error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
}

actor ChatStream: NSObject, QBChatDelegate {
    private let subject = PassthroughSubject<RemoteEvent, Never>()
    var eventPublisher: AnyPublisher<RemoteEvent, Never> {
        subject.eraseToAnyPublisher()
    }
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    private var chats: [String: Chat] = [:]
    
    override init() {
        super.init()
        
        QBChat.instance.addDelegate(self)
    }
    
    func typeOf(chat chatId: String) async throws -> DialogType {
        guard let chat = chats[chatId] else {
            let info = "Chat with id \(chatId) is absent"
            throw DataSourceException.notFound(description: info)
        }
        return await chat.type
    }
    
    func qbChat(with id: String) async throws -> QBChatDialog {
        guard let chat = chats[id] else {
            let info = "Chat with id \(id) is absent"
            throw DataSourceException.notFound(description: info)
        }
        return await chat.qbChat
    }
    
    func update(with dialog: QBChatDialog) async {
        guard let id = dialog.id else { return }
        let new = Chat(dialog)
        chats[id] = new
        await subscribeEvents(new)
    }
    
    func remove(chat id: String) async {
        guard let chat = chats[id] else { return }
        await chat.unsubscribe()
        chats.removeValue(forKey: id)
    }
    
    func send(_ message: QBChatMessage) async {
        guard let id = message.dialogID, let chat = chats[id] else { return }
        await chat.send(message)
    }
    
    func read(_ message: QBChatMessage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            QBChat.instance.read(message) { error in
                if let error = error {
                    continuation.resume(throwing:error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func delivered(_ message: QBChatMessage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            QBChat.instance.mark(asDelivered: message) { error in
                if let error = error {
                    continuation.resume(throwing:error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func subscribe(chat id: String) async {
        guard let chat = chats[id] else { return }
        await chat.subscribe()
    }
    
    func subscribeToTyping(chat id: String) async {
        guard let chat = chats[id] else { return }
        await chat.subscribeTyping()
    }
    
    func sendTyping(chat id: String) async {
        guard let chat = chats[id] else { return }
        await chat.sendTyping()
    }
    
    func sendStopTyping(chat id: String) async {
        guard let chat = chats[id] else { return }
        await chat.sendStopTyping()
    }
    
    func process(_ message: QBChatMessage) async {
        let dto = RemoteMessageDTO(message)
        let event = RemoteEvent(dto)
        subject.send(event)
    }
    
    func processSystem(_ message: QBChatMessage) async {
        var dto = RemoteMessageDTO(message)
        dto.type = .system
        let event = RemoteEvent(dto)
        subject.send(event)
    }
    
    func process(_ event: RemoteEvent) async {
        subject.send(event)
    }
    
    func clear() async {
        for id in chats.keys {
            if let chat = chats[id] {
                //TODO: Use Task Group
                await chat.unsubscribe()
            }
        }
        chats.removeAll()
    }
    
    private func subscribeEvents(_ chat: Chat) async {
        await chat.eventPublisher
            .sink(receiveValue: { event in
                self.subject.send(event)
            })
            .store(in: &cancellables)
    }
}

extension ChatStream: QBChatReceiveMessageProtocol {
    nonisolated private var currentUserId: UInt {
        return QBSession.current.currentUserID
    }
    
    nonisolated func chatDidReceive(_ message: QBChatMessage) {
        if message.senderID == currentUserId { return }
        Task { [weak self] in
            await self?.process(message)
        }
    }
    
    nonisolated func chatRoomDidReceive(_ message: QBChatMessage,
                            fromDialogID dialogID: String) {
        message.dialogID = dialogID
        
        if message.senderID == currentUserId {
            if message.type == .leave {
                Task { [weak self] in
                    await self?.remove(chat:dialogID)
                    await self?.process(message)
                }
            }
            return
        }
        
        if message.type == .removed {
            Task { [weak self] in
                await self?.remove(chat:dialogID)
                await self?.process(message)
            }
        } else {
            Task { [weak self] in
                await self?.process(message)
            }
        }
    }
    
    nonisolated func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        if message.senderID == currentUserId { return }
        Task { [weak self] in
            if message.type == .removed {
                var dialogId = message.dialogID ?? ""
                if dialogId.isEmpty, 
                    let params = message.customParameters as? [String: String],
                    let id = params[QBChatMessage.Key.dialogId] {
                    dialogId = id
                }
                await self?.remove(chat:dialogId)
            }
            await self?.processSystem(message)
        }
    }
    
    nonisolated func chatDidReadMessage(withID messageID: String,
                                        dialogID: String,
                                        readerID: UInt) {
        if readerID == QBSession.current.currentUserID { return }
        var dto = RemoteMessageDTO()
        dto.dialogId = dialogID
        dto.id = messageID
        dto.readIds.append(String(readerID))
        dto.type = .event
        dto.eventType = .read
        let event = RemoteEvent(dto)
        subject.send(event)
    }
    
    nonisolated func chatDidDeliverMessage(withID messageID: String, 
                                           dialogID: String,
                                           toUserID userID: UInt) {
        if userID == QBSession.current.currentUserID { return }
        
        var dto = RemoteMessageDTO()
        dto.dialogId = dialogID
        dto.id = messageID
        dto.deliveredIds.append(String(userID))
        dto.type = .event
        dto.eventType = .delivered
        let event = RemoteEvent(dto)
        subject.send(event)
    }
}
