//
//  UsersRepository.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 04.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain

/// This is a class that implements the ``UsersRepositoryProtocol`` protocol and contains methods and properties that allow it to interact with the ``UserEntity`` items.
///
/// An object of this class provides access for remote and local storages of ``UserEntity`` items at the time of the application's life cycle.
public class UsersRepository {
    private var remote: RemoteDataSourceProtocol!
    private var local:  LocalDataSourceProtocol!
    
    init(remote: RemoteDataSourceProtocol,
         local: LocalDataSourceProtocol) {
        self.remote = remote
        self.local = local
    }
    
    private init() { }
}

extension User {
    init(_ value: LocalUserDTO) {
        id = value.id
        name = value.name
        avatarPath = value.avatarPath
        lastRequestAt = value.lastRequestAt
        isCurrent = value.isCurrent
    }
    
    init(_ value: RemoteUserDTO) {
        id = value.id
        name = value.name
        avatarPath = value.avatarPath
        lastRequestAt = value.lastRequestAt
        isCurrent = value.isCurrent
    }
}

extension RemoteUserDTO {
    init(_ value: User) {
        id = value.id
        name = value.name
        avatarPath = value.avatarPath
        lastRequestAt = value.lastRequestAt
        isCurrent = value.isCurrent
    }
}

extension LocalUserDTO {
    init(_ value: User) {
        id = value.id
        name = value.name
        avatarPath = value.avatarPath
        lastRequestAt = value.lastRequestAt
        isCurrent = value.isCurrent
    }
}

extension UsersRepository: UsersRepositoryProtocol {
    public func save(userToLocal entity: User) async throws {
        do {
            try await local.save(user: LocalUserDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func save(usersToLocal entities: [User]) async throws {
        do {
            for entity in entities {
                try await local.save(user:  LocalUserDTO(entity))
            }
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(userFromRemote userId: String) async throws -> User {
        do {
            let dto = try await remote.get(user: RemoteUserDTO(id: userId))
            return User(dto)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(userFromLocal userId: String) async throws -> User {
        do {
            let dto = try await local.get(user: LocalUserDTO(id: userId))
            return User(dto)
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(usersFromRemote usersIds: [String]) async throws -> [User] {
        var pagination = Pagination(skip: 0, limit: usersIds.count)
        if usersIds.isEmpty {
            pagination = Pagination(skip: 0, limit: 30)
        } 
        do {
            let withIds = RemoteUsersDTO(ids: usersIds,
                                         pagination: pagination)
            let data = try await remote.get(users: withIds)
            return data.users.map { User($0) }
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(usersFromRemote fullName: String) async throws -> [User] {
        do {
            let pagination = Pagination(skip: 0, limit: 100)
            let withFullName = RemoteUsersDTO(name:fullName, pagination: pagination)
            let data = try await remote.get(users: withFullName)
            return data.users.map { User($0) }
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(usersFromLocal usersIds: [String]) async throws -> [User] {
        //FIXME: Do we need use the TaskGroup for optimization the code?
        
        var users: [User] = []
        for userId in usersIds {
            let withId = LocalUserDTO(id: userId)
            if let dto = try? await local.get(user: withId) {
                users.append(User(dto))
            }
        }
        return users
    }
}
