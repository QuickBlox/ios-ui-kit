//
//  User.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 22.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// Contain methods and properties that describe a User item.
///
/// This is an active model that conforms to the ``UserEntity`` protocol.
public struct User: UserEntity {
    public let id: String
    
    /// Display name of the User.
    ///
    /// > Note: Returns an empty string by default
    public var name: String = ""
    public var avatarPath: String = ""
    public var lastRequestAt: Date = Date(timeIntervalSince1970: 0)
    
    public var isCurrent: Bool = false
    
    public init(id: String,
                name: String,
                isCurrent: Bool = false,
                lastRequestAt: Date =
                Date(timeIntervalSince1970: 0)) {
        self.id = id
        self.name = name
        self.isCurrent = isCurrent
        self.lastRequestAt = lastRequestAt
    }
}
