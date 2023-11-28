//
//  LocalMessageDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// This is a DTO model for interactions with the message model in local storage.
public struct LocalMessageDTO: Identifiable, Hashable {
    public var id = UUID().uuidString
    var dialogId = ""
    var text = ""
    var senderId = ""
    var dateSent = Date(timeIntervalSince1970: 0)
    var isOwnedByCurrentUser = false
    var fileInfo: LocalFileInfoDTO?
    var deliveredIds: [String] = []
    var readIds: [String] = []
    var isReaded = false
    var isDelivered = false
    var eventType: MessageEventType = .message
    var type: MessageType = .chat
    var actionType: MessageAction = .none
    var originSenderName: String?
    var originalMessages: [LocalMessageDTO] = []
    var relatedId: String = ""
}

extension LocalMessageDTO: Equatable {
    public static func == (lhs: LocalMessageDTO, rhs: LocalMessageDTO) -> Bool {
        return lhs.id == rhs.id && lhs.dialogId == rhs.dialogId
    }
}

extension LocalMessageDTO: Dated {
    var date: Date { dateSent }
}

public struct LocalFileInfoDTO: Equatable, Identifiable, Hashable {
    public var id: String = ""
    var ext: FileExtension = .json
    var name: String = ""
    var path: FilePath = FilePath()
    public var uid: String = ""
}
