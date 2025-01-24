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
    var id = ""
    var smartChatAssistantId = ""
    var message = ""
    var history: [RemoteAnswerAssistHistoryMessageDTO] = []
}

/// This is a DTO model for interactions with the Answer Assist History Message models in remote storage.
public struct RemoteAnswerAssistHistoryMessageDTO {
    var id = ""
    var role: AIMessageRole = .user
    var message = ""
}
