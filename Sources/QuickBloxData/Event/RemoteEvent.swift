//
//  RemoteEvent.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//


public enum RemoteEvent {
    case create(_ dialogId: String)
    case update(_ dialogId: String)
    case leave(_ dialogId: String, byUser: Bool)
    case removed(_ dialogId: String)
    case newMessage(_ message: RemoteMessageDTO)
    case history(_ messages: RemoteMessagesDTO)
    case read( _ messageID: String, dialogID: String)
    case delivered( _ messageID: String, dialogID: String)
    case typing( _ userID: UInt, dialogID: String)
    case stopTyping( _ userID: UInt, dialogID: String)
    
    init(_ message: RemoteMessageDTO) {
        if message.type == .event {
            switch message.eventType {
            case .create:
                self = .create(message.dialogId)
            case .update:
                self = .update(message.dialogId)
            case .leave:
                if message.saveToHistory == true {
                    self = .newMessage(message)
                    self = .update(message.dialogId)
                } else {
                    self = .leave(message.dialogId, byUser: message.isOwnedByCurrentUser)
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
