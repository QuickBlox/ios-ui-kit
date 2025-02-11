//
//  RemoteAnswerAssistMessageDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// This is a DTO model for interactions with the Answer Assist Message models in remote storage.
public struct RemoteAnswerAssistMessageDTO {
    public var id = ""
    public var smartChatAssistantId = ""
    public var message = ""
    public var history: [RemoteAnswerAssistHistoryMessageDTO] = []
    
    public init () {}
}

/// This is a DTO model for interactions with the Answer Assist History Message models in remote storage.
public struct RemoteAnswerAssistHistoryMessageDTO {
    public var id = ""
    public var role: AIMessageRole = .user
    public var message = ""
    
    public init () {}
}
