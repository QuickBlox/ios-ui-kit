//
//  SendTyping.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog

public class SendTyping<Repo: DialogsRepositoryProtocol> {
    private let dialogId: String
    private let repo: Repo
    
    public init(dialogId: String, repo: Repo) {
        self.dialogId = dialogId
        self.repo = repo
    }
    
    public func execute() async throws {
        do {
            return try await repo.sendTyping(dialogInRemote: dialogId)
        } catch  {
            prettyLog(error)
            throw error
        }
    }
}
