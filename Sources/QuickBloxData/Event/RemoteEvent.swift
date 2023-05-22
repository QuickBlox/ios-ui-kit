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
    case newMessage(_ message: RemoteMessageDTO)
    case history(_ messages: RemoteMessagesDTO)
    
    init(_ message: RemoteMessageDTO) {
        if message.type == .event {
            switch message.eventType {
            case .create:
                self = .create(message.dialogId)
            case .update:
                self = .update(message.dialogId)
            case .leave:
                self = .leave(message.dialogId, byUser: message.isOwnedByCurrentUser)
            case .message:
                self = .newMessage(message)
            }
        } else {
            self = .newMessage(message)
        }
    }
}
