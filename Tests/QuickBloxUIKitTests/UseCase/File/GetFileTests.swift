//
//  GetFileTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
import Foundation

@testable import QuickBloxDomain
@testable import QuickBloxData

final class GetFileTests: XCTestCase {
    var repoMock: FilesRepositoryMock!
    
    var imageData: Data!
    
    override func setUp() async throws {
        try await super.setUp()
        
        guard let url = Bundle.module.url(forResource: "testImage",
                                          withExtension: "png") else {
            XCTFail()
            return
        }
        imageData = try Data(contentsOf: url)
        
        repoMock = FilesRepositoryMock()
    }
    
    override func tearDownWithError() throws {
        repoMock = nil
        imageData = nil
        
        try super.tearDownWithError()
    }
    
    typealias MockMethod = FilesRepositoryMock.MockMethod
}

//MARK: get file with id
//TODO: method getLocal in usecase calls more than one, need think how to update mock
// return local dto when save?
extension GetFileTests {
    func testExecuteWithIdWhenLocalNotFound() async throws {
        let fileInfo = FileInfo(id: "testId",
                                ext: .png,
                                name: "test.png",
                                path: FilePath(remote: "tesPath"),
                                uid: "")
        let file = File(id: "testId", info: fileInfo, data: imageData)

        repoMock.results[MockMethod.getLocal] =
            .success([AcyncMockReturn { file }])
        
        let useCase = GetFile(id: "testId",
                              repo: repoMock)
        var result = try await useCase.execute()
        XCTAssertEqual(result, file)
        
        repoMock.results[MockMethod.getLocal] =
            .success([AcyncMockError { RepositoryException.notFound() }])
        
        repoMock.results[MockMethod.getRemote] =
            .success([AcyncMockReturn { file }])
        
        repoMock.results[MockMethod.save] =
            .success([AcyncMockReturn { file }])
        
        result = try await useCase.execute()
        XCTAssertEqual(result, file)
        
        XCTAssertTrue(repoMock.mockMetods.isEmpty)
    }
    
    func testExecuteWithIdWhenLocalPresent() async throws {
        let fileInfo = FileInfo(id: "testId",
                                ext: .png,
                                name: "test.png",
                                path: FilePath(remote: "tesPath"),
                                uid: "")
        let file = File(id: "testId", info: fileInfo, data: imageData)
        repoMock.results[MockMethod.getLocal] =
            .success([AcyncMockReturn { file }])
        
        let useCase = GetFile(id: "testId",
                              repo: repoMock)
        var result = try await useCase.execute()
        XCTAssertEqual(result, file)
        
        repoMock.results[MockMethod.getLocal] =
            .success([AcyncMockReturn { file }])
        
        repoMock.results[MockMethod.getRemote] =
            .success([AcyncMockReturn { file }])
        
        repoMock.results[MockMethod.save] =
            .success([AcyncMockReturn { file }])
        
        result = try await useCase.execute()
        XCTAssertEqual(result, file)
        
        XCTAssertTrue(repoMock.mockMetods.count == 2)
    }
}
