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
                    var fileInfo = try RemoteFileInfoDTO($0)
                    if text.contains("MediaContentEntity|"), fileInfo.uid == "" {
                        var separated: [String] = text.components(separatedBy: "|")
                        separated.removeLast()
                        if let uid = separated.last {
                            fileInfo.id = uid
                            fileInfo.uid = uid
                            fileInfo.path = ""
                        }
                    }
                    return fileInfo
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
                                                      date: dateSent,
                                                      actionType: actionType,
                                                      originSenderName: originSenderName)
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
                                   date: Date,
                                   actionType: MessageAction,
                                   originSenderName: String) -> [RemoteMessageDTO] {
        guard let decodedOriginalMessages = jsonString.toJSON() as? [[String: AnyObject]] else { return  [] }
        var originalMessages: [RemoteMessageDTO] = []
        for (i, object) in decodedOriginalMessages.enumerated() {
            let id  = object[RemoteOriginalMessageDTO.CodingKeys.id.stringValue] as? String ?? ""
            let dialogId  = object[RemoteOriginalMessageDTO.CodingKeys.dialogId.stringValue] as? String ?? ""
            let text  = object[RemoteOriginalMessageDTO.CodingKeys.text.stringValue] as? String ?? ""
            let senderId = object[RemoteOriginalMessageDTO.CodingKeys.senderId.stringValue] as? UInt ?? 0
            let dateSent = object[RemoteOriginalMessageDTO.CodingKeys.dateSent.stringValue] as? Int64 ?? 0
            var attachments: [RemoteOriginalFileInfoDTO] = []
            if let decodedAttachments = object[RemoteOriginalMessageDTO.CodingKeys.attachments.stringValue] as? [[String: AnyObject]] {
                for decodedAttachment in decodedAttachments {
                    var fileInfoDTO = RemoteOriginalFileInfoDTO()
                    if let id = decodedAttachment["id"] as? String {
                        fileInfoDTO.id = id
                    } else {
                        if let urlPath = decodedAttachment["url"] as? String,
                           let url = URL(string: urlPath) {
                            fileInfoDTO.id = url.lastPathComponent
                        }
                        if let uid = decodedAttachment["uid"] as? String {
                            fileInfoDTO.id = uid
                        }
                        if let contentType = decodedAttachment["content-type"] as? String {
                            fileInfoDTO.type = contentType
                        }
                    }
                    if let name = decodedAttachment["name"] as? String {
                        fileInfoDTO.name = name
                    }
                    if let type = decodedAttachment["type"] as? String {
                        fileInfoDTO.type = type
                        if type == "audio/mp4" { // fix voice message from Safari
                            fileInfoDTO.type = "audio/mp3"
                            fileInfoDTO.name = fileInfoDTO.name.replacingOccurrences(of: "mp4", with: "mp3")
                        }
                    }
                    if let url = decodedAttachment["url"] as? String {
                        fileInfoDTO.url = url
                    }
                    if let uid = decodedAttachment["uid"] as? String {
                        fileInfoDTO.uid = uid
                    }
                    
                    attachments.append(fileInfoDTO)
                }
            }
            
            let decodedOriginalMessage = RemoteOriginalMessageDTO(id: id,
                                                                  dialogId: dialogId,
                                                                  text: text,
                                                                  senderId: senderId,
                                                                  dateSent: dateSent,
                                                                  attachments: attachments)
            var originalMessage = RemoteMessageDTO(decodedOriginalMessage)
            originalMessage.actionType = actionType
            originalMessage.relatedId = messageId
            originalMessage.dateSent = date
            if i == 0 {
                originalMessage.originSenderName = originSenderName
            }
            
            originalMessages.append(originalMessage)
        }
        return originalMessages
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

extension  String {
func toJSON() -> Any? {
    guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
    return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
}}
