//
//  RemoteDialogsDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import QuickBloxDomain

/// This is a DTO model for interactions with the dialog session or conversation models in remote storage.
public struct RemoteDialogsDTO {
    public var dialogs: [RemoteDialogDTO] = []
    public var usersIds: [String] = []
    public var pagination = Pagination()
    
    public init(dialogs: [RemoteDialogDTO] = [],
                usersIds: [String] = [],
                pagination: Pagination = Pagination()) {
        self.dialogs = dialogs
        self.usersIds = usersIds
        self.pagination = pagination
    }
}
