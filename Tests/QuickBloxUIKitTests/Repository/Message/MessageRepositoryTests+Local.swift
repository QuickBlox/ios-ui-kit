//
//  MessageRepositoryTests+Local.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest

@testable import QuickBloxDomain
@testable import QuickBloxData

//MARK: Utils
extension MessageRepositoryTests {
    private func repository(mock result: Result<[Any], Error>) -> MessagesRepository {
        MessagesRepository(remote: RemoteDataSource(), local: LocalDataSourceMock(result))
    }
}

//MARK: Save Message
extension MessageRepositoryTests {
    func testSaveMessageInLocal() async throws {
        let mockEntity = LocalMessagesDTO.default
        
        let result = [mockEntity]
        let repository = repository(mock: .success(result))

        let entity = Message.default
        try await repository.save(messageToLocal: entity)
        let messages = try await repository.get(messagesFromLocal: entity.dialogId)
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages[0].id, entity.id)
    }
    
    func testSaveMessageInLocalAlreadyExist() async throws {
        let repository = repository(mock: .failure(DataSourceException.alreadyExist()))
        
        await XCTAssertThrowsException(
            try await repository.save(messageToLocal: Message.default),
            equelTo: RepositoryException.alreadyExist())
    }
}

//MARK: Update Message
extension MessageRepositoryTests {
    func testUpdateMessageInLocal() async throws {
        let textToUpdate = "TextToUpdate"
        let mockEntity = LocalMessageDTO(id: Test.stringId, dialogId: Test.dialogId, text: textToUpdate)
        let mockResult = [mockEntity]
        let repository = repository(mock: .success(mockResult))

        let entity =  Message.default
        try await repository.save(messageToLocal: entity)
        var toUpdate =  Message(id: Test.stringId, dialogId: Test.dialogId)
        toUpdate.text = textToUpdate

        let result = try await
        repository.update(messageInLocal: toUpdate)
        
        XCTAssertEqual(toUpdate.text, result.text)
    }
    
    func testUpdateMessageInLocalNotFound() async throws {
        let repository = repository(mock: .failure(DataSourceException.notFound()))
        
        await XCTAssertThrowsException(
            try await repository.update(messageInLocal: Message.default),
            equelTo: RepositoryException.notFound())
    }
}

//MARK: Delete Message
extension MessageRepositoryTests {
    func testDeleteMessageInLocal() async throws {
        let mockEntity = LocalMessagesDTO.withEmptyMessages
        
        let result = [mockEntity]
        let repository = repository(mock: .success(result))

        let entity =  Message.default

        try await repository.save(messageToLocal: entity)
        try await repository.delete(messageFromLocal: Message.default)
        let messages = try await repository.get(messagesFromLocal: entity.dialogId)
        XCTAssertEqual(messages.count, 0)
    }
    
    func testDeleteMessageInLocalNotFound() async throws {
        let repository = repository(mock: .failure(DataSourceException.notFound()))
        
        await XCTAssertThrowsException(
            try await repository.delete(messageFromLocal: Message.default),
            equelTo: RepositoryException.notFound())
    }
}

//MARK: Get Messages
extension MessageRepositoryTests {
    func testGetMessagesInLocal() async throws {
        let mockEntity = LocalMessagesDTO.default
        let result = [mockEntity]
        let repository = repository(mock: .success(result))

        let entity =  Message.default
        try await repository.save(messageToLocal: entity)
        let messages = try await repository.get(messagesFromLocal: entity.dialogId)
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages[0].dialogId, entity.dialogId)
    }
    
    func testGetMessagesInLocalEmptyStorage() async throws {
        let mockEntity = LocalMessagesDTO.withEmptyMessages
        
        let result = [mockEntity]
        let repository = repository(mock: .success(result))
        let messages = try await repository.get(messagesFromLocal: Test.dialogId)
        XCTAssertEqual(messages.count, 0)
    }
}
