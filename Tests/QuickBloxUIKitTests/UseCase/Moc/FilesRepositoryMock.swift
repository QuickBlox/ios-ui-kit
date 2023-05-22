//
//  FilesRepositoryMock.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData
import Foundation

class FilesRepositoryMock: Mock { }

extension FilesRepositoryMock: FilesRepositoryProtocol {
    struct MockMethod {
        static let upload = "upload(data:ext:name:isPublic:)"
        static let getRemote = "get(fileFromRemote:)"
        static let getLocal = "get(fileFromLocal:)"
        static let save = "save(file:)"
        static let deleteRemote = "delete(fileFromRemote:)"
        static let deleteLocal = "delete(fileFromLocal:)"
    }
    
    func upload(data: Data,
                ext: FileExtension,
                name: String,
                isPublic: Bool = false) async throws -> File {
        try await mock().callAcyncReturn()
    }
    
    func get(fileFromRemote path: String) async throws -> File {
        try await mock().callAcyncReturn()
    }
    
    func get(fileFromLocal path: String) async throws -> File {
        try await mock().callAcyncReturn()
    }
    
    func save(file: File) async throws -> File {
        try await mock().callAcyncReturn()
    }
    
    func delete(fileFromRemote path: String) async throws {
        try await mock().callAcyncVoid()
    }
    
    func delete(fileFromLocal path: String) async throws {
        try await mock().callAcyncVoid()
    }
}
