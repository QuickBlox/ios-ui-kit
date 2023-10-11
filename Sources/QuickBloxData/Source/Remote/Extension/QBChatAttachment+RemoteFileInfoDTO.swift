//
//  QBChatAttachment+RemoteFileInfoDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain

extension QBChatAttachment {
    convenience init(_ value: RemoteFileInfoDTO) {
        self.init()
        id = value.id
        name = value.name
        type = value.type
        url = value.path
    }
}
