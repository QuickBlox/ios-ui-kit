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
import Photos
import PhotosUI

struct MediaPickerView: UIViewControllerRepresentable {

    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var attachmentAsset: AttachmentAsset?
    @Binding var isPresented: Bool
    var mediaTypes: [String]

    func makeCoordinator() -> MediaPickerViewCoordinator {
        return MediaPickerViewCoordinator(attachmentAsset: $attachmentAsset, isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        pickerController.mediaTypes = mediaTypes
        pickerController.allowsEditing = true
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
        var image : UIImage = UIImage()
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }

        if let imageData = image.jpegData(compressionQuality: 1) {

            var ext: FileExtension = .png
            if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                ext = FileExtension(rawValue: imageUrl.pathExtension.lowercased()) ?? .png
            }

            var name = "Image.\(ext.rawValue)"
              if let asset = info[.phAsset] as? PHAsset,
                 let fileName = asset.value(forKey: "filename") as? String {
                name = fileName
              } else if let imageURL = info[.imageURL] as? URL {
                  name = imageURL.lastPathComponent
              }

            let data = NSData(data: imageData)
            let size: Double = Double(data.length)

            self.attachmentAsset = AttachmentAsset(name: name, image: image, data: imageData, ext: ext, url: nil, size: size / 1048576)
            self.isPresented = false
        }
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL {
            do {
                let data: Data = try Data(contentsOf: videoURL)
                let ext = FileExtension(rawValue: videoURL.pathExtension.lowercased()) ?? .mov
                let name = videoURL.lastPathComponent
                self.attachmentAsset = AttachmentAsset(name: name, image: nil, data: data, ext: ext, url: videoURL, size: videoURL.fileSizeMB)
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
