//
//  RemoteMessagesDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved..
//

import QuickBloxDomain

/// This is a DTO model for interactions with messages models in remote storage.
public struct RemoteMessagesDTO {
    var dialogId = ""
    var ids: [String] = []
    var messages: [RemoteMessageDTO] = []
    var pagination = Pagination()
}
