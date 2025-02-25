//
//  PermissionsDataSourceProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.01.2025.
//  Copyright © 2025 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import AVFoundation

public protocol PermissionsDataSourceProtocol {
    
    /// Request Permission for mediaType.
    /// - Parameter mediaType: ``AVMediaType``  an identifier for various media types.
    /// - Returns: ``Bool`` granted value.
    ///
    /// - Throws: An error if the permission request fails or access to the requested media type is restricted.
    func get(permissionTo mediaType: AVMediaType) async throws -> Bool
    
    /// Open Settings.
    ///
    /// - Throws: An error if the settings cannot be opened (e.g., unsupported platform or restricted access).
    func openSettings() async throws
}
