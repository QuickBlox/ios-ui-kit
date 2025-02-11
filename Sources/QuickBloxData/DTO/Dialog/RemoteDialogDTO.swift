//
//  RemoteDialogDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// This is a DTO model for interactions with the dialog session or conversation model in remote storage.
public struct RemoteDialogDTO: Equatable {
    public var id = ""
    public var type: DialogType = .private
    public var name = ""
    public var participantsIds: [String] = []
    public var toDeleteIds: [String] = []
    public var toAddIds: [String] = []
    public var photo = ""
    public var ownerId = ""
    public var isOwnedByCurrentUser = false
    
    public var createdAt = Date()
    public var updatedAt = Date()
    
    public var lastMessageId = ""
    public var lastMessageText = ""
    public var lastMessageDateSent = Date()
    public var lastMessageUserId: String = ""
    public var unreadMessagesCount: Int = 0
    
    public init(id: String = "",
                type: DialogType = .private,
                name: String = "",
                participantsIds: [String] = [],
                toDeleteIds: [String] = [],
                toAddIds: [String] = [],
                photo: String = "",
                ownerId: String = "",
                isOwnedByCurrentUser: Bool = false,
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                lastMessageId: String = "",
                lastMessageText: String = "",
                lastMessageDateSent: Date = Date(),
                lastMessageUserId: String = "",
                unreadMessagesCount: Int = 0) {
        self.id = id
        self.type = type
        self.name = name
        self.participantsIds = participantsIds
        self.toDeleteIds = toDeleteIds
        self.toAddIds = toAddIds
        self.photo = photo
        self.ownerId = ownerId
        self.isOwnedByCurrentUser = isOwnedByCurrentUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessageId = lastMessageId
        self.lastMessageText = lastMessageText
        self.lastMessageDateSent = lastMessageDateSent
        self.lastMessageUserId = lastMessageUserId
        self.unreadMessagesCount = unreadMessagesCount
    }
}
