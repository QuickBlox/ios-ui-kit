//
//  RemoteDataSourceMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData
import Combine

class RemoteDataSourceMock: Mock {
    struct MockMethod {
        //FIXME: rename
        static let getUser = "get(user:)"
        static let getUsers = "get(users:)"
        static let getMessages = "get(messages:)"
        static let updateMessage = "update(message:)"
        static let deleteMessage = "delete(message:)"
        static let connect = "connect()"
        static let disconnect = "disconnect()"
        static let checkConnection = "checkConnection()"
        static let createDialog = "create(dialog:)"
        static let updateDialog = "update(dialog:users:)"
        static let getDialog = "get(dialog:)"
        static let deleteDialog = "delete(dialog:)"
        static let getDialogs = "get(dialogs:)"
        static let createFile = "create(file:)"
        static let getFile = "get(file:)"
        static let deleteFile = "delete(file:)"
    }
    
    let event: AnyPublisher<RemoteEvent, Never>
    let connectState: AnyPublisher<ConnectionState, Never>
    
    init(_ results: [String: Result<[Any], Error>] = [:],
         eventPublisher: AnyPublisher<RemoteEvent, Never> =
         PassthroughSubject<RemoteEvent, Never>().eraseToAnyPublisher(),
         connectionStatePublisher: AnyPublisher<ConnectionState, Never> =
         PassthroughSubject<ConnectionState, Never>().eraseToAnyPublisher() ) {
        self.event = eventPublisher
        self.connectState = connectionStatePublisher
        super.init(results)
    }
}

extension RemoteDataSourceMock: RemoteDataSourceProtocol {
    
    var eventPublisher: AnyPublisher<RemoteEvent, Never> {
        return event
    }
    
    var connectionPublisher: AnyPublisher<ConnectionState, Never> {
        return connectState
    }
    
    func connect() async throws {
        try await mock().callAcyncVoid()
    }
    
    func disconnect() async throws {
        try await mock().callAcyncVoid()
    }
    
    func checkConnection() async throws {
        try await mock().callAcyncVoid()
    }
    
    func create(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
        return try mock().getFirst()
    }
    
    func update(dialog dto: RemoteDialogDTO,
                users: [RemoteUserDTO]) async throws -> RemoteDialogDTO {
        return try mock().getFirst()
    }
    
    func get(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
        return try mock().getFirst()
    }
    
    func getAllDialogs() async throws -> RemoteDialogsDTO {
        return try mock().getFirst()
    }
    
    func get(dialogs dto: RemoteDialogsDTO) async throws -> RemoteDialogsDTO {
        return try mock().getFirst()
    }
    
    func delete(dialog dto: RemoteDialogDTO) async throws {
        _ = try mock().get()
    }
    
    func subscribeToObserveTyping(dialog dialogId: String) async throws {
        _ = try mock().get()
    }
    
    func sendTyping(dialog dialogId: String) async throws {
        _ = try mock().get()
    }
    
    func sendStopTyping(dialog dialogId: String) async throws {
        _ = try mock().get()
    }
    
    func get(messages dto: RemoteMessagesDTO) async throws -> RemoteMessagesDTO {
        return try mock().getFirst()
    }
    
    func send(message dto: RemoteMessageDTO) async throws {
        _ = try mock().get()
    }
    
    func update(message dto: RemoteMessageDTO) async throws -> RemoteMessageDTO {
        return try mock().getFirst()
    }
    
    func delete(message dto: RemoteMessageDTO) async throws {
        _ = try mock().get()
    }
    
    func read(message dto: RemoteMessageDTO) async throws {
        _ = try mock().get()
    }
    
    func markAsDelivered(message dto: RemoteMessageDTO) async throws {
        _ = try mock().get()
    }
    
    func get(user dto: RemoteUserDTO) async throws -> RemoteUserDTO {
        return try mock().getFirst()
    }
    
    func get(users dto: RemoteUsersDTO) async throws -> RemoteUsersDTO {
        return try mock().getFirst()
    }
    
    func create(file dto: RemoteFileDTO) async throws -> RemoteFileDTO {
        return try await mock().callAcyncReturn()
    }
    
    func get(file dto: RemoteFileDTO) async throws -> RemoteFileDTO {
        return try await mock().callAcyncReturn()
    }
    
    func delete(file dto: RemoteFileDTO) async throws {
        try await mock().callAcyncVoid()
    }
}
