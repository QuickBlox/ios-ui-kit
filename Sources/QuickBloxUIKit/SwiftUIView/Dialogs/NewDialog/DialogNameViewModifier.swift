//
//  DialogNameViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import UniformTypeIdentifiers

struct DialogNameHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogNameScreen.header
    
    let onDismiss: () -> Void
    let onNext: () -> Void
    let type: DialogType
    var disabled: Bool = true
    
    public init(
        type: DialogType,
        disabled: Bool,
        onDismiss: @escaping () -> Void,
        onNext: @escaping () -> Void) {
            self.onDismiss = onDismiss
            self.onNext = onNext
            self.type = type
            self.disabled = disabled
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onDismiss()
            } label: {
                if let title = settings.leftButton.title {
                    Text(title)
                        .foregroundColor(settings.leftButton.color)
                } else {
                    settings.leftButton.image
                        .resizable()
                        .scaleEffect(settings.leftButton.scale)
                        .tint(settings.leftButton.color)
                        .padding(settings.leftButton.padding)
                }
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onNext()
            } label: {
                if let next = settings.rightButton.title {
                    Text(next)
                        .foregroundColor(settings.rightButton.color.opacity(disabled == true ? settings.opacity : 1.0))
                } else {
                    settings.rightButton.image
                        .resizable()
                        .scaleEffect(settings.rightButton.scale)
                        .tint(settings.rightButton.color.opacity(disabled == true ? settings.opacity : 1.0))
                        .padding(settings.rightButton.padding)
                }
            }.disabled(disabled)
        }
    }
}

public struct DialogNameHeader: ViewModifier {
    private var settings = QuickBloxUIKit.settings.dialogNameScreen.header
    let onDismiss: () -> Void
    let onNext: () -> Void
    let type: DialogType
    var disabled: Bool = true
    
    public init(type: DialogType,
                disabled: Bool,
                onDismiss: @escaping () -> Void,
                onNext: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self.onNext = onNext
        self.type = type
        self.disabled = disabled
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogNameHeaderToolbarContent(type: type,
                                           disabled: disabled,
                                           onDismiss: onDismiss,
                                           onNext: onNext)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
    }
}

public struct CustomMediaAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogNameScreen.mediaAlert
    
    @Binding var isAlertPresented: Bool
    @State var isImagePickerPresented: Bool = false
    @State var isCameraPresented: Bool = false
    @State var isFilePresented: Bool = false
    var isExistingImage: Bool
    let isHiddenFiles: Bool
    let mediaTypes: [String]
    let onRemoveImage: () -> Void
    let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isAlertPresented || isImagePickerPresented || isFilePresented ? settings.blurRadius : 0.0)
                .confirmationDialog(settings.title, isPresented: $isAlertPresented, actions: {
                    if isExistingImage == true {
                        Button(settings.removePhoto, role: .destructive) {
                            onRemoveImage()
                            defaultState()
                        }
                    }
                    Button(settings.camera, role: .none) {
                        isImagePickerPresented = true
                        isCameraPresented = true
                    }
                    Button(settings.gallery, role: .none, action: {
                        isImagePickerPresented = true
                    })
                    if isHiddenFiles == false {
                        Button(settings.file, role: .none, action: {
                            isFilePresented = true
                        })
                    }
                    Button(settings.cancel, role: .cancel) {
                        defaultState()
                    }
                })
            
                .imagePicker(isImagePickerPresented: $isImagePickerPresented,
                             isCameraPresented: $isCameraPresented,
                             mediaTypes: mediaTypes,
                             onDismiss: {
                    defaultState()
                }, onGetAttachment: { attachmentAsset in
                    onGetAttachment(attachmentAsset)
                    defaultState()
                })
            
                .filePicker(isFilePickerPresented: $isFilePresented,
                            onGetAttachment: onGetAttachment)
        }
    }
    
    private func defaultState() {
        isAlertPresented = false
        isCameraPresented = false
        isImagePickerPresented = false
    }
}

extension View {
    func mediaAlert(
        isAlertPresented: Binding<Bool>,
        isExistingImage: Bool,
        isHiddenFiles: Bool,
        mediaTypes: [String],
        onRemoveImage: @escaping () -> Void,
        onGetAttachment: @escaping (_ attachmentAsset: AttachmentAsset) -> Void
    ) -> some View {
        self.modifier(CustomMediaAlert(isAlertPresented: isAlertPresented,
                                       isExistingImage: isExistingImage,
                                       isHiddenFiles: isHiddenFiles,
                                       mediaTypes: mediaTypes,
                                       onRemoveImage: onRemoveImage,
                                       onGetAttachment: onGetAttachment
                                      ))
    }
}

