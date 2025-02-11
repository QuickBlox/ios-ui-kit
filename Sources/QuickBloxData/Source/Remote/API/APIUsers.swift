//
//  APIUsers.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox

public struct APIUsers {
    public func `get`(with id: String) async throws -> QBUUser {
        guard let id = UInt(id) else {
            let info = "Incorrect user id: \(id)"
            throw RemoteDataSourceException.incorrectData(info)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.user(withID: id) { _, user in
                continuation.resume(returning: user)
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
    
    public func `get`(with ids: [String], page pagination: Pagination)
    async throws -> (users: [QBUUser], pagination: Pagination) {
        return try await withCheckedThrowingContinuation { continuation in
            let page = QBGeneralResponsePage(pagination)
            QBRequest.users(withIDs: ids, page: page) { _, page, users in
                continuation.resume(returning: (users, Pagination(page)))
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
    
    public func `get`(for page: Pagination)
    async throws -> (users: [QBUUser], pagination: Pagination) {
        let extendedRequest: [String: String] =
        ["order": "desc date last_request_at"]
        
        return try await withCheckedThrowingContinuation { continuation in
            let page = QBGeneralResponsePage(page)
            QBRequest.users(withExtendedRequest: extendedRequest, page: page) {
                _, page, users in
                continuation.resume(returning: (users, Pagination(page)))
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
    
    public func `get`(with name: String, page pagination: Pagination)
    async throws -> (users: [QBUUser], pagination: Pagination) {
        return try await withCheckedThrowingContinuation { continuation in
            let page = QBGeneralResponsePage(pagination)
            QBRequest.users(withFullName: name, page: page) {
                _, page, users in
                continuation.resume(returning: (users, Pagination(page)))
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }

        }
    }
}

