//
//  FilesRepositoryTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
@testable import QuickBloxData
@testable import QuickBloxDomain

class FilesRepositoryTests: XCTestCase {
    
    struct Test {
        static let id = "testId"
        static let path = "testPath"
    }
    
    var repository: FilesRepository!
    var remoteDataSourceMock: RemoteDataSourceMock!
    var localDataSourceMock: LocalFilesDataSourceMoc!
    
    var imageData: Data!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        remoteDataSourceMock = RemoteDataSourceMock()
        localDataSourceMock = LocalFilesDataSourceMoc()
        repository = FilesRepository(remote: remoteDataSourceMock,
                                     local: localDataSourceMock)
        
        guard let url = Bundle.module.url(forResource: "testImage",
                                          withExtension: "png") else {
            XCTFail()
            return
        }
        imageData = try Data(contentsOf: url)
    }
    
    override func tearDownWithError() throws {
        remoteDataSourceMock = nil
        localDataSourceMock = nil
        repository = nil
        imageData = nil
        
        try super.tearDownWithError()
    }
    
    typealias LocalMethod = LocalFilesDataSourceMoc.MockMethod
    typealias RemoteMethod = RemoteDataSourceMock.MockMethod
}

//MARK: upload
extension FilesRepositoryTests {
    func testUpload() async throws {
        let remoteFileDTO = RemoteFileDTO(id: Test.id,
                                          ext: .png,
                                          data: imageData,
                                          public: false)
        
        remoteDataSourceMock.results[RemoteMethod.createFile] =
            .success([AcyncMockReturn { remoteFileDTO }])
        let result = try await repository.upload(data: imageData,
                                                 ext: .png,
                                                 name: "test_ios.png")
        
        XCTAssertEqual(result.data, imageData)
    }
    
    func testUploadIncorrectData() async throws {
        remoteDataSourceMock.results[RemoteMethod.createFile] =
            .success([AcyncMockError {
                return RemoteDataSourceException.incorrectData()
            }])
        
        await XCTAssertThrowsException(
            try await repository.upload(data: imageData,
                                        ext: .png,
                                        name: "test_ios.png"),
            equelTo: RepositoryException.incorrectData()
        )
    }
}

//MARK: get
extension FilesRepositoryTests {
    func testGetFromLocal() async throws {
        let localFileDTO = LocalFileDTO(id: Test.id,
                                        ext: .png,
                                        data: imageData)
        
        localDataSourceMock.results[LocalMethod.getFile] =
            .success([AcyncMockReturn { localFileDTO }])
        
        let result = try await repository.get(fileFromLocal: Test.id)
        
        XCTAssertEqual(result.data, imageData)
    }
    
    func testGetFromLocalNotFound() async throws {
        localDataSourceMock.results[LocalMethod.getFile] =
            .success([AcyncMockError {
                return DataSourceException.notFound()
            }])
        
        await XCTAssertThrowsException(
            try await repository.get(fileFromLocal: Test.id),
            equelTo: RepositoryException.notFound()
        )
    }
    
    func testGetFromRemote() async throws {
        let remoteFileDTO = RemoteFileDTO(id: Test.id,
                                          ext: .png,
                                          data: imageData,
                                          public: false)
        
        remoteDataSourceMock.results[RemoteMethod.getFile] =
            .success([AcyncMockReturn { [remoteFileDTO] }])
        
        let result = try await repository.get(fileFromRemote: Test.id)
        
        XCTAssertEqual(result.data, imageData)
    }
    
    func testGetFromRemoteNotFound() async throws {
        remoteDataSourceMock.results[RemoteMethod.getFile] =
            .success([AcyncMockError {
                return DataSourceException.notFound()
            }])
        
        await XCTAssertThrowsException(
            try await repository.get(fileFromRemote: Test.id),
            equelTo: RepositoryException.notFound()
        )
    }
}

//MARK: save
extension FilesRepositoryTests {
    func testSaveFile() async throws {
        localDataSourceMock.results[LocalMethod.createFile] =
            .success([AcyncMockReturn { LocalFileDTO(id: "id") }])
        let fileInfo = FileInfo(id: Test.id,
                                ext: .png,
                                name: "test.png",
                                path: FilePath(remote: Test.path),
                                uid: "")
        let file = File(id: Test.id, info: fileInfo, data: imageData)
        
        _ = try await XCTAssertNoThrowsException(
            try await repository.save(file: file)
        )
        
        
    }
    
    func testSaveFileAlreadyExist() async throws {
        localDataSourceMock.results[LocalMethod.createFile] =
            .success([AcyncMockError {
                return DataSourceException.alreadyExist()
            }])
        let fileInfo = FileInfo(id: Test.id,
                                ext: .png,
                                name: "test.png",
                                path: FilePath(remote: Test.path),
                                uid: "")
        let file = File(id: Test.id, info: fileInfo, data: imageData)
        await XCTAssertThrowsException(
            try await repository.save(file: file),
            equelTo: RepositoryException.alreadyExist()
        )
    }
}

//MARK: delete
extension FilesRepositoryTests {
    func testDeleteFromLocal() async throws {
        localDataSourceMock.results[LocalMethod.deleteFile] =
            .success([AcyncMockVoid { }])
        
        try await XCTAssertNoThrowsException(
            try await repository.delete(fileFromLocal: Test.id)
        )
    }
    
    func testDeleteFromLocalNotFound() async throws {
        localDataSourceMock.results[LocalMethod.deleteFile] =
            .success([AcyncMockError {
                return DataSourceException.notFound()
            }])
        
        await XCTAssertThrowsException(
            try await repository.delete(fileFromLocal: Test.id),
            equelTo: RepositoryException.notFound()
        )
    }
    
    func testDeleteFromRemote() async throws {
        remoteDataSourceMock.results[RemoteMethod.deleteFile] =
            .success([AcyncMockVoid { }])
        
        try await XCTAssertNoThrowsException(
            try await repository.delete(fileFromRemote: Test.id)
        )
    }
    
    func testDeleteFromRemoteNotFound() async throws {
        remoteDataSourceMock.results[RemoteMethod.deleteFile] =
            .success([AcyncMockError {
                return DataSourceException.notFound()
            }])
        
        await XCTAssertThrowsException(
            try await repository.delete(fileFromRemote: Test.id),
            equelTo: RepositoryException.notFound()
        )
    }
}
