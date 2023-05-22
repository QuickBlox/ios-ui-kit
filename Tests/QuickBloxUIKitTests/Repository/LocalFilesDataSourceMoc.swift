//
//  LocalFilesDataSourceMoc.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData

class LocalFilesDataSourceMoc: Mock { }

extension LocalFilesDataSourceMoc {
    struct MockMethod {
        static let createFile = "createFile(_:)"
        static let getFile = "getFile(_:)"
        static let deleteFile = "deleteFile(_:)"
        static let cleareAll = "cleareAll()"
    }
}

extension LocalFilesDataSourceMoc: LocalFilesDataSourceProtocol {
    func createFile(_ dto: LocalFileDTO) async throws -> LocalFileDTO {
        try await mock().callAcyncReturn()
    }

    func getFile(_ dto: LocalFileDTO) async throws -> LocalFileDTO {
        try await mock().callAcyncReturn()
    }

    func deleteFile(_ dto: LocalFileDTO) async throws {
        try await mock().callAcyncVoid()
    }

    func cleareAll() async throws {
        try await mock().callAcyncVoid()
    }
}
