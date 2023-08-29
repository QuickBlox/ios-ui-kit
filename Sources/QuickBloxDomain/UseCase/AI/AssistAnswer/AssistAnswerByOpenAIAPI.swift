//
//  AssistAnswerByOpenAIAPI.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 04.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QBAIAnswerAssistant

public protocol AIFeatureUseCaseProtocol {
    func execute() async throws -> String
}

public class AssistAnswerByOpenAIAPI: AIFeatureUseCaseProtocol {
    private let apiKey: String
    private let content: [any MessageEntity]
    
    public init(_ apiKey: String, content: [any MessageEntity]) {
        self.apiKey = apiKey
        self.content = content
    }
    
    public func execute() async throws -> String {
        let messages: [Message] = content.compactMap { message in
            if message.isOwnedByCurrentUser {
                return OwnerMessage(message.text)
            } else {
                return OpponentMessage(message.text)
            }
        }
        return try await QBAIAnswerAssistant.openAIAnswer(to: messages,
                                                          secret: apiKey)
    }
}
