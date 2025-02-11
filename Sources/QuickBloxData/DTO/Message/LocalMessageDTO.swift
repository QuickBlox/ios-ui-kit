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
    public var dialogId = ""
    public var text = ""
    public var senderId = ""
    public var dateSent = Date(timeIntervalSince1970: 0)
    public var isOwnedByCurrentUser = false
    public var fileInfo: LocalFileInfoDTO?
    public var deliveredIds: [String] = []
    public var readIds: [String] = []
    public var isReaded = false
    public var isDelivered = false
    public var eventType: MessageEventType = .message
    public var type: MessageType = .chat
    public var actionType: MessageAction = .none
    public var originSenderName: String?
    public var originalMessages: [LocalMessageDTO] = []
    public var relatedId: String = ""
    
    public init () {}
}

extension LocalMessageDTO: Equatable {
    public static func == (lhs: LocalMessageDTO, rhs: LocalMessageDTO) -> Bool {
        return lhs.id == rhs.id && lhs.dialogId == rhs.dialogId
    }
}

extension LocalMessageDTO: Dated {
    public var date: Date { dateSent }
}

public struct LocalFileInfoDTO: Equatable, Identifiable, Hashable {
    public var id: String = ""
    public var ext: FileExtension = .json
    public var name: String = ""
    public var path: FilePath = FilePath()
    public var uid: String = ""
    
    public init () {}
}
