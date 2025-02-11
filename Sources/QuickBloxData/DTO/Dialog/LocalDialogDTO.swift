//
//  LocalDialogDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// This is a DTO model for interactions with the dialog session or conversation model in local storage.
public struct LocalDialogDTO: Equatable, Identifiable, Hashable {
    public var id = UUID().uuidString
    public var type: DialogType = .private
    public var name = ""
    public var participantsIds: [String] = []
    public var photo = ""
    public var ownerId = ""
    public var isOwnedByCurrentUser = false
    
    public var createdAt = Date()
    public var updatedAt = Date()
    
    public var messages: [LocalMessageDTO] = []
    
    public var lastMessageId = ""
    public var lastMessageText = ""
    public var lastMessageDateSent = Date(timeIntervalSince1970: 0.0)
    public var lastMessageUserId: String = ""
    public var unreadMessagesCount: Int = 0
    public var decrementCounter: Bool = false
    
    public init(id: String = UUID().uuidString,
                type: DialogType = .private,
                name: String = "",
                participantsIds: [String] = [],
                photo: String = "",
                ownerId: String = "",
                isOwnedByCurrentUser: Bool = false,
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                messages: [LocalMessageDTO] = [],
                lastMessageId: String = "",
                lastMessageText: String = "",
                lastMessageDateSent: Date = Date(timeIntervalSince1970: 0.0),
                lastMessageUserId: String = "",
                unreadMessagesCount: Int = 0,
                decrementCounter: Bool = false) {
        self.id = id
        self.type = type
        self.name = name
        self.participantsIds = participantsIds
        self.photo = photo
        self.ownerId = ownerId
        self.isOwnedByCurrentUser = isOwnedByCurrentUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.messages = messages
        self.lastMessageId = lastMessageId
        self.lastMessageText = lastMessageText
        self.lastMessageDateSent = lastMessageDateSent
        self.lastMessageUserId = lastMessageUserId
        self.unreadMessagesCount = unreadMessagesCount
        self.decrementCounter = decrementCounter
    }
}

extension LocalDialogDTO: Dated {
    public var date: Date {
        return updatedAt
    }
}
