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

public protocol LastMessageEntity: Entity {
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
    
    var updatedAt: Date { get }
    
    var lastMessage: LastMessageItem { get set }
    
    var messages: [MessageItem] { get set }
    
    var participantsIds: [String] { get set }
    
    var name: String { get set }
    
    var photo: String { get set }
    
    var unreadMessagesCount: Int { get set }
    
    var decrementCounter: Bool { get set }
    
    var time: String { get }
    
    var date: Date { get }
}

extension DialogEntity {
    public var date: Date {
        updatedAt
    }
}

extension DialogEntity {
    public var time: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) == true {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDateInYesterday(date) == true {
            return "Yesterday"
        } else if Calendar.autoupdatingCurrent.component(.year, from: date) ==
                  Calendar.autoupdatingCurrent.component(.year, from: Date()) {
            // is current year
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateStyle = .short
        }
        
        return formatter.string(from: date)
    }
}
