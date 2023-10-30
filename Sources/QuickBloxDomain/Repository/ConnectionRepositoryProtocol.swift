//
//  ConnectionRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 27.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine

public enum ConnectionState: Equatable {
    case unauthorized
    case authorized
    case disconnected(_ error: RepositoryException? = nil)
    case connecting(_ error: RepositoryException? = nil)
    case connected
}

/// Provides a set of methods to establish and track the status of a connection to a remote source.
public protocol ConnectionRepositoryProtocol {
    var statePublisher: AnyPublisher<ConnectionState, Never> { get }
    
    /// Establish a connection with a remote source.
    ///
    ///  - Throws: ``RepositoryException``**.unauthorised**  when the connection is not established.
    func connect() async throws
    
    func disconnect() async throws
    
    /// Update connection state status
    func checkConnection() async throws -> ConnectionState
}
