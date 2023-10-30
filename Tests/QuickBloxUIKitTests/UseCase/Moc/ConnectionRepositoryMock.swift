//
//  ConnectionRepositoryMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 31.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Combine

class ConnectionRepositoryMock: Mock {
    struct MockMethod {
        static let connect = "connect()"
        static let disconnect = "disconnect()"
        static let checkConnection = "checkConnection()"
    }
    
    var publisher: AnyPublisher<ConnectionState, Never>
    
    init(_ publisher: AnyPublisher<ConnectionState, Never> =
         PassthroughSubject<ConnectionState, Never>().eraseToAnyPublisher(),
         results: [String: Result<[Any], Error>] = [:]) {
        self.publisher = publisher
        super.init(results)
    }
}

extension ConnectionRepositoryMock: ConnectionRepositoryProtocol {
    var statePublisher: AnyPublisher<ConnectionState, Never> {
        return publisher
    }
    
    func connect() async throws {
        try await mock().callAcyncVoid()
    }
    
    func disconnect() async throws {
        try await mock().callAcyncVoid()
    }
    
    func checkConnection() async throws -> ConnectionState {
       return try mock().getFirst()
    }
}
