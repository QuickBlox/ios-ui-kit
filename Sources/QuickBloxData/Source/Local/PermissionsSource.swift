//
//  PermissionsSource.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import AVFoundation
import UIKit

class PermissionsSource {
    
}

//MARK: PermissionsRepositoryProtocol
extension PermissionsSource: PermissionsRepositoryProtocol {
    func openSettings() async throws {
        if let url = await URL(string: UIApplication.openSettingsURLString) {
            await UIApplication.shared.open(url, options: [:])
        }
    }
    
    func get(permissionTo mediaType: AVMediaType) async throws -> Bool {
        switch mediaType {
        case .audio: return try await PermissionsSource.requestPermissionTo(.audio)
        case .video: return try await PermissionsSource.requestPermissionTo(.video)
        default: return false
        }
    }
}

private extension PermissionsSource {
    
    static func requestPermissionTo(_ mediaType: AVMediaType) async throws -> Bool {
        switch mediaType {
        case .audio:
            return try await withCheckedThrowingContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                    DispatchQueue.main.async(execute: {
                        continuation.resume(returning: granted)
                    })
                })
            }
        case .video:
            return try await withCheckedThrowingContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video, completionHandler: {granted in
                    DispatchQueue.main.async {
                        continuation.resume(returning: granted)
                    }
                })
            }
        default: return false
        }
    }
}
