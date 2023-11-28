//
//  SendForwardMessage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxLog

public class SendForwardMessage<Item: MessageEntity ,
                         Repo: MessagesRepositoryProtocol>
where Item == Repo.MessageEntityItem {
    private let messageRepo: Repo
    private var message: Item


    public init(message: Item,
                messageRepo: Repo) {
        self.messageRepo = messageRepo
        self.message = message
    }

    public func execute() async throws {
        if message.text.isEmpty {
            let info = "Unable to send empty message."
            throw RepositoryException.incorrectData(info)
        }
        try await messageRepo.send(messageToRemote: message)
    }
}
