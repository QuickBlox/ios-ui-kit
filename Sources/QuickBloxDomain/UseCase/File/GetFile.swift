//
//  GetFile.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog

public class GetFile<File: FileEntity , Repo: FilesRepositoryProtocol>
where File == Repo.FileEntityItem {
    private let id: String
    private let repo: Repo
    
    public init(id: String, repo: Repo) {
        self.id = id
        self.repo = repo
    }
    
    public func execute() async throws -> File {
        do {
            return try await repo.get(fileFromLocal: id)
        } catch RepositoryException.notFound(_) {
            do {
                let task: Task<File, Error> = Task(priority: .medium) {
                    let file = try await repo.get(fileFromRemote: id)
                    return try await repo.save(file: file)
                }
                let result = await task.result
                
                switch result {
                    case .success(let file):
                        return file
                    case .failure(let error):
                        throw error
                }
            } catch  {
                prettyLog(error)
                throw error
            }
        }
    }
}
