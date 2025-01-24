//
//  AnswerAssistMessage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// Contain methods and properties that describe an Answer Assist Message.
///
/// This is an active model that conforms to the ``AnswerAssistMessageEntity`` protocol.
public struct AnswerAssistMessage: AnswerAssistMessageEntity {
    public typealias AnswerAssistHistoryMessageItem = AnswerAssistHistoryMessage
    public var id: String = UUID().uuidString
    public var smartChatAssistantId: String
    public var message: String
    public var history: [AnswerAssistHistoryMessage]
    
    public init(message: String,
                history: [AnswerAssistHistoryMessage],
                smartChatAssistantId: String) {
        self.smartChatAssistantId = smartChatAssistantId
        self.message = message
        self.history = history
    }
}

public extension AnswerAssistMessage {
    init<T: AnswerAssistMessageEntity>(_ value: T) {
        self.init(message: value.message,
                  history: value.history.map({ AnswerAssistHistoryMessage($0) }),
                  smartChatAssistantId: value.smartChatAssistantId)
    }
}

/// Contain methods and properties that describe an Answer Assist History Message.
///
/// This is an active model that conforms to the ``AnswerAssistHistoryMessageEntity`` protocol.
public struct AnswerAssistHistoryMessage: AnswerAssistHistoryMessageEntity {
    public var id: String = UUID().uuidString
    public var role: AIMessageRole
    public var message: String
    
    public init(role: AIMessageRole,
                message: String) {
        self.role = role
        self.message = message
    }
}

public extension AnswerAssistHistoryMessage {
    init<T: AnswerAssistHistoryMessageEntity>(_ value: T) {
        self.init(role: value.role,
                  message: value.message)
    }
}

public extension AnswerAssistHistoryMessage {
    init<T: MessageEntity>(_ value: T) {
        self.init(role: value.isOwnedByCurrentUser ? .user : .assistant,
                  message: value.text)
    }
}
