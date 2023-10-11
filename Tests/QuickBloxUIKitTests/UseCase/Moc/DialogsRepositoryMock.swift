//
//  DialogRepositoryMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData
import Combine

class DialogsRepositoryMock: Mock {
    var remotePublisher: AnyPublisher<RemoteDialogEvent<Message>, Never>
    var localPublisher: AnyPublisher<[Dialog], Never>
    var localDialogPublisher: AnyPublisher<String, Never>
    
    init(remotePublisher: AnyPublisher<RemoteDialogEvent<Message>, Never> =
         PassthroughSubject<RemoteDialogEvent, Never>().eraseToAnyPublisher(),
         localPublisher: AnyPublisher<[Dialog], Never> =
         PassthroughSubject<[Dialog], Never>().eraseToAnyPublisher(),
         localDialogPublisher: AnyPublisher<String, Never> =
         PassthroughSubject<String, Never>().eraseToAnyPublisher(),
         results: [String: Result<[Any], Error>] = [:]) {
        self.remotePublisher = remotePublisher
        self.localPublisher = localPublisher
        self.localDialogPublisher = localDialogPublisher
        let info = results
        super.init(info)
    }
}

extension DialogsRepositoryMock: DialogsRepositoryProtocol {
    struct MockMethod {
        static let getFromRemote = "get(dialogFromRemote:)"
        static let getFromLocal = "get(dialogFromLocal:)"
        static let getAllFromRemote = "getDialogsFromRemote(for)"
        static let removeAllDialogsFromLocal = "removeAllDialogsFromLocal()"
        static let saveDialogToLocal = "save(dialogToLocal:)"
        static let saveDialogsToLocal = "save(dialogsToLocal:)"
        static let updateDialogInLocal = "update(dialogInLocal:)"
    }
    
    var localDialogsPublisher: AnyPublisher<[QuickBloxData.Dialog], Never> {
        get async {
            return localPublisher
        }
    }
    
    var localDialogUpdatePublisher: AnyPublisher<String, Never> {
        get async {
            return localDialogPublisher
        }
    }
    
    var remoteEventPublisher: AnyPublisher<RemoteDialogEvent<Message>, Never> {
        return remotePublisher
    }
    
    func create(dialogInRemote entity: Dialog) async throws -> Dialog {
        throw RepositoryException.unexpected()
    }
    
    func save(dialogToLocal entity: Dialog) async throws {
        try await mock().callAcyncVoid()
    }
    
    func save(dialogsToLocal entities: [QuickBloxData.Dialog]) async throws {
        try await mock().callAcyncVoid()
    }
    
    func update(dialogInRemote entity: Dialog, users: [User]) async throws -> Dialog {
        throw RepositoryException.unexpected()
    }
    
    func update(dialogInLocal entity: Dialog) async throws {
        try await mock().callAcyncVoid()
    }
    
    func get(dialogFromRemote dialogId: String) async throws -> Dialog {
        return try await mock().callAcyncReturn()
    }
    
    func get(dialogFromLocal dialogId: String) async throws -> Dialog {
        return try await mock().callAcyncReturn()
    }
    
    func delete(dialogFromRemote entity: Dialog) async throws {
        throw RepositoryException.unexpected()
    }
    
    func delete(dialogFromLocal dialogId: String) async throws {
        throw RepositoryException.unexpected()
    }
    
    func getAllDialogsFromRemote() async throws -> [Dialog] {
        return try await mock().callAcyncReturn()
    }
    
    func getAllDialogsFromLocal() async throws -> [Dialog] {
        throw RepositoryException.unexpected()
    }
    func getDialogsFromRemote(for page: Pagination = Pagination(skip: 0))
    async throws -> (dialogs: [Dialog], usersIds: [String], page: Pagination) {
        return try await mock().callAcyncReturn()
    }
    
    public func removeAllDialogsFromLocal() async throws {
        try await mock().callAcyncVoid()
    }
    
    public func cleareAll() async throws {
        try await mock().callAcyncVoid()
    }
    
    func subscribeToObserveTyping(dialog dialogId: String) async throws {
        try await mock().callAcyncVoid()
    }
    
    func sendTyping(dialogInRemote dialogId: String) async throws {
        try await mock().callAcyncVoid()
    }
    
    func sendStopTyping(dialogInRemote dialogId: String) async throws {
        try await mock().callAcyncVoid()
    }
}
