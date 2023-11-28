//
//  GetMessage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 29.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog


public class GetMessage<Message: MessageEntity,
                        Pagination: PaginationProtocol,
                        Repo: MessagesRepositoryProtocol>
where Message == Repo.MessageEntityItem, Pagination == Repo.PaginationItem {
    private let id: String
    private let dialogId: String
    private let repo: Repo

    public init(id: String, dialogId: String, repo: Repo) {
        self.id = id
        self.dialogId = dialogId
        self.repo = repo
    }

    public func execute() async throws -> Message {
        do {
            let messages = try await repo.get(messagesFromLocal: dialogId)
            for message in messages {
                if message.id == id { return message }
            }
            throw RepositoryException.notFound()
        } catch RepositoryException.notFound(_) {
            let result = try await repo.get(messagesFromRemote: dialogId,
                                          messagesIds: [id],
                                              page: Pagination(skip: 0))
            for message in result.messages {
                if message.id == id {
                    try await repo.save(messageToLocal: message)
                    return message
                }
            }
            throw RepositoryException.notFound()
        }
    }
}
