//
//  RemoteOriginalMessageDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 22.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// This is a DTO model for interactions with the original message model in remote storage.
public struct RemoteOriginalMessageDTO: Codable {
    var id: String
    var dialogId: String
    var text: String
    var recipientId: UInt
    var senderId: UInt
    var dateSent: Int64
    var attachments: [RemoteOriginalFileInfoDTO]
    var createdAt: Date
    var updatedAt: Date
    var deliveredIds: [UInt]
    var readIds: [UInt]
    
    public init(id: String,
                dialogId: String = "",
                text: String = "",
                recipientId: UInt = 0,
                senderId: UInt = 0,
                dateSent: Int64,
                attachments: [RemoteOriginalFileInfoDTO] = [],
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                deliveredIds: [UInt] = [],
                readIds: [UInt] = []) {
        self.id = id
        self.dialogId = dialogId
        self.text = text
        self.recipientId = recipientId
        self.senderId = senderId
        self.dateSent = dateSent
        self.attachments = attachments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deliveredIds = deliveredIds
        self.readIds = readIds
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case dialogId = "chat_dialog_id"
        case text = "message"
        case recipientId = "recipient_id"
        case senderId = "sender_id"
        case dateSent = "date_sent"
        case attachments = "attachments"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deliveredIds = "delivered_ids"
        case readIds = "read_ids"
    }
}

public struct RemoteOriginalFileInfoDTO: Codable {
    var id: String = ""
    var name: String = ""
    var type: String = ""
    var url: String = ""
    var uid: String = ""
}

extension RemoteOriginalFileInfoDTO {
    init(_ value: RemoteFileInfoDTO) {
        id = value.id
        name = value.name
        type = value.type
        uid = value.uid
        url = value.path
    }
}

extension RemoteOriginalMessageDTO {
    init(_ value: RemoteMessageDTO) {
        id = value.id
        dialogId = value.dialogId
        text = value.text
        senderId = UInt(value.senderId) ?? 0
        recipientId = UInt(value.recipientId) ?? 0
        dateSent = value.dateSent.timeStampInt
        createdAt = value.createdAt
        updatedAt = value.updatedAt
        
        attachments = value.filesInfo.compactMap{ RemoteOriginalFileInfoDTO($0) }
        
        readIds = value.readIds.compactMap { UInt($0) ?? 0 }
        deliveredIds = value.deliveredIds.compactMap { UInt($0) ?? 0 }
    }
}

private extension Date {
    var timeStampInt: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
