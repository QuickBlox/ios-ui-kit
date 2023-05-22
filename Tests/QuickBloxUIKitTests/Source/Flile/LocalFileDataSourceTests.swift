//
//  LocalFileDataSourceTests.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 07.02.2023.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import XCTest
@testable import QuickBloxData
@testable import QuickBloxDomain

fileprivate extension LocalFileDTO {
    static var `default` =
    LocalFileDTO(id: LocalFileDataSourceTests.Test.stringId,
                 data: LocalFileDataSourceTests.Test.data,
                 path: FilePath(remote: LocalFileDataSourceTests.Test.path))
    
    static var searching =
    LocalFileDTO(id: LocalFileDataSourceTests.Test.stringId)
}

final class LocalFileDataSourceTests: XCTestCase {
    fileprivate struct Test {
        static let stringId = "1a2b3c4d5e"
        static let type: FileExtension = .png
        static let data = Data("data".utf8)
        static let path = "path"
    }
    
    var source: LocalFilesDataSource!
    
    override func setUp() async throws {
        try await super.setUp()
        source = LocalFilesDataSource()
    }
    
    override func tearDown() async throws {
        try await source.cleareAll()
        source = nil
        try await super.tearDown()
    }
    
    func testCreateGetAndDeleteLocalFile() async throws {
        _ = try await XCTAssertNoThrowsException(
            try await source.createFile(LocalFileDTO.default)
        )
        
        let file = try await XCTAssertNoThrowsException(
            try await self.source.getFile(LocalFileDTO.searching)
        )
        XCTAssertEqual(file.id, LocalFileDTO.default.id)
        XCTAssertNotEqual(file.path, LocalFileDTO.default.path)
        XCTAssertFalse(file.path.remote.isEmpty)
        
        try await XCTAssertNoThrowsException(
            try await source.deleteFile(LocalFileDTO.searching)
        )
        
        await XCTAssertThrowsException(
            try await source.getFile(LocalFileDTO.searching),
            equelTo: DataSourceException.notFound()
        )
    }
    
    func testGetLocalFileNotFound() async throws {
        await XCTAssertThrowsException(
            try await source.getFile(LocalFileDTO.searching),
            equelTo: DataSourceException.notFound()
        )
    }
    
    func testDeleteLocalFileNotFound() async throws {
        await XCTAssertThrowsException(
            try await source.deleteFile(LocalFileDTO.searching),
            equelTo: DataSourceException.notFound()
        )
    }
}
