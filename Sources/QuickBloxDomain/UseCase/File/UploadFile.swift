//
//  UploadFile.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation


public class UploadFile<File: FileEntity , Repo: FilesRepositoryProtocol>
where File == Repo.FileEntityItem {
    private let data: Data
    private let ext: FileExtension
    private let name: String
    private let isPublic: Bool
    private let repo: Repo
    
    public init(data: Data, ext: FileExtension, name: String, isPublic: Bool = false, repo: Repo) {
        self.data = data
        self.ext = ext
        if let extStr = name.components(separatedBy: ".").last,
            extStr.isEmpty == false {
            self.name = name
        } else {
            self.name = "\(name).\(ext.rawValue)"
        }
        self.isPublic = isPublic
        self.repo = repo
    }
    
    public func execute() async throws -> File {
        let file = try await repo.upload(data: data,
                                         ext: ext,
                                         name: name,
                                         isPublic: isPublic)
        return try await repo.save(file: file)
    }
}
