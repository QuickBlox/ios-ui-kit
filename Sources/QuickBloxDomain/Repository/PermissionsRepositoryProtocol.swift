//
//  PermissionsRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import AVFoundation


public protocol PermissionsRepositoryProtocol {
    
    /// Request Permission for mediaType.
    /// - Parameter mediaType: ``AVMediaType``  an identifier for various media types.
    /// - Returns: ``Bool`` granted value.
    ///
    /// - Throws: ``RepositoryException``**.restrictedAccess** .
    func get(permissionTo mediaType: AVMediaType) async throws -> Bool
    
    /// Open Settings.
    ///
    /// - Throws: ``RepositoryException``**.restrictedAccess** .
    func openSettings() async throws
}
