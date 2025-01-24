//
//  Utils.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxData
import QuickBloxLog
import SwiftUI
import Photos
import PDFKit

private func getFile<T:FileEntity, R:FilesRepositoryProtocol>(useCase: GetFile<T,R>, priority: TaskPriority) async throws -> T {
    
    let task: Task<T, Error> = Task(priority: priority) {
        return try await useCase.execute()
    }
    
    let result = await task.result
    
    switch result {
        case .success(let file):
            return file
        case .failure(let error):
            prettyLog(label: "getFile with prioriy \(priority)", error)
            throw error
    }
}

//MARK: DialogEntity files
extension DialogEntity {
    
    func removeAvatar() {
        let imageCache = ThumbnailImageCache.shared
        if imageCache.imageFromCache(id) != nil {
            imageCache.removeImage(for: id)
        }
    }
    
    func privateAvatar(scale: DialogThumbnailSize) async throws -> Image {
        if QuickBloxUIKit.previewAware {  return placeholder }

        let filesRepo = RepositoriesFabric.files
        
        let imageCache = ThumbnailImageCache.shared
        
        var path: String
        
        let usersRepo = RepositoriesFabric.users
        guard let userId = participantsIds.filter({ isOwnedByCurrentUser == true ? $0 != ownerId : $0 == ownerId}).first else {
            return placeholder
        }
        let getUser = GetUser(id: userId, repo: usersRepo)
        let user = try await getUser.execute()
        if user.avatarPath.isEmpty { return placeholder }
        path = user.avatarPath
        let thumbnailKey: String = user.id + "@" + scale.rawValue + "_" + path
        if let uiImage = imageCache.imageFromCache(thumbnailKey) {
            return Image(uiImage: uiImage)
        }
        
        
        let useCase = GetFile<File, FilesRepository>(id: path,
                                                     repo: filesRepo)
        try Task.checkCancellation()
        let file = try await getFile(useCase: useCase, priority: .high)
        try Task.checkCancellation()
        let size = UserThumbnailScale.avatar3x.size
        guard let uiImage = UIImage(data: file.data)?
            .cropToRect()
            .resize(to: size) else {
            let info = "Dialog avatar image data is incorrect"
            throw RepositoryException.incorrectData(info)
        }
        imageCache.store(uiImage, for: thumbnailKey)
        return Image(uiImage: uiImage)
    }
    
    func avatar(scale: DialogThumbnailSize) async throws -> Image {
        if QuickBloxUIKit.previewAware {  return placeholder }
        
        var thumbnailKey: String = ""
        
        let filesRepo = RepositoriesFabric.files
        
        let imageCache = ThumbnailImageCache.shared
        
        var path: String
        switch type {
        case .group, .public:
            if photo.isEmpty {
                return placeholder
            }
            path = photo
            if path.hasPrefix("http"),
               let url = URL(string: path),
               let last = url.pathComponents.last {
                let uuid = last.components(separatedBy: ".").first
                path = uuid ?? last
            }
            thumbnailKey = id + "@" + scale.rawValue + "_" + path
            if let uiImage = imageCache.imageFromCache(thumbnailKey) {
                return Image(uiImage: uiImage)
            }
        case .private, .unknown:
            let usersRepo = RepositoriesFabric.users
            guard let userId = participantsIds.filter({ isOwnedByCurrentUser == true ? $0 != ownerId : $0 == ownerId}).first else {
                return placeholder
            }
            let getUser = GetUser(id: userId, repo: usersRepo)
            let user = try await getUser.execute()
            if user.avatarPath.isEmpty { return placeholder }
            path = user.avatarPath
            thumbnailKey = user.id + "@" + scale.rawValue + "_" + path
            if let uiImage = imageCache.imageFromCache(thumbnailKey) {
                return Image(uiImage: uiImage)
            }
        }
        
        let useCase = GetFile<File, FilesRepository>(id: path,
                                                     repo: filesRepo)
        try Task.checkCancellation()
        let file = try await getFile(useCase: useCase, priority: .high)
        try Task.checkCancellation()
        let size = UserThumbnailScale.avatar3x.size
        guard let uiImage = UIImage(data: file.data)?
            .cropToRect()
            .resize(to: size) else {
            let info = "Dialog avatar image data is incorrect"
            throw RepositoryException.incorrectData(info)
        }
        imageCache.store(uiImage, for: thumbnailKey)
        return Image(uiImage: uiImage)
    }
    
