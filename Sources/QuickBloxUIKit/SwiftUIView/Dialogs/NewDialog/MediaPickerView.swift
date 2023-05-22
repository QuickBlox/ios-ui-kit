//
//  MediaPickerView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import UIKit
import AVFoundation
import UniformTypeIdentifiers
import QuickBloxDomain

struct MediaPickerView: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var attachmentAsset: AttachmentAsset?
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> MediaPickerViewCoordinator {
        return MediaPickerViewCoordinator(attachmentAsset: $attachmentAsset, isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        pickerController.mediaTypes = [UTType.movie.identifier, UTType.image.identifier]
        return pickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

class MediaPickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var attachmentAsset: AttachmentAsset?
    @Binding var isPresented: Bool
    
    init(attachmentAsset: Binding<AttachmentAsset?>, isPresented: Binding<Bool>) {
        self._attachmentAsset = attachmentAsset
        self._isPresented = isPresented
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
           let imageData = image.jpegData(compressionQuality: 1) {
            
            var ext: FileExtension = .png
            if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                ext = FileExtension(rawValue: imageUrl.pathExtension.lowercased()) ?? .png
            }
            
            var compressionQuality: CGFloat = 1.0
            let maxFileSize: Int = 10 * 1024 * 1024 // 10MB in bytes
            var processImageData = imageData
            
            while processImageData.count > maxFileSize && compressionQuality > 0.0 {
                compressionQuality -= 0.1
                if let imageJpegData = image.jpegData(compressionQuality: compressionQuality) {
                    processImageData = imageJpegData
                } else {
                    let data = NSData(data: processImageData)
                    let size: Double = Double(data.length)
                    self.attachmentAsset = AttachmentAsset(image: image, data: processImageData, type: .image, ext: ext, url: nil, size: size / 1048576)
                    self.isPresented = false
                    return
                }
            }
            let image = UIImage(data: processImageData)
            
            let data = NSData(data: imageData)
            let size: Double = Double(data.length)
            
            self.attachmentAsset = AttachmentAsset(image: image, data: processImageData, type: .image, ext: ext, url: nil, size: size / 1048576)
            self.isPresented = false
        }
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL {
            do {
                let data: Data = try Data(contentsOf: videoURL)
                let ext = FileExtension(rawValue: videoURL.pathExtension.lowercased()) ?? .mov
                self.attachmentAsset = AttachmentAsset(image: nil, data: data, type: .video, ext: ext, url: videoURL, size: videoURL.fileSizeMB)
                self.isPresented = false
            } catch let error {
                debugPrint("Error Get Video: \(error.localizedDescription)")
                self.isPresented = false
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
    }
    
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
}
