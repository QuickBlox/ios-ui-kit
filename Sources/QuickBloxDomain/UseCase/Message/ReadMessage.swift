//
//  ReadMessage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxLog

public class ReadMessage<MessageItem: MessageEntity ,
                         MessageRepo: MessagesRepositoryProtocol,
                         DialogItem: DialogEntity,
                         DialogRepo: DialogsRepositoryProtocol>
where MessageItem == MessageRepo.MessageEntityItem,
      DialogItem == DialogRepo.DialogEntityItem {
    private let messageRepo: MessageRepo
    private var message: MessageItem
    private let dialogRepo: DialogRepo
    private var dialog: DialogItem
    
    
    public init(message: MessageItem,
                messageRepo: MessageRepo,
                dialogRepo: DialogRepo,
                dialog: DialogItem) {
        self.messageRepo = messageRepo
        self.message = message
        self.dialogRepo = dialogRepo
        self.dialog = dialog
    }
    
    public func execute() async throws {
        try await messageRepo.read(messageInRemote: message)
        try await dialogRepo.update(dialogInLocal: dialog)
        _ = try await messageRepo.update(messageInLocal: message)
    }
}
