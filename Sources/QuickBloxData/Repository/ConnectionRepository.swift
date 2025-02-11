//
//  ConnectionRepository.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Combine

public class ConnectionRepository {
    private var remote: RemoteDataSourceProtocol!
    
    public init(remote: RemoteDataSourceProtocol) {
        self.remote = remote
    }
    
    private init() { }
}

extension ConnectionRepository: ConnectionRepositoryProtocol {
    public func checkConnection() async throws -> ConnectionState {
        do {
           return try await remote.checkConnection()
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func connect() async throws {
        do {
            try await remote.connect()
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func disconnect() async throws {
        do {
            try await remote.disconnect()
        } catch {
            throw try error.repositoryException
        }
    }
    
    public var statePublisher: AnyPublisher<ConnectionState, Never> {
        return remote.connectionPublisher
    }
}
