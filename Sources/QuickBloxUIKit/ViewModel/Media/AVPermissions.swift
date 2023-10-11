//
//  AVPermissions.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class MediaPermissions {
    
    class func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    class func requestPermissionToMicrophone(withCompletion completion: @escaping (_ granted: Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission({ granted in
            DispatchQueue.main.async(execute: {
                completion(granted)
            })
        })
    }
    
    class func requestPermissionToCamera(withCompletion completion: @escaping (_ granted: Bool) -> Void) {
        let mediaType = AVMediaType.video
        let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { granted in
                DispatchQueue.main.async(execute: {
                    completion(granted)
                })
            })
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            fatalError("unknown authStatus")
        }
    }
}
