//
//  LocalDataSourceProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.12.2022.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Combine

/// Provides a set of methods for getting, saving and manipulating with data stored locally on a device.
public protocol LocalDataSourceProtocol: ClearLocalDataSourceProtocol {
    //MARK: Dialogs
    var dialogsPublisher: AnyPublisher<[LocalDialogDTO], Never>  { get async }
    var dialogUpdatePublisher: AnyPublisher<String, Never>  { get async }
    
    /// Store a dialog session or conversation to a local storage.
    ///
    /// - Parameter dto: dialog's dto item.
    ///
    /// - Throws: ``DataSourceException``**.alreadyExist**  if the dialog's dto item  already exists in the data source with the same **.id**.
    func save(dialog dto: LocalDialogDTO) async throws
    
    /// Retrieve a dialog session or conversation from a local storage
    /// - Parameter dto: dialog's dto item.
    /// - Returns: dto: dialog's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when a dialog's dto item is missing from local storage.
    func get(dialog dto: LocalDialogDTO) async throws -> LocalDialogDTO
    
    /// Remove a dialog session or conversation from a local storage
    /// - Parameter dto: dialog's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when a dialog's dto item is missing from local storage.
    func delete(dialog dto: LocalDialogDTO) async throws
    
    /// Update a dialog session or conversation from a local storage
    /// - Parameter dto: dialog's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when a dialog's dto item is missing from local storage.
    func update(dialog dto: LocalDialogDTO) async throws
    
    /// Retrieve an array of dialogs session or conversations from a local storage
    /// - Returns: Array of dialog's dto items.
    ///
    func getAllDialogs() async throws -> LocalDialogsDTO
    
    /// Retrieve an array of dialogs session or conversations from a local storage
    /// - Returns: Array of user's dto items.
    ///
    func getAllUsers() async throws -> [LocalUserDTO]
    
    /// Remove all dialogs from storage.
    func removeAllDialogs() async throws
    
    //MARK: Messages
    
    /// Store a message  to a local storage.
    ///
    /// - Parameter dto: message's dto item.
    ///
    /// - Throws: ``DataSourceException``**.alreadyExist**  if the message's dto item  already exists in the data source with the same **.id**.
    func save(message dto: LocalMessageDTO) async throws
    
    /// Retrieve an array of messages for dialogs session or conversations from a local storage.
    /// - Parameter dialogId: string unique identifier that is used to identify a specific item of `dialog entity`.
    /// - Returns: Array of `message entity`  items.
    ///
    func get(messages dto: LocalMessagesDTO) async throws -> LocalMessagesDTO
    
    /// Update a message from a local storage
    /// - Parameter dto: message's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when a message's dto item is missing from local storage.
    func update(message dto: LocalMessageDTO) async throws
    
    /// Remove a message from a local storage
    /// - Parameter dto: message's dto item..
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when a message's dto item is missing from local storage.
    func delete(message dto: LocalMessageDTO) async throws
    
    //MARK: Users
    
    /// Store a user to a local storage.
    ///
    /// - Parameter dto: user's dto item.
    ///
    /// - Throws: ``DataSourceException``**.alreadyExist**  if the user's dto item  already exists in the data source with the same **.id**.
    func save(user dto: LocalUserDTO) async throws
    
    /// Retrieve a user from a local storage
    /// - Parameter dto: user's dto item.
    /// - Returns: user's dto item.
    ///
    /// - Throws: ``DataSourceException``**.notFound**  when a user's dto item is missing from local storage.
    func get(user dto: LocalUserDTO) async throws -> LocalUserDTO
}
