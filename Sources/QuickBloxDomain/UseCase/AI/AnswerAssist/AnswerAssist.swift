//
//  AnswerAssist.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog

public protocol AIFeatureUseCaseProtocol {
    func execute() async throws -> String
}

public class AIAnswerAssist<AnswerAssistMessageEntityItem: AnswerAssistMessageEntity,
                          HistoryMessageItem: AnswerAssistHistoryMessageEntity,
                          Repo: AIRepositoryProtocol,
                          MessageItem: MessageEntity>: AIFeatureUseCaseProtocol
where AnswerAssistMessageEntityItem == Repo.AnswerAssistMessageEntityItem,
      HistoryMessageItem == AnswerAssistMessageEntityItem.AnswerAssistHistoryMessageItem {
    private let message: MessageItem
    private let history: [MessageItem]
    private let smartChatAssistantId: String
    private let repo: Repo
    
    public init(message: MessageItem, history: [MessageItem], smartChatAssistantId: String, repo: Repo) {
        self.message = message
        self.history = history
        self.smartChatAssistantId = smartChatAssistantId
        self.repo = repo
    }
    
    public func execute() async throws -> String {

        let messages: [HistoryMessageItem] = history.compactMap { message in
            if message.isOwnedByCurrentUser {
                return HistoryMessageItem(role: .assistant, message: message.text)
            } else {
                return HistoryMessageItem(role: .user, message: message.text)
            }
        }
        
        let answerAssistMessage = AnswerAssistMessageEntityItem(message: message.text,
                                                                history: messages,
                                                                smartChatAssistantId: smartChatAssistantId)
        
        do {
            return try await repo.answerAssist(message: answerAssistMessage)
        } catch  {
            prettyLog(error)
            throw error
        }
    }
}

import Quickblox
import QBAIAnswerAssistant

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
                return QBAIAnswerAssistant.AIMessage(role: .other, text: message.text)
            } else {
                return QBAIAnswerAssistant.AIMessage(role: .me, text: message.text)
            }
        }
        
        return try await QBAIAnswerAssistant.createAnswer(to: messages,
                                                          using: settings)
    }
}
