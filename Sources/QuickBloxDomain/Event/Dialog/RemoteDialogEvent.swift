//
//  RemoteDialogEvent.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//


public enum RemoteDialogEvent<MessageItem: MessageEntity> {
    case create(_ dialogId: String)
    case update(_ dialogId: String)
    case leave(_ dialogId: String, byUser: Bool)
    case newMessage(_ message: MessageItem)
    case history(_ dialogId: String, _ messages: [MessageItem])
}
