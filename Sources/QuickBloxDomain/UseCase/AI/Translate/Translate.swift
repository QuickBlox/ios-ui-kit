//
//  Translate.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 08.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QBAITranslate

public class Translate: AIFeatureUseCaseProtocol {
    private let text: String
    private var content: [any MessageEntity]
    private var settings: QBAITranslate.AISettings
    
    public init(_ text: String, content: [any MessageEntity], settings: QBAITranslate.AISettings) {
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
        
        let messages: [QBAITranslate.AIMessage] = content.compactMap { message in
            if message.isOwnedByCurrentUser {
                return QBAITranslate.AIMessage(role: .me, text: message.text)
            } else {
                return QBAITranslate.AIMessage(role: .other, text: message.text)
            }
        }
        
        
        return try await QBAITranslate.translate(text: text,
                                                 history: messages,
                                                 using: settings)
    }
}
