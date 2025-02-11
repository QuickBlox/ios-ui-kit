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
    public var dialogId = ""
    public var ids: [String] = []
    public var messages: [RemoteMessageDTO] = []
    public var pagination = Pagination()
    
    public init(dialogId: String = "",
                ids: [String] = [],
                messages: [RemoteMessageDTO] = [],
                pagination: Pagination = Pagination()) {
        self.dialogId = dialogId
        self.ids = ids
        self.messages = messages
        self.pagination = pagination
    }
}
