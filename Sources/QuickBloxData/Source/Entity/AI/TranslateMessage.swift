//
//  TranslateMessage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain
import Foundation

/// Contain methods and properties that describe a Translate Message.
///
/// This is an active model that conforms to the ``TranslateMessageEntity`` protocol.
public struct TranslateMessage: TranslateMessageEntity {
    public var id: String = UUID().uuidString
    public var message: String
    public var smartChatAssistantId: String
    public var languageCode: String
    
    public init(message: String,
                smartChatAssistantId: String,
                languageCode: String) {
        self.message = message
        self.smartChatAssistantId = smartChatAssistantId
        self.languageCode = languageCode
    }
}

public extension TranslateMessage {
    init(message: String,
         smartChatAssistantId: String) {
        self.message = message
        self.smartChatAssistantId = smartChatAssistantId
        self.languageCode = QBAILanguage.english.rawValue
    }
}
