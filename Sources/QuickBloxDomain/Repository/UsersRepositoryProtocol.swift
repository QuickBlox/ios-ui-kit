//
//  UsersRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 04.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

/// Provides a set of methods for getting, saving and manipulating with ``UserEntity`` items.
public protocol UsersRepositoryProtocol {
    associatedtype UserEntityItem: UserEntity
    
    /// Save a new user item in the local storage
    /// - Parameter entity: ``UserEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.alreadyExist**  if the ``UserEntity`` item  already exists in the data source with the same **.id**.
    func save(userToLocal entity: UserEntityItem) async throws
    
    /// Save users item in the local storage
    /// - Parameter entities: Array of ``UserEntity`` items.
    ///
    /// - Throws: ``RepositoryException``**.alreadyExist**  if the ``UserEntity`` item  already exists in the data source with the same **.id**.
    func save(usersToLocal entities: [UserEntityItem]) async throws
    
    /// Retrieve a user from the remote server.
    /// - Parameter entity: ``UserEntity`` item.
    /// - Returns: ``UserEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when ``UserEntity`` item is missing from remote storage.
    func get(userFromRemote userId: String) async throws -> UserEntityItem
    
    /// Retrieve a user from the local storage.
    /// - Parameter userId: string unique identifier that is used to identify a specific item of user.
    /// - Returns: ``UserEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when ``UserEntity`` item is missing from local storage.
    func get(userFromLocal userId: String) async throws -> UserEntityItem
    
    /// Retrieve users from the remote server.
    /// - Parameter usersIds: An array of string unique identifiers that is used to identify specific user items.
    /// - Returns: Array of ``UserEntity`` items.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when ``UserEntity`` item is missing from remote storage.
    func get(usersFromRemote usersIds: [String]) async throws -> [UserEntityItem]
    
    /// Retrieve users from the remote server.
    /// - Parameter usersIds: An array of string unique identifiers that is used to identify specific user items.
    /// - Returns: Array of ``UserEntity`` items.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when ``UserEntity`` item is missing from remote storage.
    func get(usersFromRemote fullName: String) async throws -> [UserEntityItem]
    
    /// Retrieve users from the local storage.
    /// - Parameter usersIds: An array of string unique identifiers that is used to identify specific user items.
    /// - Returns: Array of ``UserEntity`` items.
    func get(usersFromLocal usersIds: [String]) async throws -> [UserEntityItem]
}

