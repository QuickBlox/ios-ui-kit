//
//  RemoteUserDTO+QBUUser.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain

extension RemoteUserDTO {
    public init (_ value: QBUUser) {
        id = String(value.id)
        name = value.fullName ?? ""
        if (value.blobID > 0) {
            avatarPath = String(value.blobID)
        } else {
            avatarPath = ""
        }
        lastRequestAt = value.lastRequestAt ??
        Date(timeIntervalSince1970: 0)
        isCurrent = QBSession.current.currentUserID == value.id
    }
}
