//
//  Error+RepositoryException.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain

extension Error {
    var repositoryException: RepositoryException {
        get throws {
            switch self {
            case let exception as DataSourceException:
                return from(data: exception)
            case let exception as RemoteDataSourceException:
                return from(remoteData: exception)
            case let exception as MapperException:
                return convertFrom(mapper: exception)
            default:
                return RepositoryException.unexpected(self.localizedDescription)
            }
        }
    }
    
    private func from(data exception: DataSourceException) -> RepositoryException {
        switch exception {
        case .unexpected(let info):
            return RepositoryException.unexpected(info)
        case .alreadyExist(description: let info):
            return RepositoryException.alreadyExist(description: info)
        case .notFound(description: let info):
            return RepositoryException.notFound(description: info)
        }
    }
    
    private func from(remoteData exception: RemoteDataSourceException) -> RepositoryException  {
        switch exception {
        case .unauthorised( let info):
            return RepositoryException.unauthorised( info)
        case .incorrectData(description: let info):
            return RepositoryException.incorrectData(info)
        case .restrictedAccess(description: let info):
            return RepositoryException.restrictedAccess(description: info)
        case .connectionFailed(description: let info):
            return RepositoryException.connectionFailed(description: info)
        }
    }
    
    fileprivate func convertFrom(mapper exception: MapperException) -> RepositoryException {
        switch exception {
        case .unexpected(let info):
            return RepositoryException.unexpected(info)
        case .incorrectData(description: let info):
            return RepositoryException.incorrectData(info)
        }
    }
}
