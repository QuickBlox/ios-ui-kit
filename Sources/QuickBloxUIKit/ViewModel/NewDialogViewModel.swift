//
//  NewDialogViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Combine
import QuickBloxDomain
import QuickBloxData
import AVFoundation
import QuickBloxLog
import PhotosUI
import CoreTransferable

public enum AttachmentType: String {
    case image = "image"
    case video = "video"
    case camera = "camera"
    case file = "file"
    case pdf = "pdf"
    case mp3 = "mp3"
    case gif = "gif"
    case error = "error"
}

public protocol NewDialogProtocol: PermissionProtocol, ObservableObject  {
    associatedtype DialogItem: DialogEntity
    
    var isValidDialogName: Bool { get set }
    var isExistingImage: Bool { get }
    var selectedImage: Image? { get set }
    var isProcessing: Bool { get set }
    var permissionNotGranted: PermissionInfo { get set }
    

    var modelDialog: DialogItem? { get set }
    
    func update(_ name: String)
    func removeExistingImage()
    func handleOnSelect(attachmentAsset: AttachmentAsset)
    func createPublicDialog()
    func createDialogModel()
    func openSettings()
    func requestPermission(_ mediaType: AVMediaType, completion: @escaping (_ granted: Bool) -> Void)
}

final class NewDialogViewModel: NewDialogProtocol {
    let settings = QuickBloxUIKit.settings.dialogNameScreen
    let regex = QuickBloxUIKit.feature.regex
    
    @Published public var isValidDialogName = false
    @Published public var selectedImage: Image? = nil
    @Published public var  isProcessing: Bool = false
    @Published public var permissionNotGranted: PermissionInfo = PermissionInfo(mediaType: .video)
    
    public var isExistingImage: Bool {
        return selectedImage != nil
    }
    
    private var dialogName = "" {
        didSet {
            isValidDialogName = regex.dialogName.isEmpty ? true : dialogName.isValid(regexes: [regex.dialogName])
        }
    }
    
    private var avatarUUID = ""
    
    private let permissionsRepo: PermissionsRepository = RepositoriesFabric.permissions
    
    private var attachmentAsset: AttachmentAsset? = nil
    
    @Published public var modelDialog: Dialog? = nil
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    init() {}
    
    public func sync() {}
    
    func update(_ name: String) {
        dialogName = name
    }
    
    public func handleOnSelect(attachmentAsset: AttachmentAsset) {
        if let uiImage = attachmentAsset.image {
            selectedImage = Image(uiImage: uiImage)
            self.attachmentAsset = attachmentAsset
            upload(avatar: uiImage, name: dialogName)
        }
    }
    
    public func removeExistingImage() {
        selectedImage = nil
        attachmentAsset = nil
        avatarUUID = ""
    }
    
    public func createPublicDialog() {
        //TODO: implement
//        let publicDialog = Dialog(type: .public, name: dialogName, photo: publicImageUrl ?? "")
    }
    
    public func upload(avatar: UIImage, name: String) {
        isProcessing = true
        Task { [weak self] in
            var compressionQuality: CGFloat = 1.0
            let maxFileSize: Int = 10 * 1024 * 1024 // 10MB in bytes
            var imageData = avatar.jpegData(compressionQuality: compressionQuality)
            
            while let data = imageData, data.count > maxFileSize && compressionQuality > 0.0 {
                compressionQuality -= 0.1
                imageData = avatar.jpegData(compressionQuality: compressionQuality)
            }
            
            if let finalImageData = imageData {
                let uploadAvatar = UploadFile(data: finalImageData,
                                              ext: .png,
                                              name: name,
                                              repo: RepositoriesFabric.files)
                let fileInfo =  try await uploadAvatar.execute()
                guard let uuid = fileInfo.info.path.uuid else { return }
                await MainActor.run { [weak self, uuid] in
                    self?.avatarUUID = uuid
                    self?.isProcessing = false
                }
            } else {
                await MainActor.run { [weak self] in
                    self?.isProcessing = false
                }
            }
        }
    }
    
    public func createDialogModel() {
        modelDialog = Dialog(type: .group, name: dialogName, photo: avatarUUID)
    }
    
    //MARK: - Media Permissions
    public func requestPermission(_ mediaType: AVMediaType, completion: @escaping (_ granted: Bool) -> Void) {
        let requestPermission = GetPermission(mediaType: mediaType, repo: permissionsRepo)
        
        Task {
            do {
                let granted = try await requestPermission.execute()
                await MainActor.run { [weak self, granted] in
                    self?.permissionNotGranted = PermissionInfo(mediaType: mediaType,
                                                                notGranted: granted == false)
                    completion(granted)
                }
            } catch {
                prettyLog(error)
            }
        }
    }
    
    public func openSettings() {
        let openSettings = OpenSettings(repo: permissionsRepo)
        
        Task {
            do {
                try await openSettings.execute()
            } catch {
                prettyLog(error)
            }
        }
    }
}

public extension String {
    func isValid(regexes: [String]) -> Bool {
        for regex in regexes {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            if predicate.evaluate(with: self) == true {
                return true
            }
        }
        return false
    }
}

extension View {
    public func toUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.first?.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        let image = controller.view.toUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
    public func toUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
