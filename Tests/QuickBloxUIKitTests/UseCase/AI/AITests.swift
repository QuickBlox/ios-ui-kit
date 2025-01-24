//
//  AITests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest

@testable import QuickBloxDomain
@testable import QuickBloxData

final class AITests: XCTestCase {
    
    var aiRepoMock: AIRepositoryMock!
    
    override func setUp() async throws {
        try await super.setUp()
        
        aiRepoMock = AIRepositoryMock()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        
        aiRepoMock = nil
    }

    typealias AIMethod = AIRepositoryMock.MockMethod
    
    func testAnswerAssist() async throws {

        let answer = "Test Answer from Remote"
        
        aiRepoMock.results[AIMethod.answerAssistFromRemote] =
            .success([AcyncMockReturn { answer }])
        
        let dialogId = "a1s2d2f2g2hg2h"
        
        var userMessage = Message(id: "1c2c345616846", dialogId: dialogId, type: MessageType.chat)
        userMessage.isOwnedByCurrentUser = false
        userMessage.text = "Who are you?"
        
        var ownedMessage = Message(id: "1c2c3", dialogId: dialogId, type: MessageType.chat)
        ownedMessage.isOwnedByCurrentUser = true
        ownedMessage.text = "history 1"
        
        var message1 = Message(id: "1c2c3sdd", dialogId: dialogId, type: MessageType.chat)
        message1.isOwnedByCurrentUser = false
        message1.text = "history 11"
        
        var message2 = Message(id: "1c3sdd", dialogId: dialogId, type: MessageType.chat)
        message2.isOwnedByCurrentUser = false
        message2.text = "history 113"
        
        let history = [ownedMessage, message1, message2]
        
        let useCase = AnswerAssist(message: userMessage,
                                   history: history,
                                   smartChatAssistantId: "1s2d3d4f5f6f7f8f9f",
                                   repo: aiRepoMock)
        
        let answerFromRemote = try await useCase.execute()
        
        print("answerFromRemote = \(answerFromRemote)")
        
        XCTAssertEqual(answer, answerFromRemote)
    }
    
    func testTranslate() async throws {
        
        let translate = "Test Translate from Remote"
        
        aiRepoMock.results[AIMethod.translateFromRemote] =
            .success([AcyncMockReturn { translate }])
        
        let useCase = Translate(translate,
                                smartChatAssistantId: "1s2d3d4f5f6f7f8f9f",
                                languageCode: "uk",
                                repo: aiRepoMock)
        
        let translateFromRemote = try await useCase.execute()
        
        print("translateFromRemote = \(translateFromRemote)")
        
        XCTAssertEqual(translate, translateFromRemote)
    }
}
