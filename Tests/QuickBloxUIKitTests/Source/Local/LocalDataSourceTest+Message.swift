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
