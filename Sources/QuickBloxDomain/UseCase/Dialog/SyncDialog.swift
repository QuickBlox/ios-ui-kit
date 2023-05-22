//
//  SyncDialog.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Foundation

public class SyncDialog<Dialog: DialogEntity,
                        DialogsRepo: DialogsRepositoryProtocol,
                        UsersRepo: UsersRepositoryProtocol,
                        MessageRepo: MessagesRepositoryProtocol,
                        Pagination: PaginationProtocol>
where Dialog == DialogsRepo.DialogEntityItem,
        Pagination == MessageRepo.PaginationItem,
        Pagination == DialogsRepo.PaginationItem {
    private let dialogId: String
    private let dialogsRepo: DialogsRepo
    private let usersRepo: UsersRepo
    private let messageRepo: MessageRepo
    
    private let subject = PassthroughSubject<Dialog, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private var taskSyncMessages: Task<Void, Never>?
    private var taskSyncUsers: Task<Void, Never>?
    private var taskUpdate: Task<Void, Never>?
    
    public init(dialogId: String,
                dialogsRepo: DialogsRepo,
                usersRepo: UsersRepo,
                messageRepo: MessageRepo) {
        self.dialogId = dialogId
        self.dialogsRepo = dialogsRepo
        self.usersRepo = usersRepo
        self.messageRepo = messageRepo
    }
    
    deinit {
        taskSyncMessages = nil
        taskSyncUsers = nil
        taskUpdate = nil
    }
    
    public func execute() -> AnyPublisher<Dialog, Never> {
        processDialog()
        syncMessages()
        syncUsers()
        
        return subject.eraseToAnyPublisher()
    }
    
    private func syncUsers() {
        taskSyncUsers = Task {
            do {
                let dialog = try await dialogsRepo.get(dialogFromRemote: dialogId)
                let ids = dialog.participantsIds
                if let users = try? await usersRepo.get(usersFromRemote: ids),
                   users.isEmpty != false {
                    try? await usersRepo.save(usersToLocal: users)
                }
                let saved = try? await dialogsRepo.get(dialogFromLocal: dialogId)
                if saved != nil {
                    try await dialogsRepo.update(dialogInLocal: dialog)
                } else {
                    try await dialogsRepo.save(dialogToLocal: dialog)
                }
                taskSyncUsers = nil
            } catch { prettyLog(error) } }
    }
    
    private func syncMessages() {
        taskSyncMessages = Task {
            do {
                var page = Pagination(skip: 100, limit: 100, total: 0)
                repeat {
                    page = try await syncMessages(with: page)
                } while page.hasNextPage
                _ = try await syncMessages(with: Pagination(skip: 0, limit: 100, total: 0))
            } catch { prettyLog(error) }
            taskSyncMessages = nil
        }
    }
    
    private func syncMessages(with page: Pagination) async throws -> Pagination {
        try Task.checkCancellation()
        let result = try await messageRepo.get(messagesFromRemote: dialogId,
                                               messagesIds: [],
                                               page: page)
        for message in result.messages {
            try Task.checkCancellation()
            try await messageRepo.save(messageToLocal: message)
        }
        
        var next = result.page
        next.skip += result.messages.count
        next.hasNextPage = result.messages.count == page.limit
        return result.page
    }
    
    private func processDialog() {
        taskUpdate = Task {
            await dialogsRepo.localDialogsPublisher
                .compactMap { $0.first(where: { $0.id == self.dialogId }) }
                .sink { dialog in self.subject.send(dialog) }
                .store(in: &cancellables)
        }
    }
}
