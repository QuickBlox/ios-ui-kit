//
//  LocalDataSourceTest+User.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 22.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
@testable import QuickBloxData
@testable import QuickBloxDomain


    
//MARK: Save User
extension LocalDataSourceTest {
    func testSaveUserAlreadyExist() async throws {
        let saved = try await createAndSaveUser()
        await XCTAssertThrowsException(
            try await storage.save(user: saved),
            equelTo: DataSourceException.alreadyExist()
        )
    }
}
