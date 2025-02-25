//
//  MessagesRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

/// Provides a set of methods for getting, saving and manipulating with ``MessageEntity`` items.
public protocol MessagesRepositoryProtocol {
    associatedtype MessageEntityItem: MessageEntity
    associatedtype PaginationItem: PaginationProtocol
    
    /// The initial pagination state used when fetching messages.
    ///
    /// This property provides the default pagination settings, typically starting from the first page
    /// (e.g., `skip = 0`) with a predefined `limit`. It serves as a reference for loading the first set
    /// of items in a paginated request.
    var initialPagination: PaginationItem { get }
    
    /// Send a new message to the remote server.
    /// - Parameter entity: ``MessageEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func send(messageToRemote entity: MessageEntityItem) async throws
    
    /// Save a new message item in the local storage.
    /// - Parameter entity: ``MessageEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.alreadyExist**  if the ``MessageEntity`` item  already exists in the data source with the same **.id**.
    func save(messageToLocal entity: MessageEntityItem) async throws
    
    /// Retrieve an array of messages for dialogs session or conversations from a remote storage.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of  ``DialogEntity``.
    /// - Returns: Array of ``MessageEntity``  items.
    ///
    //FIXME: update docs
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when  ``MessageEntity`` items  is missing from remote storage.
    func get(messagesFromRemote dialogId: String,
             messagesIds: [String],
             page: PaginationItem) async throws -> (messages: [MessageEntityItem],
                                                    page: PaginationItem)
    
    /// Retrieve an array of messages for dialogs session or conversations from a local storage.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of  dialogs session or conversation.
    /// - Returns: Array of ``MessageEntity``  items.
    ///
    //FIXME: Should we return an empty array?
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when  ``MessageEntity`` items  is missing from local storage.
    func get(messagesFromLocal dialogId: String)  async throws -> [MessageEntityItem]
    
    /// Update a message on the remote server.
    /// - Parameter entity: ``MessageEntity`` item that will be updated remotely.
    /// - Returns: a updated ``MessageEntity`` item returned from the server
    ///
    /// - Throws: ``RepositoryException``**.notFound** when wrong format of data, missing required fields, or providing incorrect values.
    /// - Throws: ``RepositoryException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func update(messageInRemote entity: MessageEntityItem) async throws -> MessageEntityItem
    
    /// Update a message in the local storage.
    /// - Parameter entity: ``MessageEntity`` item.
    /// - Returns: ``MessageEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an ``MessageEntity`` item is missing from local storage.
    func update(messageInLocal entity: MessageEntityItem) async throws -> MessageEntityItem
    
    /// Remove a message from a remote storage.
    /// - Parameter entity: ``MessageEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an message item is missing from remote storage.
    func delete(messageFromRemote entity: MessageEntityItem) async throws
    
    /// Remove a message from a local storage
    /// - Parameter entity: ``MessageEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when a ``MessageEntity`` item is missing from local storage.
    func delete(messageFromLocal entity: MessageEntityItem) async throws
    
    /// Read a message in the remote server.
    /// - Parameter entity: ``MessageEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func read(messageInRemote entity: MessageEntityItem) async throws
    
    /// Mark as delivered  a message in the remote server.
    /// - Parameter entity: ``MessageEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func markAsDelivered(messageInRemote entity: MessageEntityItem) async throws
}
