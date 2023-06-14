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

public protocol DialogInfoProtocol: ObservableObject {
    associatedtype Item: DialogEntity
    var dialog: Item { get set }
    var dialogName: String { get set }
    var error: String { get set }
    var isValidDialogName: Bool { get set }
    var isExistingImage: Bool { get }
    var isProcessing: CurrentValueSubject<Bool, Never> { get set }
    
    func removeExistingImage()
    func handleOnSelect(attachmentAsset: AttachmentAsset)
    func handleOnSelect(newName: String)
    func deleteDialog()
}

open class DialogInfoViewModel: DialogInfoProtocol {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    @Published public var dialog: Dialog
    
    @Published public var dialogName = ""
    @Published public var error = ""
    @Published public var isValidDialogName = false
    @Published public var isProcessing = CurrentValueSubject<Bool, Never>(false)
    public var isExistingImage: Bool {
        if dialog.photo == "null" { return false }
        return dialog.photo.isEmpty == false
    }
    
    private var attachmentAsset: AttachmentAsset? = nil
    
    private var taskUpdate: Task<Void, Never>?
    private var taskDelete: Task<Void, Never>?
    
    private var publishers = Set<AnyCancellable>()
    
    init(_ dialog: Dialog) {
        self.dialog = dialog

        let dialogName = dialog.name
        self.dialogName = dialogName
        
        isDialogNameValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValidDialogName, on: self)
            .store(in: &publishers)
    }
    
    public func updateDialog(_ modeldDialog: Dialog) {
        isProcessing.value = true
        taskUpdate = Task { [weak self] in
            do {
                let update = UpdateDialog(dialog: modeldDialog,
                                          users: [],
                                          repo: RepositoriesFabric.dialogs)
                try await update.execute()
                
                await MainActor.run { [weak self] in
                    if let uuid = self?.attachmentAsset?.name {
                        self?.dialog.photo = uuid
                    }
                    self?.isProcessing.value = false
                }
            } catch { prettyLog(error) }
            self?.taskUpdate = nil
        }
    }
    
    public func handleOnSelect(attachmentAsset: AttachmentAsset) {
        if let uiImage = attachmentAsset.image {
            self.isProcessing.value = true
            self.attachmentAsset = attachmentAsset
            updateDialog(avatar: uiImage, name: dialogName)
        }
    }
    
    @MainActor public func removeExistingImage() {
        attachmentAsset = nil
        removeDialogAvatar()
    }
    
    public func removeDialogAvatar() {
        // TODO: remove dialog avatar method. Create remove avatar use case.
        dialog.photo = "null"
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
        isProcessing.value = true
        taskDelete = Task { [weak self] in
            do {
                guard let dialog = self?.dialog else { return }
                let leave = LeaveDialog(dialog: dialog,
                                        repo: RepositoriesFabric.dialogs)
                try await leave.execute()
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.isProcessing.value = false
                }
            } catch {
                prettyLog(error)
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.error = error.localizedDescription
                }
            }
            self?.taskDelete = nil
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
