//
//  RemoteDataSourceProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Combine

/// Provides a set of methods for getting, saving and manipulating with data stored remoutly on a server.
public protocol RemoteDataSourceProtocol {
    //MARK: Dialogs
    
    /// Create a new dialog on the remote server.
    /// - Parameter dto: the dto for a new dialog item that will be created remotely.
    /// - Returns: a complete dialog's dto item returned from the server.
    ///
    /// - Throws: - ``RemoteDataSourceException``**.incorrectData**
    func create(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO
    
    /// Update a dialog session or conversation from a remote storage.
    /// - Parameter dto: dialog's dto item.
    /// - Returns: an updated dialog's dto item returned from the server.
    ///
    /// - Throws: ``RemoteDataSourceException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    /// - Throws: ``RemoteDataSourceException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func update(dialog dto: RemoteDialogDTO,
                users: [RemoteUserDTO]) async throws -> RemoteDialogDTO
    
    /// Retrieve a dialog session or conversation from a remote storage.
    /// - Parameter dto: dialog's dto item.
    /// - Returns: dialog's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an dialog item is missing from remote storage.
    func get(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO
    
    /// Retrieve all dialogs session or conversations from a remote storage.
    /// - Returns: dialogs dto item.
    func getAllDialogs() async throws -> RemoteDialogsDTO
    func get(dialogs dto: RemoteDialogsDTO) async throws -> RemoteDialogsDTO
    
    /// Remove a dialog session or conversation from a remote storage.
    /// - Parameter dto: dialog's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an dialog item is missing from remote storage.
    /// - Throws: ``RemoteDataSourceException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func delete(dialog dto: RemoteDialogDTO) async throws
    
    /// Subscribe to observe typing for dialog.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when an dialog item is missing from remote storage.
    func subscribeToObserveTyping(dialog dialogId: String) async throws
    
    /// Sends  typing message to participants.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func sendTyping(dialog dialogId: String) async throws
    
    /// Sends stopped typing message to participants.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of dialog.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func sendStopTyping(dialog dialogId: String) async throws
    
    //MARK: Messages
    
    /// Retrieve an array of messages from a remote storage.
    /// - Parameter dto: messages dto item.
    /// - Returns: messages dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an dialog item is missing from remote storage.
    /// - Throws: ``RemoteDataSourceException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func get(messages dto: RemoteMessagesDTO) async throws -> RemoteMessagesDTO
    
    /// Send a message to dialog.
    /// - Parameter dto: message's dto item.
    func send(message dto: RemoteMessageDTO) async throws
    
    /// Update a message text from a remote storage.
    /// - Parameter dto: message's dto item.
    /// - Returns: message's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an message item is missing from remote storage.
    /// - Throws: ``RemoteDataSourceException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func update(message dto: RemoteMessageDTO) async throws -> RemoteMessageDTO
//
    /// Remove a message from a remote storage.
    /// - Parameter dto: message's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an message item is missing from remote storage.
    func delete(message dto: RemoteMessageDTO) async throws
    
    /// Read a message from a remote storage.
    /// - Parameter dto: message's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an message item is missing from remote storage.
    func read(message dto: RemoteMessageDTO) async throws
    
    /// Mark as delivered  a message from a remote storage.
    /// - Parameter dto: message's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an message item is missing from remote storage.
    func markAsDelivered(message dto: RemoteMessageDTO) async throws
    
    //MARK: Users
    
    /// Retrieve a user from a remote storage.
    /// - Parameter dto: user's dto item.
    /// - Returns: user's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an user item is missing from remote storage.
    /// - Throws: ``RemoteDataSourceException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    /// - Throws: ``RemoteDataSourceException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func get(user dto: RemoteUserDTO) async throws -> RemoteUserDTO
    
    /// Retrieve an array of users from a remote storage.
    /// - Parameter dto: users dto item.
    /// - Returns: users dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an user item is missing from remote storage.
    /// - Throws: ``RemoteDataSourceException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func get(users dto: RemoteUsersDTO) async throws -> RemoteUsersDTO
    
    //MARK: Files
    
    /// Create a new file on the remote server.
    /// - Parameter dto: file's dto item.
    /// - Returns: file's dto item.
    ///
    /// - Throws: ``RemoteDataSourceException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func create(file dto: RemoteFileDTO) async throws -> RemoteFileDTO
    
    /// Retrieve a file from a remote storage.
    /// - Parameter dto: file's dto item.
    /// - Returns: file's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an file item is missing from remote storage.
    func get(file dto: RemoteFileDTO) async throws -> RemoteFileDTO
    
    /// Remove a file from a remote storage.
    /// - Parameter dto: file's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when an file item is missing from remote storage.
    /// - Throws: ``RemoteDataSourceException``**.restrictedAccess** when appropriate permissions to perform this operation is absent.
    func delete(file dto: RemoteFileDTO) async throws
    
    //MARK: Events
    
    var eventPublisher: AnyPublisher<RemoteEvent, Never> { get async }
    //MARK: Connection
    
    var connectionPublisher: AnyPublisher<ConnectionState, Never> { get }
    
    func connect() async throws
    
    func disconnect() async throws
    
    func checkConnection() async throws
}
