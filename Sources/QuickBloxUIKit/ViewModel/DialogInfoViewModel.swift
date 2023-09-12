//
//  DialogInfoViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import Combine
import QuickBloxDomain
import QuickBloxData
import QuickBloxLog
import AVFoundation

public protocol DialogInfoProtocol: ObservableObject, PermissionProtocol  {
    associatedtype Item: DialogEntity
    var dialog: Item { get set }
    var dialogName: String { get set }
    var error: String { get set }
    var isValidDialogName: Bool { get set }
    var isExistingImage: Bool { get }
    var isProcessing: Bool { get set }
    var permissionNotGranted: PermissionInfo { get set }
    var avatar: Image? { get set }
    
    func removeExistingImage()
    func handleOnSelect(attachmentAsset: AttachmentAsset)
    func handleOnSelect(newName: String)
    func deleteDialog()
    func openSettings()
    func requestPermission(_ mediaType: AVMediaType, completion: @escaping (_ granted: Bool) -> Void)
}

open class DialogInfoViewModel: DialogInfoProtocol {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    @Published public var dialog: Dialog
    
    @Published public var dialogName = ""
    @Published public var error = ""
    @Published public var isValidDialogName = false
    @Published public var isProcessing: Bool = false
    @Published public var permissionNotGranted: PermissionInfo = PermissionInfo(mediaType: .video)
    
    @Published public var avatar: Image? = nil
    
    public var isExistingImage: Bool {
        if dialog.photo == "null" { return false }
        return dialog.photo.isEmpty == false
    }
    
    private let permissionsRepo: PermissionsRepository = RepositoriesFabric.permissions
    
    private var attachmentAsset: AttachmentAsset? = nil
    
    private var taskUpdate: Task<Void, Never>?
    private var taskDelete: Task<Void, Never>?
    private var taskGetAvatar: Task<Void, Never>?
    
    private var publishers = Set<AnyCancellable>()
    
    init(_ dialog: Dialog) {
        self.dialog = dialog

        let dialogName = dialog.name
        self.dialogName = dialogName
        
        getAvatar()
        
        isDialogNameValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValidDialogName, on: self)
            .store(in: &publishers)
    }
    
    private func getAvatar() {
        isProcessing = true
        taskGetAvatar = Task { [weak self] in
            do {
                let avatar = try await self?.dialog.avatar
                
                await MainActor.run { [weak self, avatar] in
                    self?.avatar = avatar
                    self?.isProcessing = false
                }
                self?.taskGetAvatar = nil
            } catch {
                prettyLog(error)
                if error is RepositoryException {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.isProcessing = false
                    }
                    self?.taskGetAvatar = nil
                }
            }
        }
    }
    
    public func updateDialog(_ modeldDialog: Dialog) {
        isProcessing = true
        taskUpdate = Task { [weak self] in
            do {
                let update = UpdateDialog(dialog: modeldDialog,
                                          users: [],
                                          repo: RepositoriesFabric.dialogs)
                try await update.execute()
                
                await MainActor.run { [weak self] in
                    self?.getAvatar()
                }
                self?.taskUpdate = nil
            } catch {
                prettyLog(error)
                if error is RepositoryException {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.isProcessing = false
                    }
                    self?.taskUpdate = nil
                }
            }
        }
    }
    
    public func handleOnSelect(attachmentAsset: AttachmentAsset) {
        if let uiImage = attachmentAsset.image {
            isProcessing = true
            self.attachmentAsset = attachmentAsset
            updateDialog(avatar: uiImage, name: dialogName)
        }
    }
    
    @MainActor public func removeExistingImage() {
        attachmentAsset = nil
        removeDialogAvatar()
    }
    
    public func removeDialogAvatar() {
        self.isProcessing = true
        dialog.photo = "null"
        dialog.removeAvatar()
        updateDialog(dialog)
    }
    
    public func updateDialog(avatar: UIImage, name: String) {
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
                    guard let self = self else { return }
                    self.dialog.removeAvatar()
                    self.dialog.photo = uuid
                    self.updateDialog(dialog)
                }
            }
        }
    }
    
    public func handleOnSelect(newName: String) {
        updateDialog(name: newName)
    }
    
    public func updateDialog(name: String) {
        if dialog.name == name { return }
        dialog.name = name
        updateDialog(dialog)
    }
    
    public func deleteDialog() {
        if isProcessing == true {
            return
        }
        isProcessing = true
        taskDelete = Task {
            do {
                let leave = LeaveDialog(dialog: dialog,
                                        repo: RepositoriesFabric.dialogs)
                try await leave.execute()
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.isProcessing = false
                }
                self.taskDelete = nil
            } catch {
                prettyLog(error)
                if error is RepositoryException {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.error = error.localizedDescription
                        self.isProcessing = false
                    }
                    self.taskDelete = nil
                }
            }
        }
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

// MARK: - Validation
private extension DialogInfoViewModel {
    var isDialogNameValidPublisher: AnyPublisher<Bool, Never> {
        $dialogName
            .map { dialogName in
                return dialogName.isValid(regexes: [self.settings.regexDialogName])
            }
            .eraseToAnyPublisher()
    }
}
