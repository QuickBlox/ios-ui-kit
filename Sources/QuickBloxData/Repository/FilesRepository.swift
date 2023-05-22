//
//  FilesRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxDomain

public class FilesRepository: FilesRepositoryProtocol {
    private let remote: RemoteDataSourceProtocol
    private let local:  LocalFilesDataSourceProtocol
    
    public init(remote: RemoteDataSourceProtocol,
                local: LocalFilesDataSourceProtocol) {
        self.remote = remote
        self.local = local
    }
    
    public func upload(data: Data,
                       ext: FileExtension,
                       name: String,
                       isPublic: Bool = false) async throws -> File {
        do {
            let dto = RemoteFileDTO(ext: ext,
                                    name: name,
                                    data: data,
                                    public: isPublic)
            let file = try await remote.create(file: dto)
            return File(file)
        } catch { throw try error.repositoryException }
    }
    
    public func get(fileFromLocal path: String) async throws -> File {
        do {
            let dto = LocalFileDTO(id: path)
            let file = try await local.getFile(dto)
            return File(file)
        } catch { throw try error.repositoryException }
    }
    
    public func get(fileFromRemote path: String) async throws -> File {
        do {
            let dto = RemoteFileDTO(id: path)
            let file = try await remote.get(file: dto)
            return File(file)
        } catch { throw try error.repositoryException }
    }
    
    public func save(file: File) async throws -> File {
        do {
            let dto = LocalFileDTO(file)
            let file = try await local.createFile(dto)
            return File(file)
        } catch { throw try error.repositoryException }
    }
    
    public func delete(fileFromLocal path: String) async throws {
        do { try await local.deleteFile(LocalFileDTO(id: path)) }
        catch { throw try error.repositoryException }
    }
    
    public func delete(fileFromRemote path: String) async throws {
        do { try await remote.delete(file: (RemoteFileDTO(id: path))) }
        catch { throw try error.repositoryException }
    }
}

private extension LocalFileDTO {
    init(_ value: RemoteFileDTO) {
        id = value.id
        ext = value.ext
        name = value.name
        type = value.type
        data = value.data
        path = value.path
    }
}

private extension File {
    init(_ value: RemoteFileDTO) {
        id = value.id
        info = FileInfo(id: value.id,
                        ext: value.ext,
                        name: value.name,
                        path: value.path)
        data = value.data
    }
}

private extension File {
    init(_ value: LocalFileDTO) {
        id = value.id
        info = FileInfo(id: value.id,
                        ext: value.ext,
                        name: value.name,
                        path: value.path)
        data = value.data
    }
}

private extension LocalFileDTO {
    init(_ value: File) {
        id = value.id
        ext = value.info.ext
        name = value.info.name
        type = value.info.type
        path = value.info.path
        data = value.data
    }
}
