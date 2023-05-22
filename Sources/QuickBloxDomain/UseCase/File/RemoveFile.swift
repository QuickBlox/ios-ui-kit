//
//  RemoveFile.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//


public class RemoveFile<Repo: FilesRepositoryProtocol> {
    private let id: String
    private let repo: Repo
    
    public init(id: String, repo: Repo) {
        self.id = id
        self.repo = repo
    }
    
    public func execute() async throws {
        try? await repo.delete(fileFromLocal: id)
        try await repo.delete(fileFromRemote: id)
    }
}
