//
//  Rephrase.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QBAIRephrase

public class Rephrase: AIFeatureUseCaseProtocol {
    private let text: String
    private var content: [any MessageEntity]
    private var settings: QBAIRephrase.AISettings
    
    public init(_ text: String, content: [any MessageEntity], settings: QBAIRephrase.AISettings) {
        self.text = text
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
        
        let messages: [QBAIRephrase.AIMessage] = content.compactMap { message in
            if message.isOwnedByCurrentUser {
                return QBAIRephrase.AIMessage(role: .me, text: message.text)
            } else {
                return QBAIRephrase.AIMessage(role: .other, text: message.text)
            }
        }
        
        return try await QBAIRephrase.rephrase(text: text, history: messages, using: settings)
    }
}
