//
//  UsersRepositoryTests+Local.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 04.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest

@testable import QuickBloxDomain
@testable import QuickBloxData

//MARK: Utils
extension UsersRepositoryTests {
     private func repository(mock result: Result<[Any], Error>) -> UsersRepository {
         UsersRepository(remote: RemoteDataSource(), local: LocalDataSourceMock(result))
    }
}

//MARK: Save User
extension UsersRepositoryTests {
    func testSaveUserInLocal() async throws {
        let result = [LocalUserDTO.default]
        let repository = repository(mock: .success(result))

        let entity = User.default
        try await repository.save(userToLocal: entity)
        let user = try await repository.get(userFromLocal: Test.stringId)
        XCTAssertEqual(user.id, entity.id)
    }
    
    func testSaveUserInLocalAlreadyExist() async throws {
        let repository = repository(mock: .failure(DataSourceException.alreadyExist()))
        
        await XCTAssertThrowsException(
            try await repository.save(userToLocal: User.default),
            equelTo: RepositoryException.alreadyExist())
    }
}

//MARK: Save/Get Users
extension UsersRepositoryTests {
    func testSaveGetUsersInLocal() async throws {
        let result = [LocalUserDTO.default]
        let repository = repository(mock: .success(result))

        let entity = User.default
        try await repository.save(usersToLocal: [entity])
        let users = try await repository.get(usersFromLocal: [Test.stringId])
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].id, entity.id)
    }
    
    func testGetUsersInLocalEmptyStorage() async throws {
        let repository = repository(mock: .success([]))
        
        let users = try await XCTAssertNoThrowsException(
            try await repository.get(usersFromLocal: [Test.stringId])
        )
        XCTAssertEqual(users.count, 0)
    }
}

//MARK: Get User
extension UsersRepositoryTests {
    func testGetUserInLocal() async throws {
        let result = [LocalUserDTO.default]
        let repository = repository(mock: .success(result))

        let entity = User.default
        try await repository.save(userToLocal: entity)
        let user = try await repository.get(userFromLocal: Test.stringId)
        XCTAssertEqual(user.id, entity.id)
    }
    
    func testGetUserInLocalNotFound()  async throws {
        let repository = repository(mock: .failure(DataSourceException.notFound()))
        
        await XCTAssertThrowsException(
            try await repository.get(userFromLocal: Test.stringId),
            equelTo: RepositoryException.notFound())
    }
}
