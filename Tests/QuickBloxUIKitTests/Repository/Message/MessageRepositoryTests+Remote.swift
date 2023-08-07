//
//  MessageRepositoryTests+Remote.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 01.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest

@testable import QuickBloxDomain
@testable import QuickBloxData

//MARK: Utils
extension MessageRepositoryTests {
    private func repository(mock results: [String: Result<[Any], Error>]) -> MessagesRepository {
        MessagesRepository(remote: RemoteDataSourceMock(results),
                           local: LocalDataSource())
    }
}

//MARK: Get Messages
extension MessageRepositoryTests {
    func testGetMessagesWithDialogIdFromeRemoteNotFound() async throws {
        //FIXME: Should we return an empty array?
        let methodResult: Result<[Any], Error> =
            .failure(DataSourceException.notFound())
        let repository = repository(mock: [MockMethod.getMessages: methodResult])
        
        await XCTAssertThrowsException(
            try await repository.get(messagesFromRemote: Test.dialogId),
            equelTo: RepositoryException.notFound())
    }
    
    func testGetMessagesWithDialogIdFromeRemote() async throws {
        let mockEntity = RemoteMessagesDTO(dialogId: Test.dialogId,
                                           messages: [RemoteMessageDTO.default])
        
        let mockResult = [mockEntity]
        let repository =
        repository(mock: [MockMethod.getMessages: .success(mockResult)])
        
        let result = try await repository.get(messagesFromRemote: Test.dialogId)
        XCTAssertEqual(result.messages.count, 1)
    }
}

//MARK: Update Message
extension MessageRepositoryTests {
    func testUpdateMessageInRemote() async throws {
        let mockEntity = RemoteMessageDTO(id: Test.stringId, dialogId: Test.dialogId, text: Test.text)
        let results: [String: Result<[Any], Error>] =
        [MockMethod.updateMessage: .success([mockEntity])]

        var entity = Message.default
        entity.text = Test.text

        let message = try await
        repository(mock: results).update(messageInRemote: entity)

        XCTAssertEqual(message.text, entity.text)
    }
    
    func testUpdateMessageInRemoteWithNegativeCases() async throws {
        try await
        updateThrow(exception: .unauthorised(),
                    withMock: RemoteDataSourceException.unauthorised())
        try await
        updateThrow(exception: .incorrectData(),
                    withMock: RemoteDataSourceException.incorrectData())
        try await
        updateThrow(exception: .restrictedAccess(),
                    withMock: RemoteDataSourceException.restrictedAccess())
    }
    
    private func updateThrow(exception: RepositoryException,
                             withMock result: Error) async throws  {
        let results: [String: Result<[Any], Error>] =
        [MockMethod.updateMessage: .failure(result)]
        
        let repository = repository(mock: results)

        await XCTAssertThrowsException(
            try await repository.update(messageInRemote: Message.default),
            equelTo: exception
        )
    }
}

//MARK: Delete Message
extension MessageRepositoryTests {
    func testDeleteMessageFromRemote() async throws {
        let results: [String: Result<[Any], Error>] =
        [MockMethod.deleteMessage: .success([])]
        let repository = repository(mock: results)

        try await repository.delete(messageFromRemote: Message.default)
    }

    func testDeleteMessageFromRemoteNegativeCases() async throws {
        let results: [String: Result<[Any], Error>] =
        [MockMethod.deleteMessage: .failure(DataSourceException.notFound())]
        
        let repository = repository(mock: results)

        await XCTAssertThrowsException(
            try await repository.delete(messageFromRemote: Message.default),
            equelTo: RepositoryException.notFound())
    }
}
