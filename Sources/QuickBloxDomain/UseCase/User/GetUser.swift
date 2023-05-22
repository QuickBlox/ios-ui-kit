//
//  GetUser.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog


public class GetUser<User: UserEntity , Repo: UsersRepositoryProtocol>
where User == Repo.UserEntityItem {
    private let id: String
    private let repo: Repo
    
    public init(id: String, repo: Repo) {
        self.id = id
        self.repo = repo
    }
    
    public func execute() async throws -> User {
        do {
            return try await repo.get(userFromLocal: id)
        } catch RepositoryException.notFound(_) {
            let user = try await repo.get(userFromRemote: id)
            try await repo.save(userToLocal: user)
            return user
        } catch {
            prettyLog(error)
            throw error
        }
    }
}
