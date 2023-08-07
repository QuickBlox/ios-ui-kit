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
            let task: Task<File, Error> = Task { [weak self] in
                try Task.checkCancellation()
                guard let self = self else {
                    throw RepositoryException.unauthorised()
                }
                let file = try await self.repo.get(fileFromRemote: self.id)
                return try await self.repo.save(file: file)
            }
            let result = await task.result
            
            switch result {
            case .success(let file):
                return file
            case .failure(let error):
                throw error
            }
        }
    }
}
