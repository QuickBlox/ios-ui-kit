//
//  RepositoryException.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 19.12.2022.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import Foundation

public enum RepositoryException: Error, Equatable {
    
    /// Would be thrown when an unexpected error occurs.
    case unexpected(_ description:String = "")
    
    /// Would be thrown when an attempts to create a new entity that already exists in the data source.
    case alreadyExist(description:String = "")
    
    /// Would be thrown when an operation is attempted on an entity that does not exist in the data source.
    case notFound(description:String = "")
    
    /// Would be thrown when attempting to access the a remote data source and without authentication credentials to do so.
    case unauthorised( String = "")
    
    /// Would be thrown when sending the wrong format of data, missing required fields, or providing incorrect values.
    case incorrectData(description: String = "")
    
    /// Would be thrown when there are no necessary permissions to access the requested resource.
    case restrictedAccess(description: String = "")
    
    /// Would be thrown when the data source is not available, if the network connection is lost, or if there is a problem with the connection settings.
    case connectionFailed(description: String = "")
}

extension RepositoryException: LocalizedError {
    public var errorDescription: String? {
        var description:(info: String, reason: String)
        
        switch self {
        case .unexpected(let reason):
            description = ("Unexpected error.", reason)
        case .alreadyExist(let reason):
            description = ("Entity already exist.", reason)
        case .notFound(let reason):
            description = ("Entity not found.", reason)
        case .unauthorised(let reason):
            description = ("Unauthorised.", reason)
        case .incorrectData(let reason):
            description = ("Incorrect data.", reason)
        case .restrictedAccess(let reason):
            description = ("Restricted access.", reason)
        case .connectionFailed(let reason):
            description = ("Connection failed.", reason)
        }
        
        return description.reason.isEmpty ? description.info : description.reason
    }
}
