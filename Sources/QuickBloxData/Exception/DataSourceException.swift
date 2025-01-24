//
//  DataSourceException.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// Exceptions that can occur when working with a data source.
public enum DataSourceException: Error, Equatable {
    
    /// Would be thrown when an unexpected error occurs.
    case unexpected(_ description:String = "")
    
    /// Would be thrown when an attempts to create a new record that already exists in the data source.
    case alreadyExist(description:String = "")
    
    /// Would be thrown when an operation is attempted on an record that does not exist in the data source.
    case notFound(description:String = "")
    
    /// Would be thrown when attempting to access and without authentication credentials to do so.
    case unauthorised(description:String = "")
}

extension DataSourceException: LocalizedError {
    public var errorDescription: String? {
        var description:(info: String, reason: String)
        
        switch self {
        case .unexpected(let reason):
            description = ("Unexpected error.", reason)
        case .alreadyExist(let reason):
            description = ("Already exist.", reason)
        case .notFound(let reason):
            description = ("Not found.", reason)
        case .unauthorised(let reason):
            description = ("Unauthorised.", reason)
        }
        
        return description.info + "" + description.reason
    }
}
