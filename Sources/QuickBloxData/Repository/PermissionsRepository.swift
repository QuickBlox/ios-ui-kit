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
    private let source: PermissionsDataSourceProtocol
    
    public init(source: PermissionsDataSourceProtocol) {
        self.source = source
    }
}

extension PermissionsRepository: PermissionsRepositoryProtocol {
    public func openSettings() async throws {
        do {
            try await source.openSettings()
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func get(permissionTo mediaType: AVMediaType) async throws -> Bool {
        do {
            return try await source.get(permissionTo: mediaType)
        } catch {
            throw try error.repositoryException
        }
    }
}
