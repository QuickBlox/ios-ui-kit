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
    var id = ""
    var type: DialogType = .private
    var name = ""
    var participantsIds: [String] = []
    var toDeleteIds: [String] = []
    var toAddIds: [String] = []
    var photo = ""
    var ownerId = ""
    var isOwnedByCurrentUser = false
    
    var createdAt = Date()
    var updatedAt = Date()
    
    var lastMessageId = ""
    var lastMessageText = ""
    var lastMessageDateSent = Date()
    var lastMessageUserId: String = ""
    var unreadMessagesCount: Int = 0
}
