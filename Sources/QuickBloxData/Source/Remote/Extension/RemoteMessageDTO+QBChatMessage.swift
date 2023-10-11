//
//  RemoteMessageDTO+QBChatMessage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain
import QuickBloxLog

extension RemoteMessageDTO {
   init (_ value: QBChatMessage) {
       id = value.id ?? UUID().uuidString
       dialogId = value.dialogID ?? ""
       text = value.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
       if text.contains("MediaContentEntity") || text.contains("[Attachment]")  { // FIXME: temporary fix for Android
           text = "[Attachment]"
       }
       recipientId = value.recipientID != 0 ? String(value.recipientID) : ""
       senderId = value.senderID != 0 ? String(value.senderID) : ""
       senderResource = value.senderResource ?? ""
       if let date = value.dateSent {
           self.dateSent = date
       }
       if let params = value.customParameters as? [String: String] {
           customParameters = params
           if let save = params[QBChatMessage.Key.save] {
               saveToHistory = save == "1" ? true : false
           }
           if dialogId.isEmpty, let id = params[QBChatMessage.Key.dialogId] {
               dialogId = id
           }
       }
       
       if let attachments = value.attachments {
           self.filesInfo = attachments.compactMap {
               do {
                   return try RemoteFileInfoDTO($0)
               } catch {
                   prettyLog(error)
                   return nil
               }
           }
       }
       
       delayed = value.delayed
       markable = value.markable
       
       createdAt = value.createdAt ?? dateSent
       updatedAt = value.updatedAt ?? dateSent
       
       eventType = value.type
       type = eventType == .message ? .chat : .event
       
       let current = String(QBSession.current.currentUserID)
       isOwnedByCurrentUser = senderId == current
       if isOwnedByCurrentUser {
           if let ids = value.deliveredIDs {
               isDelivered = ids.map { $0.stringValue }.filter { $0 != current }.isEmpty == false
           }
           if let ids = value.readIDs {
               isReaded = ids.map { $0.stringValue }.filter { $0 != current }.isEmpty == false
           }
       } else {
           if let ids = value.readIDs {
               isReaded = ids.map { $0.stringValue }.contains(current) == true
           }
           if let ids = value.deliveredIDs {
               isDelivered = ids.map { $0.stringValue }.contains(current) == true
           }
       }
   }
   
   static func eventMessage(_ text: String,
                            dialogId: String,
                            type: MessageType,
                            eventType: MessageEventType) -> RemoteMessageDTO {
       var message = RemoteMessageDTO(dialogId: "",
                                      text: text,
                                      senderId: String(QBSession.current.currentUserID),
                                      dateSent: Date(),
                                      eventType: eventType,
                                      type: type)
       message.markable = false
       switch eventType {
       case .create:
           message.customParameters[QBChatMessage.Key.dialogId] = dialogId
           message.customParameters[QBChatMessage.Key.type]
           = QBChatMessage.Value.create
       case .update:
           message.customParameters[QBChatMessage.Key.dialogId] = dialogId
           message.customParameters[QBChatMessage.Key.type]
           = QBChatMessage.Value.update
       case .leave:
           message.customParameters[QBChatMessage.Key.dialogId] = dialogId
           message.customParameters[QBChatMessage.Key.type]
           = QBChatMessage.Value.leave
       case .removed:
           message.customParameters[QBChatMessage.Key.dialogId] = dialogId
           message.customParameters[QBChatMessage.Key.type]
           = QBChatMessage.Value.removed
       case .message:
           message.markable = true
           message.dialogId = dialogId
           message.customParameters[QBChatMessage.Key.save] = "1"
           message.deliveredIds = [message.senderId]
           message.readIds = [message.senderId]
       case .read:
           break
       case .delivered:
           break
       }
       if type == .chat {
           message.dialogId = dialogId
       }
       return message
   }
}
