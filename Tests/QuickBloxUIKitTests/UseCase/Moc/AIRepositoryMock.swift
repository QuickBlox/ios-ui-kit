//
//  AIRepositoryMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData

class AIRepositoryMock: Mock { }

extension AIRepositoryMock: AIRepositoryProtocol {

    struct MockMethod {
        static let answerAssistFromRemote = "answerAssist(message:)"
        static let translateFromRemote = "translate(message:)"
    }
    
    func answerAssist(message entity: AnswerAssistMessage) async throws -> String {
        try await mock().callAcyncReturn()
    }
    
    func translate(message entity: TranslateMessage) async throws -> String {
        try await mock().callAcyncReturn()
    }
}
