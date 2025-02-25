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
    associatedtype PaginationItem: PaginationProtocol
    
    /// The initial pagination state used when fetching messages.
    ///
    /// This property provides the default pagination settings, typically starting from the first page
    /// (e.g., `skip = 0`) with a predefined `limit`. It serves as a reference for loading the first set
    /// of items in a paginated request.
    var initialPagination: PaginationItem { get }
    
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
    /// - Parameters:
    ///     - usersIds: An array of string unique identifiers that is used to identify specific user items.
    ///     - pagination: An optional ``PaginationItem`` to control paging through results.
    /// - Returns: A tuple containing:
    ///   - `users`: An array of ``UserEntityItem`` objects that match the given name.
    ///   - `pagination`: A ``PaginationItem`` with updated pagination details.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when ``UserEntity`` item is missing from remote storage.
    func get(usersFromRemote usersIds: [String], pagination: PaginationItem?) async throws -> (users: [UserEntityItem], pagination: PaginationItem)
    
    /// Retrieve users from the remote server.
    /// - Parameters:
    ///   - fullName: The full name used to search for user items.
    ///   - pagination: An optional ``PaginationItem`` to control paging through results.
    /// - Returns: A tuple containing:
    ///   - `users`: An array of ``UserEntityItem`` objects that match the given name.
    ///   - `pagination`: A ``PaginationItem`` with updated pagination details.
    ///
    /// - Throws: ``RepositoryException``**.notFound** if no matching ``UserEntityItem`` is found in remote storage.
    func get(usersFromRemote fullName: String, pagination: PaginationItem?) async throws -> (users: [UserEntityItem], pagination: PaginationItem)
    
    /// Retrieve users from the local storage.
    /// - Parameter usersIds: An array of string unique identifiers that is used to identify specific user items.
    /// - Returns: Array of ``UserEntity`` items.
    func get(usersFromLocal usersIds: [String]) async throws -> [UserEntityItem]
}

