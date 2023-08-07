//
//  GetUsers.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog


public class GetUsers<User: UserEntity , Repo: UsersRepositoryProtocol>
where User == Repo.UserEntityItem {
    private var name: String = ""
    private var ids: [String] = []
    private let repo: Repo
    
    public init(ids: [String] = [], name: String = "", repo: Repo) {
        self.ids = ids
        self.name = name
        self.repo = repo
    }
    
    public func execute() async throws -> [User] {
        var users: [User]
        if name.isEmpty == false {
            users = try await repo.get(usersFromRemote: name)
        } else {
            users = try await repo.get(usersFromRemote: ids)
        }
        return users
    }
}
