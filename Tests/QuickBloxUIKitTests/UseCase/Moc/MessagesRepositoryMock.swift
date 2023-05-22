//
//  MessagesRepositoryMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData
import Foundation

class MessagesRepositoryMock: Mock { }

extension MessagesRepositoryMock: MessagesRepositoryProtocol {
    struct MockMethod {
        static let sendToRemote = "send(messageToRemote:)"
        static let saveToLocal = "save(messageToLocal:)"
        static let getFromRemote = "get(messagesFromRemote:messagesIds:page:)"
        static let getFromLocal = "get(messagesFromLocal:)"
        static let updateInRemote = "update(messageInRemote:)"
        static let updateInLocal = "update(messageInLocal:)"
        static let deleteFromRemote = "delete(messageFromRemote:)"
        static let deleteFromLocal = "delete(messageFromLocal:)"
    }
    
    func send(messageToRemote entity: Message) async throws {
        try await mock().callAcyncVoid()
    }
    
    func save(messageToLocal entity: Message) async throws {
        try await mock().callAcyncVoid()
    }
    
    func get(messagesFromRemote dialogId: String,
             messagesIds: [String] = [],
             page: Pagination = Pagination(skip: 0))
    async throws -> (messages: [Message], page: Pagination) {
        try await mock().callAcyncReturn()
    }
    
    func get(messagesFromLocal dialogId: String) async throws -> [Message] {
        try await mock().callAcyncReturn()
    }
    
    func update(messageInRemote entity: Message) async throws -> Message {
        try await mock().callAcyncReturn()
    }
    
    func update(messageInLocal entity: Message) async throws -> Message {
        try await mock().callAcyncReturn()
    }
    
    func delete(messageFromRemote entity: Message) async throws {
        try await mock().callAcyncVoid()
    }
    
    func delete(messageFromLocal entity: Message) async throws {
        try await mock().callAcyncVoid()
    }
}
