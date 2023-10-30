//
//  RemoteEvent.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//


public enum RemoteEvent {
    case create(_ dialogId: String, byUser: Bool, message: RemoteMessageDTO)
    case update(_ message: RemoteMessageDTO)
    case leave(_ dialogId: String)
    case userLeave(_ message: RemoteMessageDTO)
    case removed(_ dialogId: String)
    case newMessage(_ message: RemoteMessageDTO)
    case read( _ messageID: String, dialogID: String)
    case delivered( _ messageID: String, dialogID: String)
    case typing( _ userID: UInt, dialogID: String)
    case stopTyping( _ userID: UInt, dialogID: String)
}

extension RemoteEvent {
    init(_ message: RemoteMessageDTO) {
        if message.type == .event || message.type == .system {
            switch message.eventType {
            case .create:
                self = .create(message.dialogId, byUser: message.isOwnedByCurrentUser, message: message)
            case .update:
                self = .update(message)
            case .leave:
                if message.isOwnedByCurrentUser {
                    self = .leave(message.dialogId)
                } else {
                    self = .userLeave(message)
                }
            case .removed:
                self = .removed(message.dialogId)
            case .message:
                self = .newMessage(message)
            case .read:
                self = .read(message.id, dialogID: message.dialogId)
            case .delivered:
                self = .delivered(message.id, dialogID: message.dialogId)
            }
        } else {
            self = .newMessage(message)
        }
    }
}
