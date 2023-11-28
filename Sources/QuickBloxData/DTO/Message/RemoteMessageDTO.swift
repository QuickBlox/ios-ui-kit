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
    var id = ""
    var dialogId = ""
    var text = ""
    var recipientId = ""
    var senderId = ""
    var senderResource = ""
    var dateSent = Date(timeIntervalSince1970: 0)
    var customParameters: [String: String] = [:]
    var filesInfo: [RemoteFileInfoDTO] = []
    var delayed = false
    var markable = true
    var createdAt = Date(timeIntervalSince1970: 0)
    var updatedAt = Date(timeIntervalSince1970: 0)
    var deliveredIds: [String] = []
    var readIds: [String] = []
    var isOwnedByCurrentUser = false
    var isReaded = false
    var isDelivered = false
    var eventType: MessageEventType = .message
    var type: MessageType = .chat
    var saveToHistory: Bool = true
    var actionType: MessageAction = .none
    var originSenderName: String = ""
    var originalMessages: [RemoteMessageDTO] = []
    var relatedId = ""
}

public struct RemoteFileInfoDTO: Equatable, Codable {
    var id = ""
    var name = ""
    var type = ""
    var path = ""
    var uid = ""
}
