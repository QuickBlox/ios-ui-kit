//
//  DialogEntity.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 19.12.2022.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import Foundation

/// Define a set of predefined options for the type of dialog
public enum DialogType: Codable {
    case `public`
    case group
    case `private`
    case unknown
}

public protocol LastMessageEntity: Entity, Equatable {
    var id: String { get set }
    var text: String { get set }
    var dateSent: Date? { get set }
    var userId: String { get set }
    var dialogId: String { get set }
}

/// Describes a set of data and functions that represent a dialog entity.
public protocol DialogEntity: Entity {
    associatedtype LastMessageItem: LastMessageEntity
    associatedtype MessageItem: MessageEntity
    
    var id: String { get }
    
    var type: DialogType { get }
    
    var ownerId: String { get }
    
    var isOwnedByCurrentUser: Bool { get }
    
    var createdAt: Date { get }
    
    var updatedAt: Date { get set }
    
    var lastMessage: LastMessageItem { get set }
    
    var messages: [MessageItem] { get set }
    
    var participantsIds: [String] { get set }
    
    var name: String { get set }
    
    var photo: String { get set }
    
    var unreadMessagesCount: Int { get set }
    
    var decrementCounter: Bool { get set }
}

extension DialogEntity {
    public var date: Date {
        updatedAt
    }
}
