//
//  UploadFile.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
import Foundation

@testable import QuickBloxDomain
@testable import QuickBloxData

final class UploadFileTests: XCTestCase {
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

extension UploadFileTests {
    func testExecute() async throws {
        let fileInfo = FileInfo(id: "testId", ext: .png, name: "file.txt")
        let file = File(id: "testId", info: fileInfo, data: imageData)
    
        repoMock.results[MockMethod.upload] = .success([AcyncMockReturn { file }])
        repoMock.results[MockMethod.save] = .success([AcyncMockReturn { file }])
        
        let useCase = UploadFile(data: imageData,
                                 ext: .png,
                                 name: "file.txt",
                                 repo: repoMock)
        let result = try await useCase.execute()
        XCTAssertEqual(result, file)
    }
}
