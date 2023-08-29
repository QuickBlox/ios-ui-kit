//
//  GetPermission.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxLog
import AVFoundation

public class GetPermission<Repo: PermissionsRepositoryProtocol>{
    private let mediaType: AVMediaType
    private let repo: Repo
    
    public init(mediaType: AVMediaType, repo: Repo) {
        self.mediaType = mediaType
        self.repo = repo
    }
    
    public func execute() async throws -> Bool {
        return try await repo.get(permissionTo: mediaType)
    }
}
