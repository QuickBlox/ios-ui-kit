//
//  RemoteUsersDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import QuickBloxDomain

/// This is a DTO model for interactions with users models in remote storage.
public struct RemoteUsersDTO {
    var ids: [String] = []
    var name: String = ""
    var users: [RemoteUserDTO] = []
    var pagination = Pagination()
}
