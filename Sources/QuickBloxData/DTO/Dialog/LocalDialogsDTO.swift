//
//  LocalDialogsDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 07.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import QuickBloxDomain

/// This is a DTO model for interactions with  the dialog session or conversation models in local storage.
public struct LocalDialogsDTO {
    var dialogs: [LocalDialogDTO] = []
    var pagination = Pagination()
}
