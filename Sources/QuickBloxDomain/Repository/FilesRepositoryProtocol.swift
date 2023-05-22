//
//  FilesRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// Provides a set of methods for getting, saving and manipulating with ``FileEntity`` items.
public protocol FilesRepositoryProtocol {
    associatedtype FileEntityItem: FileEntity
    
    /// Uploads the specified data and returns a `FileEntityItem` representing the uploaded file.
    ///
    /// - Parameters:
    ///     - data: The data to be uploaded.
    ///     - ext The ``FileExtension`` extension of the file being uploaded.
    ///     - isPublic: A boolean indicating whether the file should be publicly accessible.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** if the data provided is incorrect.
    ///
    /// - Returns: A ``FileEntity`` representing the uploaded file.
    func upload(data: Data,
                ext: FileExtension,
                name: String,
                isPublic: Bool) async throws -> FileEntityItem
    
    /// Saves the provided data to a local file with the specified file type and identifier asynchronously.
    ///
    /// - Parameters:
    ///   - file: An instance of ``FileEntity`` to save to the file.
    ///
    /// - Throws: ``RepositoryException``**.alreadyExist**  if the item with the same **.id** already exists.
    ///
    /// - Returns: An instance of ``FileEntity`` representing the retrieved file.
    func save(file: FileEntityItem) async throws -> FileEntityItem
    
    /// Retrieves a ``FileEntity`` from the specified id asynchronously.
    ///
    /// - Parameters:
    ///   - id: The id of the file to retrieve.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** if the data provided is incorrect.
    /// - Throws: ``RepositoryException``**.notFound**  when  ``FileEntity`` item  is missing from remote storage..
    ///
    /// - Returns: An instance of ``FileEntity`` representing the retrieved file.
    func `get`(fileFromRemote id: String) async throws -> FileEntityItem
    
    /// Retrieves a ``FileEntity`` from the specified id asynchronously.
    ///
    /// - Parameters:
    ///   - id: The id of the file to retrieve.
    ///
    /// - Throws: ``RepositoryException``**.notFound**  when  ``FileEntity`` item  is missing from local storage..
    ///
    /// - Returns: An instance of ``FileEntity`` representing the retrieved file.
    func `get`(fileFromLocal id: String) async throws -> FileEntityItem
    
    /// Deletes a `FileEntityItem` from the specified remote id asynchronously.
    ///
    /// - Parameters:
    ///   - id: The id of the file to delete.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** if the data provided is incorrect.
    /// - Throws: ``RepositoryException``**.notFound** if the ``FileEntity`` is missing from remote storage.
    func delete(fileFromRemote id: String) async throws

    /// Deletes a ``FileEntity`` from the specified local id asynchronously.
    ///
    /// - Parameters:
    ///   - id: The id of the file to delete.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** if the data provided is incorrect.
    /// - Throws: ``RepositoryException``**.notFound** if the ``FileEntity`` is missing from local storage.
    func delete(fileFromLocal id: String) async throws
}
