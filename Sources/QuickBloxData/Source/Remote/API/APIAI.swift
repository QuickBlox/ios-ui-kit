//
//  APIAI.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox

public struct APIAI {
    // Quickblox Server API
    public func answerAssist(with message: QBAIAnswerAssistMessage) async throws -> String {
        let result = try await QB.ai.answerAssist(withSmartChatAssistantId: message.smartChatAssistantId,
                                                  messageToAssist: message.message,
                                                  history: message.history)
        return result.answer
    }
    
    public func translate(with message: QBAITranslateMessage) async throws -> String {
        let result = try await QB.ai.translate(withSmartChatAssistantId: message.smartChatAssistantId,
                                               textToTranslate: message.message,
                                               languageCode: message.languageCode)
        return result.answer
    }
}


import QBAIAnswerAssistant

extension APIAI {
    // Quickblox QBAIAnswerAssistant Library
    public func answerAssist(with content: [RemoteMessageDTO], settings: QBAIAnswerAssistant.AISettings) async throws -> String {
        
        var aiSettings = settings
        
        if aiSettings.serverPath.isEmpty == false {
            guard let qbToken = QBSession.current.sessionDetails?.token else {
                throw DataSourceException.unauthorised(description: "")
            }
            aiSettings.token = qbToken
        }
        
        let messages: [QBAIAnswerAssistant.AIMessage] = content.compactMap { message in
            if message.isOwnedByCurrentUser {
                return QBAIAnswerAssistant.AIMessage(role: .other, text: message.text)
            } else {
                return QBAIAnswerAssistant.AIMessage(role: .me, text: message.text)
            }
        }
        
        return try await QBAIAnswerAssistant.createAnswer(to: messages,
                                                          using: aiSettings)
    }
}


import QBAITranslate

extension APIAI {
    // Quickblox QBAITranslate Library
    public func translate(with text: String, content: [RemoteMessageDTO], settings: QBAITranslate.AISettings) async throws -> String {
        
        var aiSettings = settings
        
        if settings.serverPath.isEmpty == false {
            guard let qbToken = QBSession.current.sessionDetails?.token else {
                throw DataSourceException.unauthorised(description: "")
            }
            aiSettings.token = qbToken
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
                                                 using: aiSettings)
    }
}
