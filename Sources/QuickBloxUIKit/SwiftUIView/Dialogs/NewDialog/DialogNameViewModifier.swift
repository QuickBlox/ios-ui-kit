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
    
    private var header = QuickBloxUIKit.settings.dialogNameScreen.header
    
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
                if let title = header.leftButton.title {
                    Text(title)
                        .foregroundColor(header.leftButton.color)
                } else {
                    header.leftButton.image.tint(header.leftButton.color)
                }
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(header.title.text)
                .font(header.title.font)
                .foregroundColor(header.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onNext()
            } label: {
                if let create = header.rightButton.title,
                   let next = header.rightButton.secondTitle {
                    Text(type == .public ? create : next)
                        .foregroundColor(header.rightButton.color.opacity(disabled == true ? header.opacity : 1.0))
                } else {
                    header.rightButton.image.tint(header.rightButton.color.opacity(disabled == true ? header.opacity : 1.0))
                }
            }.disabled(disabled)
        }
    }
}

public struct DialogNameHeader: ViewModifier {
    private var header = QuickBloxUIKit.settings.dialogNameScreen.header
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
        .navigationTitle(header.title.text)
        .navigationBarTitleDisplayMode(header.displayMode)
        .navigationBarBackButtonHidden(true)
    }
}

public struct CustomMediaAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogNameScreen.mediaAlert
    
    @Binding var isAlertPresented: Bool
    @State var isImagePickerPresented: Bool = false
    @State var isCameraPresented: Bool = false
    @State var isFilePresented: Bool = false
    var isExistingImage: Bool
    let isShowFiles: Bool
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
                    if isShowFiles == true {
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
        isShowFiles: Bool,
        mediaTypes: [String],
        onRemoveImage: @escaping () -> Void,
        onGetAttachment: @escaping (_ attachmentAsset: AttachmentAsset) -> Void
    ) -> some View {
        self.modifier(CustomMediaAlert(isAlertPresented: isAlertPresented,
                                       isExistingImage: isExistingImage,
                                       isShowFiles: isShowFiles,
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
                    Text(settings.largeSize)
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
    let mediaTypes: [UTType] = [.jpeg, .png, .heic, .heif, .gif, .webP, .mpeg4Movie, .mpeg4Audio, .aiff, .wav, .webArchive, .mp3, .pdf, .image, .video, .movie, .audio, .data, .diskImage]
    let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes:mediaTypes)
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
