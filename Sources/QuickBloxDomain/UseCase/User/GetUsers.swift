//
//  GetUsers.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog


public class GetUsers<User: UserEntity, Pagination: PaginationProtocol, Repo: UsersRepositoryProtocol>
where User == Repo.UserEntityItem, Pagination == Repo.PaginationItem {
    private var name: String = ""
    private var ids: [String] = []
    private let pagination: Pagination
    private let repo: Repo
    
    public init(ids: [String] = [], name: String = "",
                pagination: Pagination,
                repo: Repo) {
        self.ids = ids
        self.name = name
        self.pagination = pagination
        self.repo = repo
    }
    
    public func execute() async throws -> (users: [User], pagination: Pagination) {
        var result: (users: [User], pagination: Pagination) = ([], pagination)
        if name.isEmpty == false {
            result = try await repo.get(usersFromRemote: name, pagination: pagination)
        } else {
            if ids.isEmpty == true {
                result = try await repo.get(usersFromRemote: [], pagination: pagination)
            } else {
                let users = try await repo.get(usersFromLocal: ids)
                let userIds = users.map { $0.id }
                let usersForUpdate = Set(ids).subtracting(Set(userIds))
                if usersForUpdate.isEmpty == false {
                    result = try await repo.get(usersFromRemote: ids,
                                                pagination: pagination)
                } else {
                    return (users: users,
                            pagination: Pagination(skip: 0,
                                                   limit: users.count,
                                                   total: users.count))
                }
            }
        }
        return result
    }
}
