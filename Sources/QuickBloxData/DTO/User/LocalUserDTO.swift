//
//  LocalUserDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved
//

import QuickBloxDomain
import Foundation

/// This is a DTO model for interactions with the user in local storage.
public struct LocalUserDTO: Equatable {
    public var id: String
    public var name: String
    public var avatarPath: String
    public var lastRequestAt: Date
    public var isCurrent: Bool
    
    public init(id: String = "",
                name: String = "",
                avatarPath: String = "",
                lastRequestAt: Date = Date(timeIntervalSince1970: 0),
                isCurrent: Bool = false) {
        self.id = id
        self.name = name
        self.avatarPath = avatarPath
        self.lastRequestAt = lastRequestAt
        self.isCurrent = isCurrent
    }
}
