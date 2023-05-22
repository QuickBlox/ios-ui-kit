//
//  UsersRepositoryTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 04.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
@testable import QuickBloxData

extension User {
    static var `default` =
    User(id: UsersRepositoryTests.Test.stringId, name: "testName")
}

extension RemoteUserDTO {
    static var `default` =
    RemoteUserDTO(id: UsersRepositoryTests.Test.stringId, name: "")
}

extension RemoteUsersDTO {
    static var `default` =
    RemoteUsersDTO(ids: UsersRepositoryTests.Test.stringIds,
                   users: [RemoteUserDTO.default])
    
    static var emptyIds =
    RemoteUsersDTO(users: [RemoteUserDTO.default])
}

final class UsersRepositoryTests: XCTestCase {
    struct Test {
        // id
        static let stringId = "1a2b3c4d5e"
        // ids
        static let stringIds = ["1a2b3c4d5e", "2a3b4c5d6e", "3a4b5c6d7e", "4a5b6c7d8e"]
        
        static let name = "TestNameOfUser"
    }
}
