//
//  ConnectionRepositoryTests.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 28.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
import Combine

@testable import QuickBloxDomain
@testable import QuickBloxData

    final class ConnectionRepositoryTests: XCTestCase {
    typealias MockMethod = RemoteDataSourceMock.MockMethod
    
    private var cancellables: Set<AnyCancellable>!

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() async throws {
        cancellables = nil
        try await super.tearDown()
    }
}

extension ConnectionRepositoryTests {
    func testConnection() async throws {
        let results: [String: Result<[Any], Error>] =
        [MockMethod.connect: .failure(RemoteDataSourceException.unauthorised())]
        let repository = repository(mock: results)
        await XCTAssertThrowsException(
            try await repository.connect(),
            equelTo: RepositoryException.unauthorised())
    }
}

//MARK: Utils
extension ConnectionRepositoryTests {
    private func repository(
        mock results: [String: Result<[Any], Error>],
        connection: AnyPublisher<ConnectionState, Never> =
        PassthroughSubject<ConnectionState, Never>().eraseToAnyPublisher()
    ) -> ConnectionRepository {
        ConnectionRepository(remote: RemoteDataSourceMock(
            results,
            connectionStatePublisher: connection)
        )
    }
}
