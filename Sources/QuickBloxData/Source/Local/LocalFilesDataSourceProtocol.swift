//
//  LocalFilesDataSourceProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain

/// Provides a set of methods for retrieving, saving, and manipulating data files stored locally on a device.
public protocol LocalFilesDataSourceProtocol: ClearLocalDataSourceProtocol {
    
    ///  Store a data file on the local storage.
    /// - Parameter dto: ``LocalFileDTO`` contains properties that describe the characteristics
    /// and content of the data file.
    /// - Returns: ``LocalFileDTO`` contains properties that describe the characteristics
    /// and content of the data file.
    ///
    /// - Throws: ``DataSourceException``**.alreadyExist**
    func createFile(_ dto: LocalFileDTO) async throws -> LocalFileDTO
    
    /// Retrieve a data file from the local storage
    /// - Parameter dto: ``LocalFileDTO`` contains properties necessary to locate a specific file.
    /// - Returns: ``LocalFileDTO`` contains properties that describe the characteristics
    /// and content of the data file.
    ///
    /// - Throws: ``DataSourceException``**.notFound**
    func getFile(_ dto: LocalFileDTO) async throws -> LocalFileDTO
    
    /// Remove a data file from the local storage
    /// - Parameter dto: ``LocalFileDTO`` contains properties necessary for removing a specific file.
    ///
    /// - Throws: ``DataSourceException``**.notFound**
    func deleteFile(_ dto: LocalFileDTO) async throws
}
