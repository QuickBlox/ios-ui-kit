//
//  LocalDataSourceMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData
import Combine

class LocalDataSourceMock: LocalDataSourceProtocol {
    
    var mock: Result<[Any], Error>
    
    var dialogsPublisher: AnyPublisher<[LocalDialogDTO], Never>
    
    init(_ mock: Result<[Any], Error>,
         dialogsPublisher: AnyPublisher<[LocalDialogDTO], Never> =
         CurrentValueSubject<[LocalDialogDTO], Never>([]).eraseToAnyPublisher()
    ) {
        self.mock = mock
        self.dialogsPublisher = dialogsPublisher
    }
    
    func save(dialog: LocalDialogDTO) async throws {
        _ = try mock.get()
    }
    
    func save(dialogs dto: LocalDialogsDTO) async throws {
        _ = try mock.get()
    }
    
    func get(dialog dto: LocalDialogDTO) async throws -> LocalDialogDTO {
        return try mock.getFirst()
    }
    
    func delete(dialog dto: LocalDialogDTO) async throws {
        _ = try mock.get()
    }
    
    func update(dialog: LocalDialogDTO) async throws {
        _ = try mock.get()
    }
    
    func getAllDialogs() async throws -> LocalDialogsDTO {
        return try mock.getFirst()
    }
    
    func getAllUsers() async throws -> [LocalUserDTO] {
        return try mock.getResults()
    }
    
    func removeAllDialogs() async throws {
        _ = try mock.get()
    }
    
    func save(message: LocalMessageDTO) async throws {
        _ = try mock.get()
    }
    
    func get(messages dto: LocalMessagesDTO) async throws -> LocalMessagesDTO {
        return try mock.getFirst()
    }
    
    func update(message: LocalMessageDTO) async throws {
        _ = try mock.get()
    }
    
    func delete(message: LocalMessageDTO) async throws {
        _ = try mock.get()
    }
    
    func save(user: LocalUserDTO) async throws {
        _ = try mock.get()
    }
    
    func get(user dto: LocalUserDTO) async throws -> LocalUserDTO {
        return try mock.getFirst()
    }
    
    func cleareAll() async throws {
        _ = try mock.get()
    }
}
