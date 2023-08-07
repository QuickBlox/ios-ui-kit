//
//  LocalDataSource.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.12.2022.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Combine
import Foundation
import QuickBloxLog

/// This is a class that implements the ``LocalDataSourceProtocol`` protocol and contains methods and properties that allow it to interact with the local data source.
///
/// An object of this class provides access for local storage of ``Entity`` items at the time of the application's life cycle.  Provides access to a single repository object by calling **LocalDataSource.instance** static property.
actor LocalDataSource: LocalDataSourceProtocol {
    //MARK: Properties
    private var dialogs = CurrentValueSubject<[LocalDialogDTO], Never>([])
    private var users: [String: LocalUserDTO] = [:]
    
    var dialogsPublisher: AnyPublisher<[LocalDialogDTO], Never> {
        get async {
            dialogs.eraseToAnyPublisher()
        }
    }
}

//MARK: Clear
extension LocalDataSource {
    func cleareAll() async throws {
        try await removeAllDialogs()
        users.removeAll()
    }
}

//MARK: Dialogs
extension LocalDataSource {
    func save(dialog dto: LocalDialogDTO) async throws {
        if dialogs.value.first(where: { $0.id == dto.id }) != nil {
            try await update(dialog: dto)
            return
        }
        var value = dialogs.value
        value.insertElement(dto, withSorting: .orderedDescending)
        dialogs.value = value
    }
    
    func get(dialog dto: LocalDialogDTO) async throws -> LocalDialogDTO {
        guard let dialog = dialogs.value.first(where: { $0.id == dto.id }) else {
            throw DataSourceException.notFound()
        }
        return dialog
    }
    
    func delete(dialog dto: LocalDialogDTO) async throws {
        guard let index = dialogs.value.firstIndex(where: { $0.id == dto.id }) else {
            throw DataSourceException.notFound()
        }
        dialogs.value.remove(at: index)
    }
    
    func update(dialog dto: LocalDialogDTO) async throws {
        guard let index = dialogs.value.firstIndex(where: { $0.id == dto.id }) else {
            throw DataSourceException.notFound()
        }
        
        var dialog = dialogs.value[index]
        
        if dto.name.isEmpty == false {
            dialog.name = dto.name
        }
        
        if dto.participantsIds.isEmpty == false {
            dialog.participantsIds = dto.participantsIds
        }
        
        if dto.photo.isEmpty == false {
            dialog.photo = dto.photo
        }
        
        dialog.updatedAt = dto.updatedAt
        
        if dto.unreadMessagesCount != 0 {
            dialog.unreadMessagesCount = dto.unreadMessagesCount
        }
        
        if dto.messages.isEmpty == false {
            for new in dto.messages {
                dialog.messages.insertElement(new, withSorting: .orderedAscending)
            }
        }
        
        if dto.lastMessageId.isEmpty == false {
            dialog.lastMessageId = dto.lastMessageId
        }
        
        if dto.lastMessageText.isEmpty == false {
            dialog.lastMessageText = dto.lastMessageText
        }
        
        if dto.lastMessageDateSent != Date(timeIntervalSince1970: 0.0) {
            dialog.lastMessageDateSent = dto.lastMessageDateSent
        }
        
        if dto.lastMessageUserId.isEmpty == false {
            dialog.lastMessageUserId = dto.lastMessageUserId
        }
        
        dialogs.value[index] = dialog
    }
    
    func getAllDialogs() async throws -> LocalDialogsDTO {
        return LocalDialogsDTO(dialogs: Array(dialogs.value))
    }
    
    func getAllUsers() async throws -> [LocalUserDTO] {
        return Array(users.values)
    }
    
    func removeAllDialogs() async throws {
        dialogs.value.removeAll()
    }
}

//MARK: Messages
extension LocalDataSource {
    func save(message: LocalMessageDTO) async throws {
        guard let index = dialogs.value.firstIndex(where: { $0.id == message.dialogId }) else {
            let info = "Dialog not found for message with dialog id: \(message.dialogId)"
            throw DataSourceException.notFound(description: info)
        }
        var dialog = dialogs.value[index]
        dialog.messages.insertElement(message, withSorting: .orderedAscending)
        dialogs.value[index] = dialog
    }
    
    func get(messages dto: LocalMessagesDTO) async throws -> LocalMessagesDTO {
        guard let dialog = dialogs.value.first(where: { $0.id == dto.dialogId }) else {
            let info = "Dialog not found for messages with dialog id: \(dto.dialogId)"
            throw DataSourceException.notFound(description: info)
        }
        
        var result = LocalMessagesDTO()
        result.dialogId = dialog.id
        result.messages = dialog.messages
        
        return result
    }
    
    func delete(message dto: LocalMessageDTO) async throws {
        guard let index = dialogs.value.firstIndex(where: { $0.id == dto.dialogId }) else {
            let info = "Dialog not found for messages with dialog id: \(dto.dialogId)"
            throw DataSourceException.notFound(description: info)
        }
        var dialog = dialogs.value[index]
        
        dialog.messages.removeAll { $0.id == dto.id }
        dialogs.value[index] = dialog
    }
    
    func update(message dto: LocalMessageDTO) async throws {
        guard let index = dialogs.value.firstIndex(where: { $0.id == dto.dialogId }) else {
            let info = "Dialog not found for messages with dialog id: \(dto.dialogId)"
            throw DataSourceException.notFound(description: info)
        }
        var dialog = dialogs.value[index]
        dialog.messages.insertElement(dto, withSorting: .orderedAscending)
        dialogs.value[index] = dialog
    }
}

//MARK: Users
extension LocalDataSource {
    func save(user dto: LocalUserDTO) async throws {
        users[dto.id] = dto
    }
    
    func get(user dto: LocalUserDTO) async throws -> LocalUserDTO {
        guard let user = users[dto.id] else {
            throw DataSourceException.notFound()
        }
        
        return user
    }
}
