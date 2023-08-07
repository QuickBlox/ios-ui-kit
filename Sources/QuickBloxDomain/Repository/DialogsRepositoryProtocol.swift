//
//  DialogsRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine

/// Provides a set of methods for getting, saving and manipulating with ``DialogEntity`` items.
public protocol DialogsRepositoryProtocol {
    associatedtype DialogEntityItem: DialogEntity
    associatedtype UsersEntityItem: UserEntity
    associatedtype PaginationItem: PaginationProtocol
    
    /// Create a new dialog on the remote server.
    /// - Parameter dialog: ``DialogEntity`` item that will be created remotely.
    ///
    /// - Returns: a complete dialog item returned from the server
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func create(dialogInRemote entity: DialogEntityItem) async throws -> DialogEntityItem
    
    /// Save a new dialog item in the local storage
    /// - Parameter entity: ``DialogEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.alreadyExist**  if the ``DialogEntity`` item  already exists in the data source with the same **.id**.
    func save(dialogToLocal entity: DialogEntityItem) async throws
    
    /// Update a dialog on the remote server.
    /// - Parameter dialog: ``DialogEntity`` item that will be updated remotely.
    ///
    /// - Returns: a updated dialog item returned from the server
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    /// - Throws: ``RepositoryException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func update(dialogInRemote entity: DialogEntityItem,
                users: [UsersEntityItem]) async throws -> DialogEntityItem
    
    /// Update a dialog in the local storage.
    /// - Parameter entity: ``DialogEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an ``DialogEntity`` item is missing from local storage.
    func update(dialogInLocal entity: DialogEntityItem) async throws
    
    /// Retrieve a dialog from the remote server.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    /// - Returns: a dialog item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when dialog item is missing from remote storage.
    func get(dialogFromRemote dialogId: String) async throws -> DialogEntityItem
    
    /// Retrieve a dialog from the local storage.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Returns: ``DialogEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an ``DialogEntity`` item is missing from local storage.
    func get(dialogFromLocal dialogId: String) async throws -> DialogEntityItem
    
    /// Delete a dialog from the remote server.
    /// - Parameter entity: ``DialogEntity`` item.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an dialog item is missing from remote storage.
    /// - Throws: ``RepositoryException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func delete(dialogFromRemote entity: DialogEntityItem) async throws
    
    /// Delete a dialog from the local storage.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an ``DialogEntity`` item is missing from local storage.
    func delete(dialogFromLocal dialogId: String) async throws
    
    /// Retrieve dialogs from the remote server.
    /// - Returns: Array of ``DialogEntity`` items.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an dialog item is missing from remote storage.
    func getAllDialogsFromRemote() async throws -> [DialogEntityItem]
    func getDialogsFromRemote(for page: PaginationItem)
    async throws -> (dialogs: [DialogEntityItem],
                     usersIds: [String],
                     page: PaginationItem)
    
    /// Retrieve dialogs  from the local storage.
    /// - Returns: Array of ``DialogEntity`` items.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an dialog item is missing from remote storage.
    func getAllDialogsFromLocal() async throws -> [DialogEntityItem]
    
    /// Remove dialogs  from the local storage.
    func removeAllDialogsFromLocal() async throws
    
    /// Remove data  from the local storage.
    func cleareAll() async throws
    
    /// Subscribe to observe typing for dialog.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an dialog item is missing from remote storage.
    func subscribeToObserveTyping(dialog dialogId: String) async throws
    
    /// Sends  typing message to participants.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func sendTyping(dialogInRemote dialogId: String) async throws
    
    /// Sends stopped typing message to participants.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func sendStopTyping(dialogInRemote dialogId: String) async throws
    
    //FIXME: Add method documentation
    var remoteEventPublisher: AnyPublisher<RemoteDialogEvent<DialogEntityItem.MessageItem>, Never> { get async }
    var localDialogsPublisher: AnyPublisher<[DialogEntityItem], Never> { get async }
}
