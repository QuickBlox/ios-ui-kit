//
//  TranslateMessageEntity.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// Describes a set of data and functions that represent a TranslateMessage entity.
public protocol TranslateMessageEntity: Entity {
    
    var id: String { get }
    
    var message: String { get }
    
    var smartChatAssistantId: String { get }
    
    var languageCode: String { get }
    
    init(message: String,
         smartChatAssistantId: String,
         languageCode: String)
}

//public extension TranslateMessageEntity {
//    init(message: String,
//         smartChatAssistantId: String,
//         languageCode: String) {
//        self.init(id: UUID().uuidString,
//                  message: message,
//                  smartChatAssistantId: smartChatAssistantId,
//                  languageCode: languageCode)
//    }
//}
