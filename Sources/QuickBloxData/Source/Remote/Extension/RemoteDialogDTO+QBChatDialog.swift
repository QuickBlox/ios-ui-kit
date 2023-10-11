//
//  RemoteDialogDTO+QBChatDialog.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain

extension QBChatDialogType {
    var dialogType: DialogType {
        switch self {
        case .publicGroup: return .public
        case .group: return .group
        case .private: return .private
        @unknown default:
            return .unknown
        }
    }
}

extension DialogType {
    var qbDialogType: QBChatDialogType {
        switch self {
        case .public: return .publicGroup
        case .group: return .group
        case .private, .unknown: return .private
        }
    }
}

extension RemoteDialogDTO {
    init(_ value: QBChatDialog) {
        id = value.id ?? UUID().uuidString
        type = value.type.dialogType
        name = value.name ?? ""
        if let occupantIDs = value.occupantIDs {
            participantsIds = occupantIDs
                .map({ $0.stringValue })
        }
        ownerId = String(value.userID)
        isOwnedByCurrentUser = value.userID == QBSession.current.currentUserID
        
        //FIXME: Need implement
        
        createdAt = value.createdAt ?? Date()
        updatedAt = value.updatedAt ?? Date()
        
        if let lastMessageId = value.lastMessageID {
            self.lastMessageId = lastMessageId
            lastMessageText = value.lastMessageText ?? ""
            if lastMessageText.contains("MediaContentEntity") { // FIXME: temporary fix for Android
                lastMessageText = "[Attachment]"
            }
            if value.lastMessageUserID != 0 {
                lastMessageUserId = String(value.lastMessageUserID)
            }
            //FIXME: Need implement
            if let lastMessageDate = value.lastMessageDate {
                lastMessageDateSent = lastMessageDate
            }
            
        }
        photo = value.photo ?? ""
        unreadMessagesCount = Int(value.unreadMessagesCount)
    }
}
