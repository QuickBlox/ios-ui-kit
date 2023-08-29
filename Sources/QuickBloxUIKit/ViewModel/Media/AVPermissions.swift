//
//  AVPermissions.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class MediaPermissions: ObservableObject {
    
    public let microphonePermissionGrantedWillChange = PassthroughSubject<Bool, Never>()
    
    public let cameraPermissionGrantedWillChange = PassthroughSubject<Bool, Never>()
    
    private var microphonePermissionGranted: Bool = false {
        didSet {
            microphonePermissionGrantedWillChange.send(microphonePermissionGranted)
        }
    }
    
    private var cameraPermissionGranted: Bool = false {
        didSet {
            cameraPermissionGrantedWillChange.send(cameraPermissionGranted)
        }
    }
    
    public func requestPermissionToCamera() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {granted in
            DispatchQueue.main.async {
                self.cameraPermissionGranted = granted
            }
        })
    }
    
    public func requestPermissionToMicrophone() {
        AVAudioSession.sharedInstance().requestRecordPermission({ granted in
            DispatchQueue.main.async(execute: {
                self.microphonePermissionGranted = granted
            })
        })
    }
    
    public func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    public func requestPermissionToMicrophone(withCompletion completion: @escaping (_ granted: Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission({ granted in
            DispatchQueue.main.async(execute: {
                completion(granted)
            })
        })
    }
    
    public func requestPermissionToCamera(withCompletion completion: @escaping (_ granted: Bool) -> Void) {
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
