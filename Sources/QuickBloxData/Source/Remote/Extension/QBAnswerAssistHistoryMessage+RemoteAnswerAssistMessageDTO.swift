//
//  QBAnswerAssistMessage+RemoteAnswerAssistMessageDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox

extension QBAIAnswerAssistHistoryMessage {
    convenience init(_ value: RemoteAnswerAssistHistoryMessageDTO) {
        self.init(role: value.role == .user ? .user : .assistant,
                  message: value.message)
    }
}

extension QBAIAnswerAssistMessage {
    convenience init(_ value: RemoteAnswerAssistMessageDTO) {
        self.init(message: value.message,
                  smartChatAssistantId: value.smartChatAssistantId,
                  history: value.history.compactMap({ QBAIAnswerAssistHistoryMessage($0) }))
    }
}
