//
//  Dialog.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxLog
import Foundation

/// Contain methods and properties that describe a conversation between one or more participants.
///
/// This is an active model that conforms to the ``DialogEntity`` protocol.
public struct Dialog: DialogEntity {
    public let id: String
    public let type: DialogType
    
    public var name: String
    public var participantsIds: [String]
    public var photo: String
    public var ownerId: String
    public var isOwnedByCurrentUser = false
    public var createdAt: Date
    public var updatedAt: Date
    public var lastMessage = LastMessage(id: "",
                                         text: "",
                                         userId: "")
    public var messages: [Message] = []
    public var unreadMessagesCount: Int
    
    public init(id: String = "",
                type: DialogType,
                name: String = "",
                participantsIds: [String] = [],
                photo: String = "",
                ownerId: String = "",
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                lastMessage: LastMessage =
                LastMessage(id: "",
                            text: "",
                            userId: ""),
                messages: [Message] = [],
                unreadMessagesCount: Int = 0) {
        self.id = id
        self.type = type
        self.name = name
        self.participantsIds = participantsIds
        self.photo = photo
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessage = lastMessage
        self.messages = messages
        self.unreadMessagesCount = unreadMessagesCount
    }
}

public struct LastMessage: LastMessageEntity {
    public var id: String = ""
    
    public var text: String = ""
    
    public var dateSent: Date? = nil
    
    public var userId: String = ""
    
    public var dialogId: String = ""
    
    public init(id: String = "",
                text: String = "",
                dateSent: Date? = nil,
                userId: String = "",
                dialogId: String = "") {
        self.id = id
        self.text = text
        self.dateSent = dateSent
        self.userId = userId
        self.dialogId = dialogId
    }
}
