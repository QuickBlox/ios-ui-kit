//
//  RemoteDataSourceException.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 18.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// Exceptions that can occur when working with a remote data source.
public enum RemoteDataSourceException: Error, Equatable {
    
    /// Would be thrown when attempting to access the a remote data source and without authentication credentials to do so.
    case unauthorised(_ description: String = "")
    
    /// Would be thrown when sending the wrong format of data, missing required fields, or providing incorrect values.
    case incorrectData(_ description: String = "")
    
    /// Would be thrown when there are no necessary permissions to access the requested resource.
    case restrictedAccess(description: String = "")
    
    /// Would be thrown when the data source is not available, if the network connection is lost, or if there is a problem with the connection settings.
    case connectionFailed(description: String = "")
}

extension RemoteDataSourceException: LocalizedError {
    public var errorDescription: String? {
        var description:(info: String, reason: String)
        
        switch self {
        case .unauthorised(let reason):
            description = ("Unauthorised.", reason)
        case .incorrectData(let reason):
            description = ("Incorrect data.", reason)
        case .restrictedAccess(let reason):
            description = ("Restricted access.", reason)
        case .connectionFailed(let reason):
            description = ("Connection failed.", reason)
        }
        
        return description.info + "" + description.reason
    }
}
