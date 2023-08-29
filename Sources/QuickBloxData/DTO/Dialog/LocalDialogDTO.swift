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
    var type: DialogType = .private
    var name = ""
    var participantsIds: [String] = []
    var photo = ""
    var ownerId = ""
    var isOwnedByCurrentUser = false
    
    var createdAt = Date()
    var updatedAt = Date()
    
    var messages: [LocalMessageDTO] = []
    
    var lastMessageId = ""
    var lastMessageText = ""
    var lastMessageDateSent = Date(timeIntervalSince1970: 0.0)
    var lastMessageUserId: String = ""
    var unreadMessagesCount: Int = 0
    var decrementCounter: Bool = false
}

extension LocalDialogDTO: Dated {
    var date: Date {
        return updatedAt
    }
}
