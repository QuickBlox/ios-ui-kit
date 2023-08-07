//
//  UpdateDialog.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

public class UpdateDialog<DialogItem: DialogEntity,
                          UserItem: UserEntity,
                            Repo: DialogsRepositoryProtocol>
where DialogItem == Repo.DialogEntityItem, UserItem == Repo.UsersEntityItem {
    private let repo: Repo
    private let dialog: DialogItem
    private let users: [UserItem]
    
    public init(dialog: DialogItem,
                users: [UserItem],
                repo: Repo) {
        self.dialog = dialog
        self.users = users
        self.repo = repo
    }
    
    public func execute() async throws {
        do {
            let _ = try await repo.update(dialogInRemote: dialog, users: users)
        } catch  {
            throw error
        }
    }
}