    func attachment(size: CGSize) async throws -> (name: String, image: Image?, placeholder: Image)? {
        do {
            if QuickBloxUIKit.previewAware, id.isEmpty {  return nil }
            
            let repo = RepositoriesFabric.messages
            
            if lastMessage.id.isEmpty { return nil }

            var attachmentId: String
            if let old = messages.last,
               old.id == lastMessage.id {
                if let id = old.fileInfo?.id {
                    attachmentId = id
                } else { return nil }
            } else {
                try Task.checkCancellation()
                let getMessage = GetMessage(id: lastMessage.id, dialogId: id, repo: repo)
                let new = try await getMessage.execute()
                if let id = new.fileInfo?.id {
                    attachmentId = id
                } else { return nil }
            }
            
            let filesRepo = RepositoriesFabric.files
            
            let useCase = GetFile<File, FilesRepository>(id: attachmentId, repo: filesRepo)
            try Task.checkCancellation()
            let file = try await getFile(useCase: useCase, priority: .low)
            try Task.checkCancellation()
            let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.lastMessage
            let imageCache = ThumbnailImageCache.shared
            
            let fileName = file.info.ext.name
            switch file.info.ext.type {
            case .audio:
                return (fileName, nil, settings.audioPlaceholder)
            case .video:
                return (fileName, nil, settings.videoPlaceholder)
            case .image:
                if let uiImage = imageCache.imageFromCache(id + "1x") {
                    return (fileName, Image(uiImage: uiImage), settings.imagePlaceholder)
                }
                guard let uiImage = UIImage(data: file.data)?
                    .cropToRect()
                    .resize(to: size) else {
                    return (fileName, nil, settings.imagePlaceholder)
                }
                imageCache.store(uiImage, for: id + "1x")
                return (fileName, Image(uiImage: uiImage), settings.imagePlaceholder)
            case .file:
                return (fileName, nil, settings.filePlaceholder)
            }
            
        } catch { return nil }
    }
    
    var placeholder: Image {
        let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
        switch type {
        case .public: return settings.avatar.publicAvatar
        case .group: return settings.avatar.groupAvatar
        case .private, .unknown: return settings.avatar.privateAvatar
        }
    }
}

extension DialogEntity {
    public var displayedMessages: [MessageItem]  {
        var dividers: Set<Date> = []
        var displayed: [MessageItem] = []
        for message in messages {
            let divideDate = Calendar.current.startOfDay(for: message.date)
            if dividers.contains(divideDate) {
                if displayed.contains(where: { $0.id == message.id && $0.relatedId == message.relatedId }) == false {
                    displayed.append(prepareMessage(message))
                }
                continue
            }
            dividers.insert(divideDate)
            
            let divideText = divideText(divideDate)
            let dividerMessage = MessageItem(id: divideText,
                                             dialogId: id,
                                             text: divideText,
                                             date: divideDate,
                                             type: .divider)
            
            if displayed.contains(where: { $0.id == dividerMessage.id }) == false {
                displayed.append(dividerMessage)
            }
            if displayed.contains(where: { $0.id == message.id && $0.relatedId == message.relatedId }) == false {
                displayed.append(prepareMessage(message))
            }
        }
        return displayed
    }
    
    private func prepareMessage(_ message: MessageItem) -> MessageItem {
        let stringUtils = QuickBloxUIKit.settings.dialogScreen.stringUtils
        
        if message.isNotification == true {
            var update = message
            update.text = stringUtils.notificationText(message.text)
            return update
        } else {
            return message
        }
    }
    
    private func divideText(_ divideDate: Date) -> String {
        let stringUtils = QuickBloxUIKit.settings.dialogScreen.stringUtils
        
        let formatter = DateFormatter()
        if divideDate.hasSame([.year], as: Date()) == true {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM, yyyy"
        }
        
        if Calendar.current.isDateInToday(divideDate) == true {
            return  stringUtils.today
        } else if Calendar.current.isDateInYesterday(divideDate) == true {
            return  stringUtils.yesterday
        } else {
            return formatter.string(from: divideDate)
        }
    }
}

extension MessageEntity {
    var userName: String {
        get async throws {
            if QuickBloxUIKit.previewAware {  return "Name" }
            
            let usersRepo = RepositoriesFabric.users
            let getUser = GetUser(id: userId, repo: usersRepo)
            let user = try await getUser.execute()
            if user.name.isEmpty { return user.id }
            
            return user.name
        }
    }
    
