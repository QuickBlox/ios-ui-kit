//
//  DialogViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine
import Photos
import QuickBloxLog

public struct AttachmentAsset {
    var image: UIImage?
    var data: Data?
    var type: FileType?
    var ext: FileExtension?
    var url: URL?
    var size: Double
}

public protocol DialogViewModelProtocol: QuickBloxUIKitViewModel {
    associatedtype DialogItem: DialogEntity
    
    var audioPlayer: AudioPlayer { get set }
    var targetMessage: DialogItem.MessageItem? { get set }
    var text: String { get set }
    var typing: String { get set }
    var dialog: DialogItem { get set }
    var withAnimation: Bool { get set }
    
    func saveImage(_ image: Image)
    func stopPlayng()
    func startRecording()
    func stopRecording()
    func deleteRecording()
    func sendMessage()
    func handleOnSelect(attachment: AttachmentAsset)
    func playAudio(_ audioData: Data, action: MessageAttachmentAction)
}

open class DialogViewModel: DialogViewModelProtocol {
    @Published public var dialog: Dialog
    @Published public var targetMessage: Message?
    @Published public var text: String = ""
    @Published public var audioPlayer = AudioPlayer()
    @Published public var typing: String = ""
    
    @Published public var deleteDialog: Bool = false
    
    var audioRecorder: AudioRecorder = AudioRecorder()
    
    public var withAnimation: Bool = false
    
    @Published public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    init(dialog: Dialog) {
        self.dialog = dialog
        
        audioPlayer
            .objectWillChange
            .sink { [weak self] (_) in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
    }
    
    public func sync() {
        let syncDialog = SyncDialog(dialogId: dialog.id,
                                    dialogsRepo: RepositoriesFabric.dialogs,
                                    usersRepo: RepositoriesFabric.users,
                                    messageRepo: RepositoriesFabric.messages)
        syncDialog.execute()
            .receive(on: RunLoop.main)
            .sink { dialog in
                self.dialog = dialog
                self.targetMessage = dialog.messages.last
            }
            .store(in: &cancellables)
    }
    
    
    public func handleOnSelect(attachment: AttachmentAsset) {
        guard let  attachmentType = attachment.type else {
            return
        }
        
        if attachmentType == .video,
           let videoData = attachment.data,
           let ext = attachment.ext {
            Task {
                let uploadFile = UploadFile(data: videoData,
                                            ext: ext,
                                            name: "Video.\(ext)",
                                            repo: RepositoriesFabric.files)
                let file = try await uploadFile.execute()
                
                let message = Message(dialogId: dialog.id,
                                      text: "[Attachment]",
                                      type: .chat,
                                      fileInfo: file.info)
                let sendMessage = SendMessage(message: message,
                                              messageRepo: RepositoriesFabric.messages)
                try await sendMessage.execute()
            }
        } else if attachmentType == .image,
                  let uiImage = attachment.image {
            
            let ext = attachment.ext ?? .png
            
            let newImage = uiImage.fixOrientation()
            
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
            
            // create smaller image
            UIGraphicsBeginImageContext(newSize)
            
            newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            
            guard let imageData = resizedImage?.pngData() else {
                return
            }
            
            Task {
                let uploadFile = UploadFile(data: imageData,
                                            ext: .png,
                                            name: "Image.\(ext)",
                                            repo: RepositoriesFabric.files)
                let file = try await uploadFile.execute()
                
                let message = Message(dialogId: dialog.id,
                                      text: "[Attachment]",
                                      type: .chat,
                                      fileInfo: file.info)
                let sendMessage = SendMessage(message: message,
                                              messageRepo: RepositoriesFabric.messages)
                try await sendMessage.execute()
            }
        } else if attachmentType == .file,
                  let url = attachment.url {
            let ext = FileExtension(rawValue: url.pathExtension.lowercased()) ?? .pdf
            var fileData: Data? {
                didSet {
                    if let fileData {
                        Task {
                            let uploadFile = UploadFile(data: fileData,
                                                        ext: ext,
                                                        name: "File.\(ext)",
                                                        repo: RepositoriesFabric.files)
                            let file = try await uploadFile.execute()
                            
                            let message = Message(dialogId: dialog.id,
                                                  text: "[Attachment]",
                                                  type: .chat,
                                                  fileInfo: file.info)
                            let sendMessage = SendMessage(message: message,
                                                          messageRepo: RepositoriesFabric.messages)
                            try await sendMessage.execute()
                        }
                    }
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data: Data = try Data(contentsOf: url)
                    
                    DispatchQueue.main.async {
                        fileData = data
                    }
                } catch {
                    print("Unable to load data: \(error)")
                }
            }
        }
    }
    
    
    //MARK: - Messages
    public func sendMessage() {
        
        if let voiceMessage = audioRecorder.audioRecording {
            let name = "\(voiceMessage.createdAt)"
            
            Task {
                let data = try Data(contentsOf: voiceMessage.audioURL)
                let uploadFile = UploadFile(data: data,
                                            ext: .m4a,
                                            name: name + ".m4a",
                                            repo: RepositoriesFabric.files)
                let file = try await uploadFile.execute()
                
                let message = Message(dialogId: dialog.id,
                                      text: "[Attachment]",
                                      type: .chat,
                                      fileInfo: file.info)
                let sendMessage = SendMessage(message: message,
                                              messageRepo: RepositoriesFabric.messages)
                try await sendMessage.execute()
                audioRecorder.delete()
            }
        }
        
        if text.isEmpty == false {
            let message = Message(dialogId: dialog.id,
                                  text: text,
                                  type: .chat)
            
            let sendMessage = SendMessage(message: message,
                                          messageRepo: RepositoriesFabric.messages)
            
            Task {
                try await sendMessage.execute()
            }
            text = ""
        }
    }
    
    public func saveImage(_ image: Image) {
        
    }
}

// Audio
public extension DialogViewModel {
    func startRecording() {
        audioRecorder.start()
    }
    
