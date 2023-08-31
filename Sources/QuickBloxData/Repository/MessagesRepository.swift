//
//  MessagesRepository.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.

import QuickBloxDomain
import Foundation

/// This is a class that implements the ``MessagesRepositoryProtocol`` protocol and contains methods and properties that allow it to interact with the ``MessageEntity`` items.
///
/// An object of this class provides access for remote and local storages of ``MessageEntity`` items at the time of the application's life cycle.
public class MessagesRepository: MessagesRepositoryProtocol {
    private var remote: RemoteDataSourceProtocol!
    private var local:  LocalDataSourceProtocol!
    
    init(remote: RemoteDataSourceProtocol,
         local: LocalDataSourceProtocol) {
        self.remote = remote
        self.local = local
    }
    
    private init() { }
}

extension LocalMessageDTO {
    init(_ value: Message) {
        id = value.id
        dialogId = value.dialogId
        text = value.text
        senderId = value.userId
        dateSent = value.date
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
        deliveredIds = value.deliveredIds
        readIds = value.readIds
        isReaded = value.isRead
        isDelivered = value.isDelivered
        type = value.type
        eventType = value.eventType
        if let new = value.fileInfo {
            if fileInfo == nil { fileInfo = LocalFileInfoDTO() }
            fileInfo?.id = new.id
            fileInfo?.name = new.name
            fileInfo?.ext = new.ext
            fileInfo?.path = new.path
            fileInfo?.uid = new.uid
        }
    }
}

private extension RemoteMessageDTO {
    init(_ value: Message) {
        id = value.id
        dialogId = value.dialogId
        text = value.text
        senderId = value.userId
        dateSent = value.date
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
        deliveredIds = value.deliveredIds
        readIds = value.readIds
        isReaded = value.isRead
        isDelivered = value.isDelivered
        type = value.type
        eventType = value.eventType
        if let file = value.fileInfo {
            filesInfo.append(
                RemoteFileInfoDTO(
                    id: file.id,
                    name: file.name,
                    type: file.ext.type.rawValue,
                    path: file.path.remote,
                    uid: file.uid
                ))
        }
    }
}

extension Message {
    init(_ value: RemoteMessageDTO) {
        id = value.id
        dialogId = value.dialogId
        text = value.text
        userId = value.senderId
        date = value.dateSent
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
        isRead = value.isReaded
        isDelivered = value.isDelivered
        deliveredIds = value.deliveredIds
        readIds = value.readIds
        type = value.type
        eventType = value.eventType
        if let filesInfo = value.filesInfo.last {
            if let extStr = filesInfo.name.components(separatedBy: ".").last,
               let ext = FileExtension(rawValue: extStr.lowercased()) {
                fileInfo = FileInfo(id: filesInfo.id,
                                ext: ext,
                                name: filesInfo.name)
            } else {
                let info = """
                Message \(id) has an attachment with a name that does not
                include a file extension.
                """
                Warning.push(info)
                fileInfo = FileInfo(id: filesInfo.id,
                                ext: .json,
                                name: filesInfo.name)
            }
            fileInfo?.path.remote = filesInfo.path
            fileInfo?.uid = filesInfo.uid
        }
    }
    
    init(_ value: LocalMessageDTO) {
        id = value.id
        dialogId = value.dialogId
        text = value.text
        userId = value.senderId
        date = value.dateSent
        isOwnedByCurrentUser = value.isOwnedByCurrentUser
        deliveredIds = value.deliveredIds
        readIds = value.readIds
        isDelivered = value.isDelivered
        isRead = value.isReaded
        eventType = value.eventType
        type = value.type
        if let info = value.fileInfo {
            fileInfo = FileInfo(id: info.id,
                            ext: info.ext,
                            name: info.name)
            fileInfo?.path = info.path
            fileInfo?.uid = info.uid
        }
    }
}

extension MessagesRepository {
    public func send(messageToRemote entity: Message) async throws {
        do {
            _ = try await remote.send(message: RemoteMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func save(messageToLocal entity: Message) async throws {
        do {
            try await local.save(message: LocalMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(messagesFromRemote dialogId: String,
                    messagesIds: [String] = [],
                    page: Pagination = Pagination(skip: 0))
    async throws -> (messages: [Message], page: Pagination) {
        do {
            let withDialogId = RemoteMessagesDTO(dialogId: dialogId,
                                                 ids: messagesIds,
                                                 pagination: page)
            let data = try await remote.get(messages: withDialogId)
            return (data.messages.map {Message($0)}, data.pagination)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(messagesFromLocal dialogId: String) async throws -> [Message] {
        do {
            let withId = LocalMessagesDTO(dialogId: dialogId)
            return try await local.get(messages: withId).messages.map { Message($0)}
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func update(messageInRemote entity: Message) async throws -> Message {
        do {
            let data = try await remote.update(message: RemoteMessageDTO(entity))
            return Message(data)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func update(messageInLocal entity: Message) async throws -> Message {
        do {
            try await local.update(message: LocalMessageDTO(entity))
            return entity
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func delete(messageFromRemote entity: Message) async throws {
        do {
            try await remote.delete(message: RemoteMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func delete(messageFromLocal entity: Message) async throws {
        do {
            try await local.delete(message: LocalMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func read(messageInRemote entity: Message) async throws {
        do {
            try await remote.read(message: RemoteMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func markAsDelivered(messageInRemote entity: Message) async throws {
        do {
            try await remote.delete(message: RemoteMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
}
