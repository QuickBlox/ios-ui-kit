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
    public var ids: [String]
    public var name: String
    public var users: [RemoteUserDTO]
    public var pagination: Pagination
    
    public init(ids: [String] = [],
                name: String = "",
                users: [RemoteUserDTO] = [],
                pagination: Pagination = Pagination()) {
        self.ids = ids
        self.name = name
        self.users = users
        self.pagination = pagination
    }
}