    func avatar(scale: UserThumbnailScale) async throws -> Image {
        if QuickBloxUIKit.previewAware {  return placeholder }
        
        let usersRepo = RepositoriesFabric.users
        let getUser = GetUser(id: userId, repo: usersRepo)
        let user = try await getUser.execute()
        
        if user.avatarPath.isEmpty { return placeholder }
        
        let thumbnailKey: String = user.id + "@" + scale.rawValue + "_" + user.avatarPath
        
        let imageCache = ThumbnailImageCache.shared
        if let uiImage = imageCache.imageFromCache(thumbnailKey) {
            return Image(uiImage: uiImage)
        }
    
        let filesRepo = RepositoriesFabric.files
        let useCase = GetFile<File, FilesRepository>(id: user.avatarPath,
                                                     repo: filesRepo)
        try Task.checkCancellation()
        let file = try await getFile(useCase: useCase, priority: .high)
        try Task.checkCancellation()
        guard let uiImage = UIImage(data: file.data)?
            .cropToRect()
            .resize(to: scale.size) else {
            let info = "Message avatar image data is incorrect"
            throw RepositoryException.incorrectData(info)
        }
        imageCache.store(uiImage, for: thumbnailKey)
        return Image(uiImage: uiImage)
    }
    
    var placeholder: Image {
        return QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    }
    
    func file(size: CGSize?) async throws -> (type: String, image: UIImage?, url: URL?)?  {
        do {
            if QuickBloxUIKit.previewAware, id.isEmpty {  return nil }
            
            guard let file = fileInfo else { return nil }
            
            let filesRepo = RepositoriesFabric.files
            
            let useCase = GetFile<File, FilesRepository>(id: file.id,
                                                         repo: filesRepo)
            try Task.checkCancellation()
            let uploaded = try await getFile(useCase: useCase, priority: .low)
            try Task.checkCancellation()
            let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
            let imageCache = ThumbnailImageCache.shared
            
            switch uploaded.info.ext.type {
            case .audio:
                let localURL = uploaded.temporaryUrl
                return (uploaded.info.name, UIImage().withTintColor(.blue, renderingMode: .alwaysTemplate), localURL)
            case .video:
                let localURL = uploaded.temporaryUrl
                if let cachedImage = imageCache.imageFromCache(id) {
                    return (uploaded.info.name, cachedImage, localURL)
                }
                var image: UIImage?
                let uiImage = try await localURL.getThumbnailImage()
                if size != nil {
                    let imageSize = settings.imageSize(isPortrait: uiImage.size.height > uiImage.size.width)
                    let resized = uiImage.crop(to: imageSize)
                    imageCache.store(resized, for: id)
                    image = resized
                } else {
                    image = uiImage
                }
                return (uploaded.info.name, image, localURL)
            case .image:
                guard let uiImage = UIImage(data: uploaded.data) else {
                    return (uploaded.info.name, nil, nil)
                }
                let localURL = uploaded.temporaryUrl
                if size != nil {
                    if let cachedImage = imageCache.imageFromCache(id) {
                        return (uploaded.info.name, cachedImage, localURL)
                    }
                    let imageSize = settings.imageSize(isPortrait: uiImage.size.height > uiImage.size.width)
                    let resized = uiImage.crop(to: imageSize)
                    imageCache.store(resized, for: id)
                    return (uploaded.info.name, resized ,localURL)
                }
                return (uploaded.info.name, uiImage ,localURL)
            case .file:
                let localURL = uploaded.temporaryUrl
                return (uploaded.info.name, nil, localURL)
            }
        } catch {
            return nil
        }
    }
    
    var audioFile: (type: String, data: Data?, url: URL?, time: TimeInterval)? {
        get async throws {
            do {
                if QuickBloxUIKit.previewAware, id.isEmpty {  return nil }
                
                guard let file = fileInfo else { return nil }
                
                let filesRepo = RepositoriesFabric.files
                
                let useCase = GetFile<File, FilesRepository>(id: file.id,
                                                             repo: filesRepo)
                try Task.checkCancellation()
                let uploaded = try await getFile(useCase: useCase, priority: .low)
                try Task.checkCancellation()

                switch uploaded.info.ext.type {
                case .audio:
                    let localURL = uploaded.temporaryUrl
                    let asset = AVURLAsset(url: localURL, options: nil)
                    let duration = try await asset.load(.duration)
                    let time: TimeInterval = duration.seconds.rounded()
                    return (uploaded.info.name, uploaded.data, localURL, time)
                default:
                    return nil
                }
            } catch {
                return nil
            }
        }
    }
}

