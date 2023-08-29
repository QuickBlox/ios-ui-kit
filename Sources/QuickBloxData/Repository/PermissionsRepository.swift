//
//  PermissionsRepository.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import AVFoundation

public class PermissionsRepository {
    private var repo: PermissionsRepositoryProtocol!
    
    init(repo: PermissionsRepositoryProtocol) {
        self.repo = repo
    }
    
    private init() { }
}

extension PermissionsRepository: PermissionsRepositoryProtocol {
    public func openSettings() async throws {
        do {
            try await repo.openSettings()
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(permissionTo mediaType: AVMediaType) async throws -> Bool {
        do {
            return try await repo.get(permissionTo: mediaType)
        } catch {
            throw try error.repositoryException
        }
    }
}
