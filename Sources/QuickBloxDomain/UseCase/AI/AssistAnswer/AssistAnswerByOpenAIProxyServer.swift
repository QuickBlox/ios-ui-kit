//
//  AssistAnswerByOpenAIProxyServer.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 04.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QBAIAnswerAssistant

public class AssistAnswerByOpenAIProxyServer: AIFeatureUseCaseProtocol {
    private let serverURLPath: String
    private let content: [any MessageEntity]
    
    public init(_ serverURLPath: String, content: [any MessageEntity]) {
        self.serverURLPath = serverURLPath
        self.content = content
    }
    
    public func execute() async throws -> String {
        guard let qbToken = QBSession.current.sessionDetails?.token else {
            throw RepositoryException.unauthorised()
        }
        
        let messages: [Message] = content.compactMap { message in
            if message.isOwnedByCurrentUser {
                return OwnerMessage(message.text)
            } else {
                return OpponentMessage(message.text)
            }
        }
        return try await QBAIAnswerAssistant.openAIAnswer(to: messages,
                                                          qbToken: qbToken,
                                                          proxy: serverURLPath)
    }
}
