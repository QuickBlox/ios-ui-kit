//
//  RemoveFileTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest

@testable import QuickBloxDomain
@testable import QuickBloxData

final class RemoveFileTests: XCTestCase {
    var repoMock: FilesRepositoryMock!
    
    override func setUp() async throws {
        try await super.setUp()
        
        repoMock = FilesRepositoryMock()
    }
    
    override func tearDownWithError() throws {
        repoMock = nil
        
        try super.tearDownWithError()
    }
    
    typealias MockMethod = FilesRepositoryMock.MockMethod
}

extension RemoveFileTests {
    func testExecuteWithId() async throws {
        repoMock.results[MockMethod.deleteLocal] =
            .success([AcyncMockError { RepositoryException.notFound() }])
        
        repoMock.results[MockMethod.deleteRemote] =
            .success([AcyncMockVoid { }])
        
        let useCase = RemoveFile(id: "testId",
                              repo: repoMock)
        
        try await  XCTAssertNoThrowsException( try await useCase.execute() )
    }
}
