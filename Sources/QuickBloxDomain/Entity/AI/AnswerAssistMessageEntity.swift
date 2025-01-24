//
//  AnswerAssistMessageEntity.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// Define a set of predefined options for the type of AI Role
public enum AIMessageRole: String, Codable {
    case user
    case assistant
}

/// Describes a set of data and functions that represent an AnswerAssistHistoryMessage entity.
public protocol AnswerAssistHistoryMessageEntity: Entity {
    var id: String { get }
    
    var role: AIMessageRole { get }
    
    var message: String { get }
    
    init(role: AIMessageRole, message: String)
}

/// Describes a set of data and functions that represent an AnswerAssistMessage entity.
public protocol AnswerAssistMessageEntity: Entity {
    associatedtype AnswerAssistHistoryMessageItem: AnswerAssistHistoryMessageEntity
    
    var id: String { get }
    
    var smartChatAssistantId: String { get }
    
    var message: String { get }
    
    var history: [AnswerAssistHistoryMessageItem] { get }
    
    init(message: String,
         history: [AnswerAssistHistoryMessageItem],
         smartChatAssistantId: String)
}