private extension File {
    var temporaryUrl: URL {
        let localURL = URL(fileURLWithPath:NSTemporaryDirectory())
            .appendingPathComponent(info.id + info.name)
        let _ = (try? data.write(to: localURL, options: [.atomic])) != nil
        return localURL
    }
}

extension UserEntity {
    func avatar(scale: UserThumbnailScale) async throws -> Image {
        if QuickBloxUIKit.previewAware {  return placeholder }
        
        if avatarPath.isEmpty { return placeholder }
        
        let thumbnailKey: String = id + "@" + scale.rawValue + "_" + avatarPath
        
        let imageCache = ThumbnailImageCache.shared
        if let uiImage = imageCache.imageFromCache(thumbnailKey) {
            return Image(uiImage: uiImage)
        }
        
        let filesRepo = RepositoriesFabric.files
        let useCase = GetFile<File, FilesRepository>(id: avatarPath,
                                                     repo: filesRepo)
        try Task.checkCancellation()
        let file = try await getFile(useCase: useCase, priority: .high)
        try Task.checkCancellation()
        guard let uiImage = UIImage(data: file.data)?
            .cropToRect()
            .resize(to: scale.size) else {
            let info = "User avatar image data is incorrect"
            throw RepositoryException.incorrectData(info)
        }
        imageCache.store(uiImage, for: thumbnailKey)
        return Image(uiImage: uiImage)
    }
    
    var placeholder: Image {
        return QuickBloxUIKit.settings.createDialogScreen.userRow.avatar
    }
}


extension File {
    var placeholderPreview: Image {
        get async {
            let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.lastMessage
            
            switch info.ext.type {
            case .audio:
                return settings.audioPlaceholder
            case .video:
                return settings.videoPlaceholder
            case .image:
                return settings.imagePlaceholder
            case .file:
                return settings.filePlaceholder
            }
        }
    }
    
    var thumbnailForPDF: Image {
        get throws {
            guard let pdfURL = info.path.localURL else {
                let info = "Thumbnail For PDF, invalid url"
                throw RepositoryException.incorrectData(info)
            }
            
            guard let pdfDocument = PDFDocument(url: pdfURL) else {
                throw NSError(domain: "PDFError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load PDF document."])
            }
            
            guard let firstPage = pdfDocument.page(at: 0) else {
                throw NSError(domain: "PDFError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve first page."])
            }
            
            return renderPageAsImage(page: firstPage)
        }
    }

    func renderPageAsImage(page: PDFPage) -> Image {
        let pageBounds = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageBounds.size)
        
        let thumbnailImage = renderer.image { _ in
            UIColor.white.set()
            UIRectFill(CGRect(origin: .zero, size: pageBounds.size))
            
            let ctx = UIGraphicsGetCurrentContext()!
            ctx.saveGState()
            
            ctx.translateBy(x: 0.0, y: pageBounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
            ctx.concatenate(page.transform(for: .mediaBox))
            
            page.draw(with: .mediaBox, to: ctx)
            
            ctx.restoreGState()
        }
        
        return Image(uiImage: thumbnailImage)
    }
}

extension URL {
    func getThumbnailImage() async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            self.getThumbnailImage { image, error in
                guard let image = image else {
                    continuation.resume(throwing: error ?? RepositoryException.incorrectData("Thumbnail Image"))
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
                                                         
    func getThumbnailImage(completion: @escaping ((_ image: UIImage?, _ error: Error?) -> Void)) {
        if let document = CGPDFDocument(self as CFURL),
           let page = document.page(at: 1) {
            let pageRect = page.getBoxRect(.mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let image = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                
                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                ctx.cgContext.drawPDFPage(page)
            }
            completion(image, nil)
            return
        }
        DispatchQueue.global().async {
            if self.pathExtension.lowercased() == "gif" {
                guard let imageData = try? Data(contentsOf: self),
                      let image = UIImage(data: imageData) else {
                    DispatchQueue.main.async {
                        completion(nil, NSError(domain: "InvalidGIF", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to load GIF"]))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(image, nil)
                }
                return
            }
            
            let avAsset = AVAsset(url: self)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: avAsset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage, nil)
                }
            } catch {
                prettyLog(error)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}

extension Double {
    func truncate(to places: Int) -> Double {
        return Double(Int((pow(10, Double(places)) * self).rounded())) / pow(10, Double(places))
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        var transformOrientation: CGAffineTransform = .identity
        let width = size.width
        let height = size.height
        if imageOrientation == .up {
            return self
        }
        
        if imageOrientation == .down || imageOrientation == .downMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: height)
            transformOrientation = transformOrientation.rotated(by: .pi)
        } else if imageOrientation == .left || imageOrientation == .leftMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: 0)
            transformOrientation = transformOrientation.rotated(by: .pi/2)
        } else if imageOrientation == .right || imageOrientation == .rightMirrored {
            transformOrientation = transformOrientation.translatedBy(x: 0, y: height)
            transformOrientation = transformOrientation.rotated(by: -(.pi/2))
        }
        
        if imageOrientation == .upMirrored || imageOrientation == .downMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: 0)
            transformOrientation = transformOrientation.scaledBy(x: -1, y: 1)
        } else if imageOrientation == .leftMirrored || imageOrientation == .rightMirrored {
            transformOrientation = transformOrientation.translatedBy(x: height, y: 0)
            transformOrientation = transformOrientation.scaledBy(x: -1, y: 1)
        }
        
