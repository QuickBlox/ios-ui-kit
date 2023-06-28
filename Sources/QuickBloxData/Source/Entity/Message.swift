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
    public var isRead: Bool = false
    public var isDelivered = false
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

public extension Message {
    init<T: MessageEntity>(_ value: T) {
        self.init(id: value.id,
                  dialogId: value.dialogId,
                  text: value.text,
                  userId: value.userId,
                  date: value.date,
                  isOwnedByCurrentUser: value.isOwnedByCurrentUser,
                  deliveredIds: value.deliveredIds,
                  readIds: value.readIds,
                  isDelivered: value.isDelivered,
                  isRead: value.isRead,
                  eventType: value.eventType,
                  type: value.type)
        if let fileInfo = value.fileInfo {
            self.fileInfo = FileInfo(fileInfo)
        }
        
    }
}
