//
//  SystemMessages.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 30.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain

extension QBChatMessage {
    var type: MessageEventType {
        if let notification = self.customParameters[Key.type] as? String {
            switch notification {
            case Value.create: return .create
            case Value.update: return .update
            case Value.leave: return .leave
            case Value.removed: return .removed
            default: return .message
            }
        }
        return .message
    }
    
    var actionType: MessageAction {
        if let action = self.customParameters[Key.messageAction] as? String {
            switch action {
            case ActionValue.forward: return .forward
            case ActionValue.reply: return .reply
            default: return .none
            }
        }
        return .none
    }
    
    struct Value {
        static let create = "1"
        static let update = "2"
        static let leave = "3"
        static let removed = "4"
    }
    
    struct ActionValue {
        static let forward = "forward"
        static let reply = "reply"
    }
    
    struct Key {
        static let type = "notification_type"
        static let save = "save_to_history"
        static let dialogId = "dialog_id"
        
        static let messageAction = "qb_message_action"
        static let originSenderName = "origin_sender_name"
        static let originalMessages = "qb_original_messages"
    }
}

extension QBChatMessage {
    static func create(dialog id: String, dialogName: String) throws -> QBChatMessage {
        guard let user = QBSession.current.currentUser,
              user.id != 0,
              let name = user.fullName else {
            let info = "Internal: Invalid or unauthorized current user."
            throw RepositoryException.incorrectData(info)
        }
        
        let message = QBChatMessage()
        
        message.senderID = user.id
        message.dialogID = id
        message.deliveredIDs = [(NSNumber(value: user.id))]
        message.readIDs = [(NSNumber(value: user.id))]
        
        message.dateSent = Date()
        
        message.customParameters[QBChatMessage.Key.save] = true
        message.customParameters[QBChatMessage.Key.type]
        = QBChatMessage.Value.create
        
        let actionMessage = "created the group chat"
        message.text = "\(name) \(actionMessage) \(dialogName)"
        
        return message
    }
    
    static func createSystem(dialog id: String) throws -> QBChatMessage {
        guard let user = QBSession.current.currentUser,
              user.id != 0 else {
            let info = "Internal: Invalid or unauthorized current user."
            throw RepositoryException.incorrectData(info)
        }
        
        let system = QBChatMessage()
        system.senderID = user.id
        system.dialogID = id
        system.customParameters[QBChatMessage.Key.type] = QBChatMessage.Value.create
        system.customParameters[QBChatMessage.Key.dialogId] = id
        system.text = ""
        system.dateSent = Date()
        
        return system
    }
    
    static func event(_ user: QBUUser, leaveDialog id: String) throws -> QBChatMessage {
        let name = user.fullName ?? String(user.id)
        let message = QBChatMessage()
        
        message.senderID = user.id
        message.dialogID = id
        message.deliveredIDs = [(NSNumber(value: user.id))]
        message.readIDs = [(NSNumber(value: user.id))]
        
        message.dateSent = Date()
        
        message.customParameters[QBChatMessage.Key.save] = true
        message.customParameters[QBChatMessage.Key.type]
        = QBChatMessage.Value.leave
        
        message.text = name + " " + "has left"
        
        return message
    }
}
