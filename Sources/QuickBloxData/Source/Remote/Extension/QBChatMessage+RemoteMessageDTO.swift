//
//  QBChatMessage+RemoteMessageDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain

extension QBChatMessage {
    convenience init(_ value: RemoteMessageDTO, toSend: Bool) {
        self.init()
        if toSend == false {
            id = value.id
        }
        dialogID = value.dialogId
        text = value.text
        senderID = (toSend == true ? QBSession.current.currentUserID : UInt(value.senderId)) ?? 0
        recipientID = UInt(value.recipientId) ?? 0
        senderResource = value.senderResource
        dateSent = toSend == true ? Date() : value.dateSent
        customParameters = NSMutableDictionary(dictionary: value.customParameters)
        if value.type == .chat {
            customParameters[QBChatMessage.Key.save] = true
            if value.dialogId.isEmpty,
               let id = customParameters[QBChatMessage.Key.dialogId] as? String {
                dialogID = id
            }
        }
        
        switch value.eventType {
        case .create:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.create
        case .update:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.update
        case .leave:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.leave
        case .removed:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.removed
        case .message:
            break
        case .read:
            break
        case .delivered:
            break
        }
        
        attachments = value.filesInfo.compactMap {
            let attachment = QBChatAttachment($0)
            attachment["uid"] = $0.uid
            return attachment
        }
        
        switch value.actionType {
        case .forward:
            customParameters[QBChatMessage.Key.messageAction]
            = QBChatMessage.ActionValue.forward
            customParameters[QBChatMessage.Key.originSenderName]
            = value.originSenderName
            if value.originalMessages.isEmpty == false {
                customParameters[QBChatMessage.Key.originalMessages]
                = originalMessages(value.originalMessages)
            }
        case .reply:
            customParameters[QBChatMessage.Key.messageAction]
            = QBChatMessage.ActionValue.reply
            customParameters[QBChatMessage.Key.originSenderName]
            = value.originSenderName
            if value.originalMessages.isEmpty == false {
                customParameters[QBChatMessage.Key.originalMessages]
                = originalMessages(value.originalMessages)
            }
        default:
            break
        }
        
        delayed = value.delayed
        markable = value.markable
        
        readIDs = toSend == true ? [NSNumber(value: QBSession.current.currentUserID)]
        : value.readIds.compactMap { NSNumber(value: UInt($0) ?? 0) }
        deliveredIDs = toSend == true ? [NSNumber(value: QBSession.current.currentUserID)]
        : value.deliveredIds.compactMap { NSNumber(value: UInt($0) ?? 0) }
    }
    
    private func originalMessages(_ messages: [RemoteMessageDTO]) -> String {
        let payload = messages.compactMap{ RemoteOriginalMessageDTO($0) }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        jsonEncoder.dateEncodingStrategy = .iso8601
        
        do {
            let encodeOriginalMessages = try jsonEncoder.encode(payload)
            guard let endcodeString = String(data: encodeOriginalMessages, encoding: .utf8) else {
                return ""
            }
            return endcodeString
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}
