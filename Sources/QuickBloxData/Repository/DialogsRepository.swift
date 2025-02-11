//
//  DialogsRepository.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Combine

/// This is a class that implements the ``DialogsRepositoryProtocol`` protocol and contains methods and properties that allow it to interact with the ``DialogEntity`` items.
///
/// An object of this class provides access for remote and local storages of ``DialogEntity`` items at the time of the application's life cycle.
public class DialogsRepository {
    private let remote: RemoteDataSourceProtocol
    private let local:  LocalDataSourceProtocol
    
    public init(remote: RemoteDataSourceProtocol,
                local: LocalDataSourceProtocol) {
        self.remote = remote
        self.local = local
    }
}

extension DialogsRepository: DialogsRepositoryProtocol {
    public var remoteEventPublisher: AnyPublisher<RemoteDialogEvent<Message>, Never> {
        get async {
            await remote.eventPublisher
                .compactMap { event in
                    switch event {
                    case .create(let dialogId, let isCurrent, let message): return .create(dialogId, byUser: isCurrent, message: Message(message))
                    case .update(let message): return .update(Message(message))
                    case .leave( let dialogId):
                        return .leave(dialogId)
                    case .userLeave(let message):
                        return .userLeave(Message(message))
                    case .removed(let dialogId):
                        return .removed(dialogId)
                    case .newMessage(let message):
                        return .newMessage(Message(message))
                    case .read(let messageID, let dialogID):
                        return .read(messageID, dialogID: dialogID)
                    case .delivered(let messageID, let dialogID):
                        return .delivered(messageID, dialogID: dialogID)
                    case .typing(let userID,let dialogID):
                        return .typing(userID, dialogID: dialogID)
                    case .stopTyping(let userID,let dialogID):
                        return .stopTyping(userID, dialogID: dialogID)
                    }
                }
                .eraseToAnyPublisher()
        }
    }
    
    public var localDialogsPublisher: AnyPublisher<[Dialog], Never> {
        get async {
            await local.dialogsPublisher
                .map{ info in
                    info.map { Dialog($0) }
                }
                .eraseToAnyPublisher()
        }
    }
    
    public var localDialogUpdatePublisher: AnyPublisher<String, Never> {
        get async {
            await local.dialogUpdatePublisher
                .eraseToAnyPublisher()
        }
    }
    
    public func create(dialogInRemote entity: Dialog) async throws -> Dialog {
        do {
            let data = try await remote.create(dialog: RemoteDialogDTO(entity))
            return Dialog(data)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func save(dialogToLocal entity: Dialog) async throws {
        do {
            try await local.save(dialog: LocalDialogDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func update(dialogInRemote entity: Dialog,
                       users: [User]) async throws -> Dialog {
        do {
            let data = try await
            remote.update(dialog: RemoteDialogDTO(entity),
                          users: users.map { RemoteUserDTO($0) })
            return Dialog(data)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func update(dialogInLocal entity: Dialog) async throws {
        do {
            try await local.update(dialog: LocalDialogDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(dialogFromRemote dialogId: String) async throws -> Dialog {
        do {
            let withId = RemoteDialogDTO(id: dialogId)
            let data = try await remote.get(dialog: withId)
            return Dialog(data)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(dialogFromLocal dialogId: String) async throws -> Dialog {
        do {
            let withId = LocalDialogDTO(id: dialogId)
            let data = try await local.get(dialog: withId)
            return Dialog(data)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func delete(dialogFromRemote entity: Dialog) async throws {
        do {
            try await remote.delete(dialog: RemoteDialogDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func delete(dialogFromLocal dialogId: String) async throws {
        do {
            let withId = LocalDialogDTO(id: dialogId)
            try await local.delete(dialog: withId)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func getAllDialogsFromRemote() async throws -> [Dialog] {
        do {
            let data = try await remote.getAllDialogs()
            return data.dialogs.map { Dialog($0)}
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func getDialogsFromRemote(for page: Pagination = Pagination(skip: 0))
    async throws -> (dialogs: [Dialog], usersIds: [String], page: Pagination) {
        do {
            let dto = RemoteDialogsDTO(pagination: page)
            let data = try await remote.get(dialogs: dto)
            return (dialogs: data.dialogs.map { Dialog($0)},
                    usersIds: data.usersIds,
                    page: data.pagination)
            
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func getAllDialogsFromLocal() async throws -> [Dialog] {
        do {
            let data = try await local.getAllDialogs()
            return data.dialogs.map { Dialog($0) }
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func removeAllDialogsFromLocal() async throws {
        do {
            try await local.removeAllDialogs()
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func cleareAll() async throws {
        do {
            try await local.cleareAll()
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func subscribeToObserveTyping(dialog dialogId: String) async throws {
        do {
            try await remote.subscribeToObserveTyping(dialog: dialogId)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func sendTyping(dialogInRemote dialogId: String) async throws {
        do {
            try await remote.sendTyping(dialog: dialogId)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func sendStopTyping(dialogInRemote dialogId: String) async throws {
        do {
            try await remote.sendStopTyping(dialog: dialogId)
        } catch {
            throw try error.repositoryException
        }
    }
}

private extension RemoteDialogDTO {
    init(_ value: Dialog) {
        id = value.id
        type = value.type
        name = value.name
        participantsIds = value.participantsIds
        photo = value.photo
        ownerId = value.ownerId
        updatedAt = value.updatedAt
        lastMessageId = value.lastMessage.id
        lastMessageText = value.lastMessage.text
        lastMessageDateSent = value.date
        lastMessageUserId = value.lastMessage.userId
        unreadMessagesCount = value.unreadMessagesCount
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
        toAddIds = value.pushIDs
        toDeleteIds = value.pullIDs
    }
}

private extension LocalDialogDTO {
    init(_ value: Dialog) {
        id = value.id
        type = value.type
        name = value.name
        participantsIds = value.participantsIds
        photo = value.photo
        ownerId = value.ownerId
        updatedAt = value.updatedAt
        messages = value.messages.map { LocalMessageDTO($0) }
        
        lastMessageId = value.lastMessage.id
        lastMessageText = value.lastMessage.text
        lastMessageDateSent = value.lastMessage.dateSent ?? updatedAt
        lastMessageUserId = value.lastMessage.userId
        
        unreadMessagesCount = value.unreadMessagesCount
        decrementCounter = value.decrementCounter
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
    }
}

private extension Dialog {
    init(_ value: RemoteDialogDTO) {
        id = value.id
        type = value.type
        name = value.name
        participantsIds = value.participantsIds
        photo = value.photo
        ownerId = value.ownerId
        createdAt = value.createdAt
        updatedAt = value.updatedAt
        lastMessage = LastMessage(id: value.lastMessageId,
                                  text: value.lastMessageText,
                                  dateSent: value.lastMessageDateSent,
                                  userId: value.lastMessageUserId,
                                  dialogId: value.id)
        unreadMessagesCount = value.unreadMessagesCount
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
    }
    
    init(_ value: LocalDialogDTO) {
        id = value.id
        type = value.type
        name = value.name
        participantsIds = value.participantsIds
        photo = value.photo
        ownerId = value.ownerId
        createdAt = value.createdAt
        updatedAt = value.updatedAt
        messages = value.messages.map{ Message($0) }
        lastMessage = LastMessage(id: value.lastMessageId,
                                  text: value.lastMessageText,
                                  dateSent: value.lastMessageDateSent,
                                  userId: value.lastMessageUserId,
                                  dialogId: value.id)
        unreadMessagesCount = value.unreadMessagesCount
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
    }
}
