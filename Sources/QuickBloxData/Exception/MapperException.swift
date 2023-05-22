//
//  MapperException.swift
//  QuickBloxUIKit
//  
//  Created by Injoit on 24.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

public enum MapperException: Error {
    /// Would be thrown when an unexpected error occurs.
    case unexpected(_ description:String = "")
    /// Would be thrown when mapping the wrong format of data, missing required fields, or providing incorrect values.
    case incorrectData(description: String = "")
}

extension MapperException: LocalizedError {
    public var errorDescription: String? {
        var description:(info: String, reason: String)
        
        switch self {
        case .unexpected(let reason):
            description = ("Unexpected error.", reason)
        case .incorrectData(let reason):
            description = ("Incorrect data.", reason)
        }
        
        return description.info + "" + description.reason
    }
}
