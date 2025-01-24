//
//  Translate.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog

public class AITranslate<TranslateMessageEntityItem: TranslateMessageEntity,
                       Repo: AIRepositoryProtocol>: AIFeatureUseCaseProtocol
where TranslateMessageEntityItem == Repo.TranslateMessageEntityItem {
    private let text: String
    private let smartChatAssistantId: String
    private let languageCode: String
    private let repo: Repo
    
    public init(_ text: String, smartChatAssistantId: String, languageCode: String, repo: Repo) {
        self.text = text
        self.smartChatAssistantId = smartChatAssistantId
        self.languageCode = languageCode
        self.repo = repo
    }
    
    public func execute() async throws -> String {

        let translate = TranslateMessageEntityItem(message: text,
                                                   smartChatAssistantId: smartChatAssistantId,
                                                   languageCode: languageCode)
        
        do {
            return try await repo.translate(message: translate)
        } catch  {
            prettyLog(error)
            throw error
        }
    }
}

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
        
        var messages: [QBAITranslate.AIMessage] = []
        
        messages = content.compactMap { message in
            if message.isOwnedByCurrentUser {
                return QBAITranslate.AIMessage(role: .other, text: message.text)
            } else {
                return QBAITranslate.AIMessage(role: .me, text: message.text)
            }
        }
        
        messages = []
        
        return try await QBAITranslate.translate(text: text,
                                                 history: messages,
                                                 using: settings)
    }
}
