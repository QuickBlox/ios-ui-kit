//
//  OpenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog

public class OpenSettings<Repo: PermissionsRepositoryProtocol>{
    private let repo: Repo
    
    public init(repo: Repo) {
        self.repo = repo
    }
    
    public func execute() async throws {
        return try await repo.openSettings()
    }
}
