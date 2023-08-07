//
//  UsersRepositoryTests+Remote.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 05.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
@testable import QuickBloxDomain
@testable import QuickBloxData

//MARK: Utils
extension UsersRepositoryTests {
    private func repository(mock results: [String: Result<[Any], Error>]) -> UsersRepository {
        UsersRepository(remote: RemoteDataSourceMock(results), local: LocalDataSource())
    }
}

//MARK: Get User
extension UsersRepositoryTests {
    typealias MockMethod = RemoteDataSourceMock.MockMethod
    
    func testGetUserFromRemote() async throws {
        let mockResult = [RemoteUserDTO.default]
        let repository =
        repository(mock: [MockMethod.getUser: .success(mockResult)])

        let result = try await repository.get(userFromRemote: Test.stringId)
        XCTAssertEqual(result.id, Test.stringId)
    }

    func testGetUserFromRemoteNotFound() async throws {
        let result: Result<[Any], Error> = .failure(DataSourceException.notFound())
        let repository = repository(mock: [MockMethod.getUser: result])

        await XCTAssertThrowsException(
            try await repository.get(userFromRemote: Test.stringId),
            equelTo: RepositoryException.notFound())
    }
}

//MARK: Get Users
extension UsersRepositoryTests {
    
    func testGetUsersFromRemoteWithIds() async throws {
        let mockEntity = RemoteUsersDTO.default
        let mockResult = [mockEntity]
        let methodResult: Result<[Any], Error> = .success(mockResult)
        let repository =
        repository(mock: [MockMethod.getUsers: methodResult])

        let result = try await repository.get(usersFromRemote: Test.stringIds)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, Test.stringId)
    }

    func testGetUsersFromRemoteNotFound() async throws {
        let methodResult: Result<[Any], Error> =
            .failure(DataSourceException.notFound())
        let repository =
        repository(mock: [MockMethod.getUsers: methodResult])

        await XCTAssertThrowsException(
            try await repository.get(usersFromRemote: [Test.stringId]),
            equelTo: RepositoryException.notFound())
    }
}
