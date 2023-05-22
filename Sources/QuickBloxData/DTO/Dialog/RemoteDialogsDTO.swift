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
    var dialogs: [RemoteDialogDTO] = []
    var usersIds: [String] = []
    var pagination = Pagination()
}
