//
//  Message.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// Contain methods and properties that describe a message  during the conversation.
///
/// This is an active model that conforms to the ``MessageEntity`` protocol.
public struct Message: MessageEntity {
    public var id: String
    
    /// The unique ID of the conversation that the message belongs to.
    public let dialogId: String
    
    /// Message text.
    ///
    /// > Note: Returns an empty string by default
    public var text: String = ""
    
    public var userId: String = ""
    public var isOwnedByCurrentUser = false
    public var date: Date = Date()
    
    public var fileInfo: FileInfo?
    public var deliveredIds: [String] = []
    public var readIds: [String] = []
    public var eventType: MessageEventType = .message
    public var type: MessageType = .chat
    
    public init(id: String = UUID().uuidString,
                dialogId: String,
                type: MessageType) {
        self.id = id
        self.dialogId = dialogId
        self.type = type
    }
}
