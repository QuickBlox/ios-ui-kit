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
    var id: String = ""
    var name: String = ""
    var avatarPath: String = ""
    var lastRequestAt: Date = Date(timeIntervalSince1970: 0)
    var isCurrent: Bool = false
}