public struct ErrorAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogScreen
    
    @Binding var error: String
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        ZStack {
            content.blur(radius: isPresented ? settings.blurRadius : 0.0)
                .alert("", isPresented: $isPresented) {
                    Button("Cancel", action: {
                        error = ""
                        isPresented = false
                    })
                } message: {
                    Text(error)
                }
        }
    }
}

extension View {
    func errorAlert(_ error: Binding<String>,
                    isPresented: Binding<Bool>
    ) -> some View {
        self.modifier(ErrorAlert(error: error,
                                 isPresented: isPresented))
    }
}

public struct LargeFileSizeAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogScreen
    
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        ZStack {
            content.blur(radius: isPresented ? settings.blurRadius : 0.0)
                .alert("", isPresented: $isPresented) {
                    Button("Cancel", action: {
                        isPresented = false
                    })
                } message: {
                    Text(settings.maxSize)
                }
        }
    }
}

extension View {
    func largeFileSizeAlert(
        isPresented: Binding<Bool>
    ) -> some View {
        self.modifier(LargeFileSizeAlert(isPresented: isPresented))
    }
}


public struct ImagePicker: ViewModifier {
    
    @Binding var isImagePickerPresented: Bool
    @Binding var isCameraPresented: Bool
    @State var attachmentAsset: AttachmentAsset? = nil
    var mediaTypes: [String]
    let onDismiss: () -> Void
    let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .fullScreenCover(isPresented: $isImagePickerPresented) {
                    ZStack {
                        if isCameraPresented == true {
                            Color.black.ignoresSafeArea(.all)
                        }
                        MediaPickerView(sourceType: isCameraPresented == false ? .photoLibrary : .camera,
                                        attachmentAsset: $attachmentAsset,
                                        isPresented: $isImagePickerPresented,
                                        mediaTypes: mediaTypes)
                        .onDisappear {
                            onDismiss()
                            if let attachmentAsset {
                                onGetAttachment(attachmentAsset)
                            }
                        }
                        
                    }
                }
        }
    }
}

extension View {
    func imagePicker(
        isImagePickerPresented: Binding<Bool>,
        isCameraPresented: Binding<Bool>,
        mediaTypes: [String],
        onDismiss: @escaping () -> Void,
        onGetAttachment: @escaping (_ attachmentAsset: AttachmentAsset) -> Void
    ) -> some View {
        self.modifier(ImagePicker(isImagePickerPresented: isImagePickerPresented,
                                  isCameraPresented: isCameraPresented,
                                  mediaTypes: mediaTypes,
                                  onDismiss: onDismiss,
                                  onGetAttachment: onGetAttachment))
    }
}

public struct FilePickerViewModifier : ViewModifier {
    @Binding var isFilePickerPresented: Bool
    let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .sheet(isPresented: $isFilePickerPresented) {
                    FilePickerView(onGetAttachment: onGetAttachment)
                }
        }
    }
}

extension View {
    func filePicker(isFilePickerPresented: Binding<Bool>,
                    onGetAttachment: @escaping (_ attachmentAsset: AttachmentAsset) -> Void
    ) -> some View {
        self.modifier(FilePickerViewModifier(isFilePickerPresented: isFilePickerPresented,
                                             onGetAttachment: onGetAttachment))
    }
}

import UIKit

struct FilePickerView: UIViewControllerRepresentable {
    public var settings = QuickBloxUIKit.settings.dialogNameScreen.mediaAlert
    
    let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: settings.fileMediaTypes)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onGetAttachment: onGetAttachment)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
        
        init(onGetAttachment: @escaping (_ attachmentAsset: AttachmentAsset) -> Void) {
            self.onGetAttachment = onGetAttachment
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
            
            let isAccessing = url.startAccessingSecurityScopedResource()
            
            defer {
                if isAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            guard let ext = FileExtension(rawValue: url.pathExtension.lowercased()) else { return }
            let name = url.lastPathComponent
            
            if ext.type == .image {
                let image = UIImage(contentsOfFile: url.path)
                let attachmentAsset = AttachmentAsset(name: name, image: image, data: nil, ext: ext, url: url, size: url.fileSizeMB)
                onGetAttachment(attachmentAsset)
            } else {
                do {
                    let data = try Data(contentsOf: url)
                    let attachmentAsset = AttachmentAsset(name: name, image: nil, data: data, ext: ext, url: url, size: url.fileSizeMB)
                    onGetAttachment(attachmentAsset)
                } catch let error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
    }
}

extension URL {
    var fileSize: Int? {
        let _  = self.startAccessingSecurityScopedResource()
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
    var fileSizeMB: Double {
        let filePath = self.path
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1048576
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    var directorySize: Int? {
        let value = try? resourceValues(forKeys: [.isDirectoryKey])
        return value?.fileSize
    }
}
