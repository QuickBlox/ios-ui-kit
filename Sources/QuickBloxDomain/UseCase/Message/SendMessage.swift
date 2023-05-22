//
//  SendMessage.swift.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxLog

public class SendMessage<Item: MessageEntity ,
                         Repo: MessagesRepositoryProtocol>
where Item == Repo.MessageEntityItem {
    private let messageRepo: Repo
    private let message: Item
    
    
    public init(message: Item,
                messageRepo: Repo) {
        self.messageRepo = messageRepo
        self.message = message
    }
    
    public func execute() async throws {
        do {
            if message.text.isEmpty {
                let info = "Unable to send empty message."
                throw RepositoryException.incorrectData(description: info)
            }
            try await messageRepo.send(messageToRemote: message)
        } catch {
            prettyLog(error)
            throw error
        }
    }
}
