//
//  LocalMessagesDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 07.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//
//

import QuickBloxDomain

/// This is a DTO model for interactions with messages models in local storage.
public struct LocalMessagesDTO {
    var dialogId = ""
    var messages: [LocalMessageDTO] = []
    var pagination = Pagination()
}
