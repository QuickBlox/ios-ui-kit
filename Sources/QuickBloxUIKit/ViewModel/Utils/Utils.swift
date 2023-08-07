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
        if imageCache.imageFromCache(id) != nil {
            imageCache.removeImage(for: id)
        }
    }
    
    var avatar: Image {
        get async throws {
            if QuickBloxUIKit.previewAware {  return placeholder }
            
            if let uiImage = imageCache.imageFromCache(id) {
                return Image(uiImage: uiImage)
            }
            
            let filesRepo = RepositoriesFabric.files
            var path: String
            switch type {
            case .group, .public:
                if photo.isEmpty || photo == "null" { return placeholder }
                path = photo
                if path.hasPrefix("http"),
                   let url = URL(string: path),
                   let last = url.pathComponents.last {
                    let uuid = last.components(separatedBy: ".").first
                    path = uuid ?? last
                }
            case .private, .unknown:
                let usersRepo = RepositoriesFabric.users
                guard let userId = participantsIds.first else {
                    return placeholder
                }
                let getUser = GetUser(id: userId, repo: usersRepo)
                let user = try await getUser.execute()
                if user.avatarPath.isEmpty { return placeholder }
                path = user.avatarPath
            }
            
            let useCase = GetFile<File, FilesRepository>(id: path,
                                                         repo: filesRepo)
            try Task.checkCancellation()
            let file = try await getFile(useCase: useCase, priority: .high)
            try Task.checkCancellation()
            let size = QuickBloxUIKit.settings.dialogScreen.avatarSize.avatar3x
            guard let uiImage = UIImage(data: file.data)?
                .cropToRect()
                .resize(to: size) else {
                let info = "Dialog avatar image data is incorrect"
                throw RepositoryException.incorrectData(description: info)
            }
            imageCache.store(uiImage, for: id)
            return Image(uiImage: uiImage)
        }
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
            
            let fileName = file.info.ext.name
            switch file.info.ext.type {
            case .audio:
                return (fileName, nil, settings.audioPlaceholder)
            case .video:
                return (fileName, nil, settings.videoPlaceholder)
            case .image, .gif:
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

private extension FileExtension {
    var name: String {
        switch type {
        case .image: return "Image.\(self)"
        case .video: return "Video.\(self)"
        case .audio: return "Audio.\(self)"
        case .file: return "File.\(self)"
        case .gif: return "GIF.\(self)"
        }
    }
}

extension DialogEntity {
    public var displayedMessages: [MessageItem]  {
        var displayed: [MessageItem] = []
        var dividers: Set<Date> = []
        var tempMessages: [MessageItem] = []
        for message in messages {
            let divideDate = Calendar.current.startOfDay(for: message.date)
            if dividers.contains(divideDate) {
                if tempMessages.contains(where: { $0.id == message.id }) == false {
                    tempMessages.append(message)
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

            if tempMessages.contains(where: { $0.id == dividerMessage.id }) == false {
                tempMessages.append(dividerMessage)
            }
            if tempMessages.contains(where: { $0.id == message.id }) == false {
                tempMessages.append(message)
            }
        }
        displayed = tempMessages
        return displayed
    }
    
    private func divideText(_ divideDate: Date) -> String {
        let formatter = DateFormatter()
        if divideDate.hasSame([.year], as: Date()) == true {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM, yyyy"
        }
        
        if Calendar.current.isDateInToday(divideDate) == true {
            return  "Today"
        } else if Calendar.current.isDateInYesterday(divideDate) == true {
            return  "Yesterday"
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
    
    func avatar(size: CGSize) async throws -> Image {
        if QuickBloxUIKit.previewAware {  return placeholder }
        
        let usersRepo = RepositoriesFabric.users
        let getUser = GetUser(id: userId, repo: usersRepo)
        let user = try await getUser.execute()
        
        if let uiImage = imageCache.imageFromCache(user.id) {
            return Image(uiImage: uiImage)
        }
        
        if user.avatarPath.isEmpty { return placeholder }
        
        let filesRepo = RepositoriesFabric.files
        let useCase = GetFile<File, FilesRepository>(id: user.avatarPath,
                                                     repo: filesRepo)
        try Task.checkCancellation()
        let file = try await getFile(useCase: useCase, priority: .high)
        try Task.checkCancellation()
        guard let uiImage = UIImage(data: file.data)?
            .cropToRect()
            .resize(to: size) else {
            let info = "Message avatar image data is incorrect"
            throw RepositoryException.incorrectData(description: info)
        }
        imageCache.store(uiImage, for: user.id)
        return Image(uiImage: uiImage)
    }
    
    var placeholder: Image {
        return QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    }
    
    func file(size: CGSize?) async throws -> (type: String, image: Image?, url: URL?)?  {
        do {
            if QuickBloxUIKit.previewAware, id.isEmpty {  return nil }
            
            guard let file = fileInfo else { return nil }
            
            let filesRepo = RepositoriesFabric.files
            
            let useCase = GetFile<File, FilesRepository>(id: file.id,
                                                         repo: filesRepo)
            try Task.checkCancellation()
            let uploaded = try await getFile(useCase: useCase, priority: .low)
            try Task.checkCancellation()
            let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.lastMessage
            switch uploaded.info.ext.type {
            case .audio:
                guard let localURL = uploaded.info.path.localURL else { return nil }
                return (uploaded.info.name, nil, localURL)
            case .video:
                let localURL = uploaded.temporaryUrl
                if let cachedImage = imageCache.imageFromCache(id) {
                    return (uploaded.info.name, Image(uiImage: cachedImage), localURL)
                }
                var image: Image = settings.videoPlaceholder
                if let uiImage = await localURL.getThumbnailImage() {
                    if let size {
                        let resized = uiImage.resize(to: size)
                        imageCache.store(resized, for: id)
                        image = Image(uiImage: resized)
                    } else {
                        image = Image(uiImage: uiImage)
                    }
                }
                return (uploaded.info.name, image, localURL)
            case .image, .gif:
                guard let uiImage = UIImage(data: uploaded.data) else {
                    return (uploaded.info.name, settings.imagePlaceholder, nil)
                }
                if let size {
                    if let cachedImage = imageCache.imageFromCache(id) {
                        return (uploaded.info.name, Image(uiImage: cachedImage), nil)
                    }
                    let resized = uiImage.resize(to: size)
                    imageCache.store(resized, for: id)
                    let image = Image(uiImage: resized)
                    return (uploaded.info.name, image ,nil)
                }
                return (uploaded.info.name, Image(uiImage: uiImage) ,nil)
            case .file:
                let localURL = uploaded.temporaryUrl
                return (uploaded.info.name,
                        settings.filePlaceholder,
                        localURL)
            }
        } catch { return nil }
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
            } catch { return nil }
        }
    }
}

private extension File {
    var temporaryUrl: URL {
        let localURL = URL(fileURLWithPath:NSTemporaryDirectory())
            .appendingPathComponent(info.name)
        let _ = (try? data.write(to: localURL, options: [.atomic])) != nil
        return localURL
    }
}

extension UserEntity {
    
    func avatar(size: CGSize) async throws -> Image {
        if QuickBloxUIKit.previewAware {  return placeholder }
        
        if avatarPath.isEmpty { return placeholder }
        
        let filesRepo = RepositoriesFabric.files
        let useCase = GetFile<File, FilesRepository>(id: avatarPath,
                                                     repo: filesRepo)
        try Task.checkCancellation()
        let file = try await getFile(useCase: useCase, priority: .high)
        try Task.checkCancellation()
        guard let uiImage = UIImage(data: file.data)?
            .cropToRect()
            .resize(to: size) else {
            let info = "User avatar image data is incorrect"
            throw RepositoryException.incorrectData(description: info)
        }
        return Image(uiImage: uiImage)
    }
    
    var avatar: Image {
        get async throws {
            if QuickBloxUIKit.previewAware {  return placeholder }
            
            if let uiImage = imageCache.imageFromCache(id) {
                return Image(uiImage: uiImage)
            }
            
            if avatarPath.isEmpty { return placeholder }
            
            let filesRepo = RepositoriesFabric.files
            let useCase = GetFile<File, FilesRepository>(id: avatarPath,
                                                         repo: filesRepo)
            try Task.checkCancellation()
            let file = try await getFile(useCase: useCase, priority: .high)
            try Task.checkCancellation()
            let avatarSize = QuickBloxUIKit.settings.dialogNameScreen.avatarSize
            guard let uiImage = UIImage(data: file.data)?
                .cropToRect()
                .resize(to: avatarSize) else {
                let info = "User avatar image data is incorrect"
                throw RepositoryException.incorrectData(description: info)
            }
            imageCache.store(uiImage, for: id)
            return Image(uiImage: uiImage)
        }
    }
    
    var placeholder: Image {
        return QuickBloxUIKit.settings.createDialogScreen.userRow.avatar
    }
}


extension File {
    var preview: Image? {
        get async {
            if QuickBloxUIKit.previewAware, id.isEmpty {  return nil }
            
            guard let url = info.path.localURL else {
                prettyLog(label: "use placeholder, reason", DataSourceException.notFound(description: "getThumbnailImage"))
                return nil
            }
            guard let uiImage = await url.getThumbnailImage() else {
                
                prettyLog(label: "use placeholder, reason", DataSourceException.notFound(description: "getThumbnailImage"))
                return nil
            }
            return Image(uiImage: uiImage)
        }
    }
    
    var placeholderPreview: Image {
        get async {
            let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.lastMessage
            
            switch info.ext.type {
            case .audio:
                return settings.audioPlaceholder
            case .video:
                return settings.videoPlaceholder
            case .image, .gif:
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
                throw RepositoryException.incorrectData(description: info)
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
    func getThumbnailImage() async -> UIImage? {
        return await withCheckedContinuation({
            (continuation: CheckedContinuation<UIImage?, Never>) in
            self.getThumbnailImage { image in
                continuation.resume(returning: image)
            }
        })
    }
                                                         
    func getThumbnailImage(completion: @escaping ((_ image: UIImage?) -> Void)) {
    
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
            completion(image)
            return
        }
        DispatchQueue.global().async {
            let avAsset = AVAsset(url: self)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: avAsset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
            } catch {
                prettyLog(error)
                DispatchQueue.main.async {
                    completion(nil)
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
