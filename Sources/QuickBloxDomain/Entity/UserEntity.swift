//
//  UserEntity.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

/// Describes a set of data and functions that represent a user entity.
public protocol UserEntity: Entity {
    /// Display name of the ``UserEntity``.
    var id: String { get }
    var name: String { get set }
    var avatarPath: String { get set }
    var lastRequestAt: Date { get set }
    var isCurrent: Bool { get }
}
