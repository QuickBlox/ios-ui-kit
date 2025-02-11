//
//  RemoteMessageDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// This is a DTO model for interactions with the message model in remote storage.
public struct RemoteMessageDTO: Equatable {
    public var id: String
    public var dialogId: String
    public var text: String
    public var recipientId: String
    public var senderId: String
    public var senderResource: String
    public var dateSent: Date
    public var customParameters: [String: String]
    public var filesInfo: [RemoteFileInfoDTO]
    public var delayed: Bool
    public var markable: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var deliveredIds: [String]
    public var readIds: [String]
    public var isOwnedByCurrentUser: Bool
    public var isReaded: Bool
    public var isDelivered: Bool
    public var eventType: MessageEventType
    public var type: MessageType
    public var saveToHistory: Bool
    public var actionType: MessageAction
    public var originSenderName: String
    public var originalMessages: [RemoteMessageDTO]
    public var relatedId: String
    
    public init(id: String = "",
                dialogId: String = "",
                text: String = "",
                recipientId: String = "",
                senderId: String = "",
                senderResource: String = "",
                dateSent: Date = Date(timeIntervalSince1970: 0),
                customParameters: [String : String] = [:],
                filesInfo: [RemoteFileInfoDTO] = [],
                delayed: Bool = false,
                markable: Bool = true,
                createdAt: Date = Date(timeIntervalSince1970: 0),
                updatedAt: Date = Date(timeIntervalSince1970: 0),
                deliveredIds: [String] = [],
                readIds: [String] = [],
                isOwnedByCurrentUser: Bool = false,
                isReaded: Bool = false,
                isDelivered: Bool = false,
                eventType: MessageEventType = .message,
                type: MessageType = .chat,
                saveToHistory: Bool = true,
                actionType: MessageAction = .none,
                originSenderName: String = "",
                originalMessages: [RemoteMessageDTO] = [],
                relatedId: String = "") {
        self.id = id
        self.dialogId = dialogId
        self.text = text
        self.recipientId = recipientId
        self.senderId = senderId
        self.senderResource = senderResource
        self.dateSent = dateSent
        self.customParameters = customParameters
        self.filesInfo = filesInfo
        self.delayed = delayed
        self.markable = markable
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deliveredIds = deliveredIds
        self.readIds = readIds
        self.isOwnedByCurrentUser = isOwnedByCurrentUser
        self.isReaded = isReaded
        self.isDelivered = isDelivered
        self.eventType = eventType
        self.type = type
        self.saveToHistory = saveToHistory
        self.actionType = actionType
        self.originSenderName = originSenderName
        self.originalMessages = originalMessages
        self.relatedId = relatedId
    }
}

public struct RemoteFileInfoDTO: Equatable, Codable {
    public var id: String
    public var name: String
    public var type: String
    public var path: String
    public var uid: String
    
    public init(id: String = "",
                name: String = "",
                type: String = "",
                path: String = "",
                uid: String = "") {
        self.id = id
        self.name = name
        self.type = type
        self.path = path
        self.uid = uid
    }
}
