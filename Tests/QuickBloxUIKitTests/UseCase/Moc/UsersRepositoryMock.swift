//
//  UsersRepositoryMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData

class UsersRepositoryMock: Mock { }

extension UsersRepositoryMock: UsersRepositoryProtocol {
    
    struct MockMethod {
        static let saveToLocal = "save(userToLocal:)"
        static let saveUsersToLocal = "save(usersToLocal:)"
        static let getFromRemote = "get(userFromRemote:)"
        static let getFromLocal = "get(userFromLocal:)"
        static let getUsersFromRemote = "get(usersFromRemote:)"
        static let getUsersFromLocal = "get(usersFromLocal:)"
    }
    
    func save(userToLocal entity: User) async throws {
        try await mock().callAcyncVoid()
    }
    
    func save(usersToLocal entities: [User]) async throws {
        try await mock().callAcyncVoid()
    }
    
    func get(userFromRemote userId: String) async throws -> User {
        try await mock().callAcyncReturn()
    }
    
    func get(userFromLocal userId: String) async throws -> User {
        try await mock().callAcyncReturn()
    }
    
    func get(usersFromRemote usersIds: [String]) async throws -> [User] {
        try await mock().callAcyncReturn()
    }
    
    func get(usersFromRemote fullName: String) async throws -> [User] {
        try await mock().callAcyncReturn()
    }
    
    func get(usersFromLocal usersIds: [String]) async throws -> [User] {
        try await mock().callAcyncReturn()
    }
}