    func stopRecording() {
        audioRecorder.stop()
    }
    
    func deleteRecording() {
        audioRecorder.delete()
    }
    
    func playAudio(_ audioData: Data, action: MessageAttachmentAction) {
        if action == .play {
            if audioPlayer.isPlaying == false {
                audioPlayer.startPlayback(audio: audioData)
            }
        } else if action == .stop {
            if audioPlayer.isPlaying == true {
                audioPlayer.stopPlayback()
            }
        }
    }
    
    func stopPlayng() {
        if audioPlayer.isPlaying == true {
            audioPlayer.stopPlayback()
        }
    }
}

extension MessageEntity {
    var isAttachmentMessage: Bool {
        return fileInfo != nil
    }
    
    func fileIsKinfOf(type expected: FileType) -> Bool {
        if isAttachmentMessage,
           let type = fileInfo?.ext.type,
           type == expected {
            return true
        }
        return false
    }
    
    var isAudioMessage: Bool {
        fileIsKinfOf(type: .audio)
    }
    
    var isVideoMessage: Bool {
        fileIsKinfOf(type: .video)
    }
    
    var isImageMessage: Bool {
        fileIsKinfOf(type: .image)
    }
    
    var isPDFMessage: Bool {
        fileIsKinfOf(type: .file)
    }
    
    var isGIFMessage: Bool {
        fileIsKinfOf(type: .gif)
    }
    
    var isChat: Bool {
        if isNotification == true || type != .divider {
            return false
        }
        return true
    }
    
    var isNotification: Bool {
        return eventType != .message
    }
}

struct Key {
    static let dialogId = "dialog_id"
    static let newOccupantsIds = "new_occupants_ids"
    static let saveToHistory = "save_to_history"
    static let dateDividerKey = "kQBDateDividerCustomParameterKey"
    static let forwardedMessage = "origin_sender_name"
    static let attachmentSize = "size"
    static let notificationType = "notification_type"
    static let userID = "user_id"
    static let today = "Today"
    static let yesterday = "Yesterday"
}

enum NotificationType : String {
    case createGroupDialog = "1"
    case addUsersToGroupDialog = "2"
    case leaveGroupDialog = "3"
    case startConference = "4"
    case startStream = "5"
}

extension Date {
    func hasSame(_ components: Set<Calendar.Component>, as date: Date, using calendar: Calendar = .autoupdatingCurrent) -> Bool {
        return components.filter { calendar.component($0, from: date) != calendar.component($0, from: self) }.isEmpty
    }
    
    func setupDate() -> String {
        let formatter = DateFormatter()
        var dateString = ""
        if Calendar.current.isDateInToday(self) == true {
            formatter.dateFormat = "HH:mm"
            dateString = formatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) == true {
            dateString = "Yesterday"
        } else if self.hasSame([.year], as: Date()) == true {
            formatter.dateFormat = "d MMM"
            dateString = formatter.string(from: self)
        } else {
            formatter.dateFormat = "d.MM.yy"
            var anotherYearDate = formatter.string(from: self)
            if (anotherYearDate.hasPrefix("0")) {
                anotherYearDate.remove(at: anotherYearDate.startIndex)
            }
            dateString = anotherYearDate
        }
        return dateString
    }
}

extension Date
{
    func toString(dateFormat format: String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
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
              let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: space, bitmapInfo: cgImage.bitmapInfo.rawValue)  else {
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
}
