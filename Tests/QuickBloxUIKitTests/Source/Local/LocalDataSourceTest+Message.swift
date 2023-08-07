//
//  LocalDataSourceTest+Message.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 21.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest

@testable import QuickBloxDomain
@testable import QuickBloxData

//MARK: Update Message
extension LocalDataSourceTest {
    
    func testUpdateMessage() async throws {
        _ = try await createAndSaveMessage()
        
        let toUpdate = LocalMessageDTO(id: Test.stringId,
                                       dialogId: Test.dialogId,
                                       text: Test.updatedText)
        try await storage.update(message: toUpdate)
        let result = try await storage.get(messages: LocalMessagesDTO.withEmptyMessages).messages
        XCTAssertEqual(Test.updatedText, result[0].text)
    }
}

//MARK: Get Messages
extension LocalDataSourceTest {
    func testGetMessages() async throws {
        let ids = ["Test.id0", "Test.id1"]
        
        let message0 = try await createAndSave(messageWithId: ids[0])
        let message1 = try await createAndSave(messageWithId: ids[1])
        
        let result = try await storage.get(messages: LocalMessagesDTO.withEmptyMessages).messages
        
        XCTAssertEqual(result.count, ids.count)
        XCTAssertTrue(result.contains(message0))
        XCTAssertTrue(result.contains(message1))
    }
}
