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
    var isValidDialogName: Bool { get set }
    var isExistingImage: Bool { get }
    var selectedImage: Image? { get set }
    var isProcessing: CurrentValueSubject<Bool, Never> { get set }
    
    func removeExistingImage()
    func handleOnSelect(attachmentAsset: AttachmentAsset)
    func handleOnSelect(newName: String)
    func deleteDialog()
}

open class DialogInfoViewModel: DialogInfoProtocol {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    public var dialog: Dialog
    
    @Published public var dialogName = ""
    @Published public var isValidDialogName = false
    @Published public var selectedImage: Image? = nil
    @Published public var isProcessing = CurrentValueSubject<Bool, Never>(false)
    public var isExistingImage: Bool {
        return dialog.photo.isEmpty == false
    }
    
    private var attachmentAsset: AttachmentAsset? = nil
    
    private var taskUpdate: Task<Void, Never>?
    private var taskDelete: Task<Void, Never>?
    
    private var publishers = Set<AnyCancellable>()
    
    public private(set) var dialogsRepo: DialogsRepository =
    RepositoriesFabric.dialogs
    
    init(_ dialog: Dialog,
         dialogsRepo: DialogsRepository = RepositoriesFabric.dialogs) {
        self.dialog = dialog
        self.dialogsRepo = dialogsRepo
        self.dialogName = dialog.name
        
        isDialogNameValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValidDialogName, on: self)
            .store(in: &publishers)
    }
    
    public func updateDialog(_ modeldDialog: Dialog) {
        isProcessing.value = true
        taskUpdate = Task {
            do {
                let update = UpdateDialog(dialog: modeldDialog,
                                          users: [],
                                          repo: dialogsRepo)
                try await update.execute()
                self.isProcessing.value = false
                self.taskUpdate = nil
            } catch {
                prettyLog(error)
                taskUpdate = nil
            }
        }
    }
    
    public func handleOnSelect(attachmentAsset: AttachmentAsset) {
        if let uiImage = attachmentAsset.image {
            selectedImage = Image(uiImage: uiImage)
            self.attachmentAsset = attachmentAsset
            updateDialog(avatar: selectedImage)
        }
    }
    
    public func removeExistingImage() {
        selectedImage = nil
        attachmentAsset = nil
        updateDialog(avatar: nil)
    }
    
    public func updateDialog(avatar: Image?) {
        if let avatar {
            let uiImage = avatar.toUIImage()
            Task {
                var compressionQuality: CGFloat = 1.0
                let maxFileSize: Int = 10 * 1024 * 1024 // 10MB in bytes
                var imageData = uiImage.jpegData(compressionQuality: compressionQuality)
                
                while let data = imageData, data.count > maxFileSize && compressionQuality > 0.0 {
                    compressionQuality -= 0.1
                    imageData = uiImage.jpegData(compressionQuality: compressionQuality)
                }
                
                if let finalImageData = imageData {
                    let uploadAvatar = UploadFile(data: finalImageData,
                                                  ext: .png,
                                                  name: dialogName,
                                                  repo: RepositoriesFabric.files)
                    let fileInfo =  try await uploadAvatar.execute()
                    await MainActor.run { [fileInfo] in
                        if let uuid = fileInfo.info.path.uuid {
                            dialog.photo = uuid
                            self.updateDialog(dialog)
                        }
                    }
                }
            }
        } else {
            dialog.photo = ""
            updateDialog(dialog)
        }
    }
    
    public func handleOnSelect(newName: String) {
        updateDialog(name: newName)
    }
    
    public func updateDialog(name: String) {
        dialog.name = name
        updateDialog(dialog)
    }
    
    public func deleteDialog() {
        isProcessing.value = true
        taskDelete = Task {
            do {
                let leave = LeaveDialog(dialog: dialog,
                                        repo: RepositoriesFabric.dialogs)
                try await leave.execute()
                self.isProcessing.value = false
                self.taskDelete = nil
            } catch {
                prettyLog(error)
                taskDelete = nil
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
