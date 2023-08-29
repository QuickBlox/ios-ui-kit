//
//  MessageEntity.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 19.12.2022.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import Foundation

public enum MessageEventType: Codable {
    case create
    case update
    case leave
    case removed
    case message
    case read
    case delivered
}

public enum MessageType: Codable {
    case chat
    case event
    case divider
}

/// Describes a set of data and functions that represent a message entity.
public protocol MessageEntity: Entity {
    associatedtype FileInfoItem: FileInfoEntity
    
    var id: String { get set }
    /// This property hold the actual text that is being exchanged between the user and the system during the conversation.
    var text: String { get set }
    var translatedText: String { get set }
    
    /// The unique ID of the conversation that the message belongs to.
    var dialogId: String { get }
    
    var userId: String { get set }
    var isOwnedByCurrentUser: Bool { get set }
    var date: Date { get set }
    var fileInfo: FileInfoItem? { get set }
    var deliveredIds: [String] { get set }
    var readIds: [String] { get set }
    var isDelivered: Bool { get set }
    var isRead: Bool { get set }
    var eventType: MessageEventType { get set }
    var type: MessageType { get set }
    
    init(id: String, dialogId: String, type: MessageType)
}

extension MessageEntity {
    public init(id: String = UUID().uuidString,
                dialogId: String,
                text: String = "",
                translatedText: String = "",
                userId: String = "",
                date: Date = Date(),
                isOwnedByCurrentUser: Bool = false,
                deliveredIds: [String] = [],
                readIds: [String] = [],
                isDelivered: Bool = false,
                isRead: Bool = false,
                eventType: MessageEventType = .message,
                type: MessageType = .chat,
                fileInfo: FileInfoItem? = nil) {
        self.init(id: id, dialogId: dialogId, type: type)
        self.text = text
        self.translatedText = text
        self.userId = userId
        self.date = date
        self.isOwnedByCurrentUser = isOwnedByCurrentUser
        self.deliveredIds = deliveredIds
        self.readIds = readIds
        self.isDelivered = isDelivered
        self.isRead = isRead
        self.eventType = eventType
        self.fileInfo = fileInfo
    }
}