        guard let cgImage = self.cgImage, let space = cgImage.colorSpace,
              let context = CGContext(data: nil,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: cgImage.bitsPerComponent,
                                      bytesPerRow: 0,
                                      space: space,
                                      bitmapInfo: cgImage.bitmapInfo.rawValue)  else {
            return UIImage()
        }
        context.concatenate(transformOrientation)
        
        if imageOrientation == .left ||
            imageOrientation == .leftMirrored ||
            imageOrientation == .right ||
            imageOrientation == .rightMirrored {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        } else {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        guard let newCGImage = context.makeImage() else {
            return UIImage()
        }
        let image = UIImage(cgImage: newCGImage)
        
        return image
    }
    
    func cropToRect() -> UIImage {
        let sideLength = min(
            size.width,
            size.height
        )
        let source = size
        let xOffset = (source.width - sideLength) / 2.0
        let yOffset = (source.height - sideLength) / 2.0
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: sideLength,
            height: sideLength
        ).integral
        
        guard let sourceCGImage = cgImage else {
            return self
        }
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        let croppedUIImage = UIImage(
            cgImage: croppedCGImage,
            scale: imageRendererFormat.scale,
            orientation: imageOrientation
        )
        return croppedUIImage
    }
    
    func crop(to targetSize: CGSize) -> UIImage {
        let source = size
        let xOffset = (source.width - targetSize.width) / 2.0
        let yOffset = (source.height - targetSize.height) / 2.0
        let cropRect = CGRect(
            x: xOffset,
            y: yOffset,
            width: targetSize.width,
            height: targetSize.height
        ).integral
        
        guard let sourceCGImage = cgImage else {
            return self
        }
        let croppedCGImage = sourceCGImage.cropping(
            to: cropRect
        )!
        let croppedUIImage = UIImage(
            cgImage: croppedCGImage,
            scale: imageRendererFormat.scale,
            orientation: imageOrientation
        )
        return croppedUIImage
    }
    
    func resize(to targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?
        CGSize(width: size.width * heightRatio,
               height: size.height * heightRatio)
        : CGSize(width: size.width * widthRatio,
                 height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    static func animatedImage(from url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        var images: [UIImage] = []
        let count = CGImageSourceGetCount(source)
        
        var scaleFactor = 1.0

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                // Get the image's original size
                let imageSize = CGSize(width: CGFloat(cgImage.width),
                                       height: CGFloat(cgImage.height))
                
                // Determine if the image is portrait or landscape
                let isPortrait = imageSize.height > imageSize.width

                // Define the target size (portrait or landscape)
                let targetSize = isPortrait ? CGSize(width: 160.0, height: 240.0) : CGSize(width: 240.0, height: 160.0)
                
                // Check if the image's size exceeds the target size
                if imageSize.width > targetSize.width || imageSize.height > targetSize.height {
                    // Calculate the scaling factor to fit the image within the target size while preserving the aspect ratio
                    let scaleFactor = min(targetSize.width / imageSize.width, targetSize.height / imageSize.height)
                    
                    // Resize using UIGraphicsImageRenderer to control the final dimensions
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor))
                    let resizedImage = renderer.image { context in
                        context.cgContext.translateBy(x: 0, y: imageSize.height * scaleFactor)
                        context.cgContext.scaleBy(x: 1, y: -1)
                        context.cgContext.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)))
                    }
                    
                    images.append(resizedImage)
                } else {
                    // No resizing needed, just append the original image
                    let originalImage = UIImage(cgImage: cgImage)
                    images.append(originalImage)
                }
            }
        }

        let duration = Double(count) * 0.1 // Adjust frame duration if needed
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
