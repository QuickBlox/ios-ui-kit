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
        actionType = value.actionType
        
        let originSenderName: String = value.customParameters[QBChatMessage.Key.originSenderName] as? String ?? ""
        
        if let originalMessages = value.customParameters[QBChatMessage.Key.originalMessages] as? String {
            self.originalMessages = originaldMessages(originalMessages, messageId: id,
                                                      dateSent: dateSent,
                                                      actionType: actionType,
                                                      originSenderName: originSenderName)
        }
        
        if self.originalMessages.isEmpty == true {
            actionType = .none
        }
        
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
    
    private func originaldMessages(_ jsonString: String,
                                   messageId: String,
                                   dateSent: Date,
                                   actionType: MessageAction,
                                   originSenderName: String) -> [RemoteMessageDTO] {
        guard let data = jsonString.data(using: .utf8) else { return [] }
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        do {
            let decodedOriginalMessages = try jsonDecoder.decode([RemoteOriginalMessageDTO].self, from: data)
            var originalMessages: [RemoteMessageDTO] = []
            for (i, decodedOriginalMessage) in decodedOriginalMessages.enumerated() {
                var originalMessage = RemoteMessageDTO(decodedOriginalMessage)
                originalMessage.actionType = actionType
                originalMessage.relatedId = messageId
                originalMessage.dateSent = dateSent
                if i == 0 {
                    originalMessage.originSenderName = originSenderName
                }
                originalMessages.append(originalMessage)
            }
            return originalMessages
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
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

extension RemoteMessageDTO {
    init(_ value: RemoteOriginalMessageDTO) {
        id = value.id
        dialogId = value.dialogId
        text = value.text
        senderId = value.senderId != 0 ? String(value.senderId) : ""
        recipientId = value.recipientId != 0 ? String(value.recipientId) : ""
        dateSent = value.dateSent.dateTimeIntervalSince1970
        createdAt = value.createdAt
        updatedAt = value.updatedAt
        
        if value.attachments.isEmpty == false {
            self.filesInfo = value.attachments.compactMap{ RemoteFileInfoDTO($0) }
        }
        
        createdAt = dateSent
        updatedAt = dateSent
        
        let current = String(QBSession.current.currentUserID)
        isOwnedByCurrentUser = senderId == current
        isDelivered = true
        isReaded = true
    }
}

extension RemoteFileInfoDTO {
    init(_ value: RemoteOriginalFileInfoDTO) {
        id = value.id
        name = value.name
        type = value.type
        uid = value.uid
        path = value.url
    }
}

private extension Int64 {
    var dateTimeIntervalSince1970: Date {
        let timestampInSeconds = TimeInterval(self) / 1000.0
        return Date(timeIntervalSince1970: timestampInSeconds)
    }
}
