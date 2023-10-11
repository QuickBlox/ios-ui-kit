//
//  AnswerAssist.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 04.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QBAIAnswerAssistant

public protocol AIFeatureUseCaseProtocol {
    func execute() async throws -> String
}

public class AnswerAssist: AIFeatureUseCaseProtocol {
    private let content: [any MessageEntity]
    private var settings: QBAIAnswerAssistant.AISettings
    
    public init(_ content: [any MessageEntity], settings: QBAIAnswerAssistant.AISettings) {
        self.content = content
        self.settings = settings
    }
    
    public func execute() async throws -> String {
        
        if settings.serverPath.isEmpty == false {
            guard let qbToken = QBSession.current.sessionDetails?.token else {
                throw RepositoryException.unauthorised()
            }
            settings.token = qbToken
        }
        
        let messages: [QBAIAnswerAssistant.AIMessage] = content.compactMap { message in
            if message.isOwnedByCurrentUser {
                return QBAIAnswerAssistant.AIMessage(role: .me, text: message.text)
            } else {
                return QBAIAnswerAssistant.AIMessage(role: .other, text: message.text)
            }
        }
        
        return try await QBAIAnswerAssistant.createAnswer(to: messages,
                                                          using: settings)
    }
}
