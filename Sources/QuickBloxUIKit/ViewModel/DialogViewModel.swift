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
import QBAIRephrase

public enum Role {
    case owner, opponent
}

public struct AttachmentAsset {
    var name: String
    var image: UIImage?
    var data: Data?
    var ext: FileExtension
    var url: URL?
    var size: Double
}

public struct TranslationInfo {
    var id: String = ""
    var waiting: Bool = false
}

public struct PermissionInfo {
    var mediaType: AVMediaType
    var notGranted: Bool = false
}

public protocol PermissionProtocol {
    var permissionNotGranted: PermissionInfo { get set }
    
    func openSettings()
    func requestPermission(_ mediaType: AVMediaType, completion: @escaping (_ granted: Bool) -> Void)
}

public protocol DialogViewModelProtocol: QuickBloxUIKitViewModel, PermissionProtocol  {
    associatedtype DialogItem: DialogEntity
    
    var audioPlayer: AudioPlayer { get set }
    var targetMessage: DialogItem.MessageItem? { get set }
    var dialog: DialogItem { get set }
    var withAnimation: Bool { get set }
    var typing: String { get set }
    var waitingAnswer: Bool { get set }
    var aiAnswer: String { get set }
    var waitingTranslation: TranslationInfo { get set }
    var permissionNotGranted: PermissionInfo { get set }
    var isProcessing: Bool { get set }
    var tones: [QBAIRephrase.ToneInfo] { get set }
    
    func stopPlayng()
    func startRecording()
    func stopRecording()
    func deleteRecording()
    func sendMessage(_ text: String)
    func handleOnSelect(attachment: AttachmentAsset)
    func handleOnAppear(_ message: DialogItem.MessageItem)
    func playAudio(_ audioData: Data, action: MessageAttachmentAction)
    func sendStopTyping()
    func sendTyping()
    func unsubscribe()
    func applyAIAnswerAssist(_ message: DialogItem.MessageItem)
    func applyAITranslate(_ message: DialogItem.MessageItem)
    func applyAIRephrase(_ tone: QBAIRephrase.ToneInfo, content: String, needToUpdate: Bool)
    func openSettings()
    func requestPermission(_ mediaType: AVMediaType, completion: @escaping (_ granted: Bool) -> Void)
}

public extension QBAIRephrase.ToneInfo {
    static let original = QBAIRephrase.ToneInfo(
    name: "Back to original text",
    behavior: "",
    icon: "✅"
  )
}

open class DialogViewModel: DialogViewModelProtocol {
    
    @Published public var waitingTranslation: TranslationInfo = TranslationInfo()
    @Published public var dialog: Dialog
    @Published public var targetMessage: Message?
    @Published public var audioPlayer = AudioPlayer()
    @Published public var deleteDialog: Bool = false
    @Published public var typing: String = ""
    @Published public var waitingAnswer: Bool = false
    @Published public var aiAnswer: String = ""
    @Published public var permissionNotGranted: PermissionInfo = PermissionInfo(mediaType: .audio)
    @Published public var isProcessing: Bool = false
    
    public var tones: [QBAIRephrase.ToneInfo] = {
        let tones: [any QBAIRephrase.Tone]  =
        [QBAIRephrase.ToneInfo.original] + QuickBloxUIKit.feature.ai.rephrase.tones
        return tones as? [QBAIRephrase.ToneInfo] ?? []
    }()
    
    private var isExistingImage: Bool {
        if dialog.photo == "null" { return false }
        return dialog.photo.isEmpty == false
    }
    
    var audioRecorder: AudioRecorder = AudioRecorder()
    
    public var withAnimation: Bool = false
    
    @Published public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    private let dialogsRepo: DialogsRepository = RepositoriesFabric.dialogs
    private let usersRepo: UsersRepository = RepositoriesFabric.users
    private let permissionsRepo: PermissionsRepository = RepositoriesFabric.permissions
    
    private var syncDialog: SyncDialog<Dialog,
                                       DialogsRepository,
                                       UsersRepository,
                                       MessagesRepository,
                                       Pagination>?
    
    private var typingObserve: TypingObserver<DialogsRepository>!
    private var stopTypingObserve: StopTypingObserver<DialogsRepository>!
    private var updateDialogObserve: UpdateDialogObserver<Dialog, DialogsRepository>!
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    private var typingProvider: TypingProvider
    
    private var isTypingEnable = true
    
    private var rephrasedContent: [QBAIRephrase.ToneInfo: String] = [:]
    
    private var draftAttachmentMessage: Message? = nil
    
    let aiFeatures = QuickBloxUIKit.feature.ai
    
    init(dialog: Dialog) {
        self.dialog = dialog
        
        isTypingEnable = QuickBloxUIKit.settings.dialogScreen.typing.enable
        
        typingProvider = TypingProvider(dialogId: dialog.id, usersRepo: usersRepo)
        
        typingProvider
            .objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] typing in
                if self?.isTypingEnable == true {
                    self?.typing = typing
                }
            }.store(in: &cancellables)
        
        typingObserve = TypingObserver(repo: dialogsRepo,
                                       dialogId: dialog.id)
        stopTypingObserve = StopTypingObserver(dialogsRepo: dialogsRepo,
                                               dialogId: dialog.id)
        updateDialogObserve = UpdateDialogObserver(repo: dialogsRepo,
                                                   dialogId: dialog.id)
        
        typingObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] userId in
                prettyLog(label: "typing user.id", userId)
                if self?.isTypingEnable == true {
                    self?.typingProvider.typingUser(userId)
                }
            }
            .store(in: &cancellables)
        
        stopTypingObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] userId in
                prettyLog(label: "stop typing userId", userId)
                if self?.isTypingEnable == true {
                    self?.typingProvider.stopTypingUser(userId)
                }
            }
            .store(in: &cancellables)
        
        updateDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialogId in
                if dialogId == self?.dialog.id {
                    self?.sync()
                }
            }
        .store(in: &cancellables)
        
        audioPlayer
            .objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] (_) in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        
        QuickBloxUIKit.syncState
            .receive(on: RunLoop.main)
            .sink { [weak self] syncState in
                if syncState == .synced {
                    self?.sync()
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        unsubscribe()
    }
    
    public func unsubscribe() {
        typingObserve = nil
        stopTypingObserve = nil
    }
    
    public func sync() {
        syncDialog = SyncDialog(dialogId: dialog.id,
                                dialogsRepo: dialogsRepo,
                                usersRepo: usersRepo,
                                messageRepo: RepositoriesFabric.messages)
        syncDialog?.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialog in
                if dialog.messages.isEmpty == false {
                    self?.dialog = dialog
                    if let draftAttachmentMessage = self?.draftAttachmentMessage {
                        self?.dialog.messages.append(draftAttachmentMessage)
                    }
                }
                self?.targetMessage = dialog.messages.last
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Typing Current User
    @objc public func sendStopTyping() {
        typingProvider.sendStopTyping()
    }

    public func sendTyping() {
        typingProvider.sendTyping()
    }
    
    public func handleOnSelect(attachment: AttachmentAsset) {
        if attachment.ext.type == .image,
           let uiImage = attachment.image {
            
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
            sendAttachment(withData: imageData, ext: attachment.ext, name: attachment.ext.name)
            
        } else if let data = attachment.data {
            sendAttachment(withData: data, ext: attachment.ext, name: attachment.ext.name)
        }
    }
    
    private func sendAttachment(withData data: Data, ext: FileExtension, name: String) {
        isProcessing = true
        sendStopTyping()
        
        draftAttachmentMessage = Message(dialogId: dialog.id,
                              text: "[Attachment]",
                              isOwnedByCurrentUser: true,
                              type: .chat,
                              fileInfo: FileInfo(id: UUID().uuidString, ext: ext, name: "Draft/Attachment"))
        
        if let draftAttachmentMessage {
            dialog.messages.append(draftAttachmentMessage)
            targetMessage = draftAttachmentMessage
        }
       
        
        Task {
            let uploadFile = UploadFile(data: data,
                                        ext: ext,
                                        name: name,
                                        repo: RepositoriesFabric.files)
            let file = try await uploadFile.execute()
            
            let message = Message(dialogId: dialog.id,
                                  text: attachmentMessageText(file.info),
                                  isOwnedByCurrentUser: true,
                                  type: .chat,
                                  fileInfo: file.info)
            
            let sendMessage = SendMessage(message: message,
                                          messageRepo: RepositoriesFabric.messages)
            try await sendMessage.execute()
            
            draftAttachmentMessage = nil
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.isProcessing = false
            }
        }
    }
    
    private func attachmentMessageText(_ info: FileInfo) -> String {
        return "[Attachment]|\(info.name)|\(info.uid)|\(info.ext.mimeType)"
    }
    
    //MARK: - Messages
    public func sendMessage(_ text: String) {
        sendStopTyping()
        
        if let voiceMessage = audioRecorder.audioRecording {
            let name = "\(voiceMessage.createdAt)"
            
            Task { [weak self] in
                guard let dialogId = self?.dialog.id, let self = self else { return }
                
                let data = try Data(contentsOf: voiceMessage.audioURL)
                //TODO: get extention (.m4a) from the audioRecorder
                let uploadFile = UploadFile(data: data,
                                            ext: .m4a,
                                            name: name + ".m4a",
                                            repo: RepositoriesFabric.files)
                let file = try await uploadFile.execute()
                
                let message = Message(dialogId: dialogId,
                                      text: self.attachmentMessageText(file.info),
                                      type: .chat,
                                      fileInfo: file.info)
                let sendMessage = SendMessage(message: message,
                                              messageRepo: RepositoriesFabric.messages)
                try await sendMessage.execute()
                self.audioRecorder.delete()
            }
        } else if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            let message = Message(dialogId: dialog.id,
                                  text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                                  type: .chat)
            
            let sendMessage = SendMessage(message: message,
                                          messageRepo: RepositoriesFabric.messages)
            
            Task {
                do {
                    try await sendMessage.execute()
                } catch { prettyLog(error) }
            }
        }
    }
    
    public func handleOnAppear(_ message: Message) {
        if dialog.unreadMessagesCount == 0 { return }
        if message.isOwnedByCurrentUser { return }
        if message.isRead { return }
        if message.userId.isEmpty == true { return }
        
        var updatedMessage = message
        updatedMessage.isRead = true
        
        var updated = dialog
        updated.decrementCounter = true
        
        let readMessage = ReadMessage(message: updatedMessage,
                                      messageRepo: RepositoriesFabric.messages,
                                      dialogRepo: dialogsRepo,
                                      dialog: updated)
        Task {
            do {
                try await readMessage.execute()
            } catch {
                prettyLog(error)
            }
        }
    }
    
    //MARK: - AI Features
    public func applyAIAnswerAssist(_ message: DialogItem.MessageItem) {
        waitingAnswer = true
        aiAnswer = ""
        
        let proxyServerURL = aiFeatures.assistAnswer.proxyServerURLPath // proxy Server URL
        let apiKey = aiFeatures.assistAnswer.openAIAPIKey
        
        let messages = filterTextHistory(from: message.date)
        
        var useCase: AIFeatureUseCaseProtocol?
        if proxyServerURL.isEmpty == false {
            useCase = AssistAnswerByOpenAIProxyServer(proxyServerURL, content: messages)
        } else if apiKey.isEmpty == false {
            useCase = AssistAnswerByOpenAIAPI(apiKey, content: messages)
        }
        guard let useCase else { return }
        
        Task { [weak self] in
            do {
                let answer = try await useCase.execute()
                await MainActor.run { [weak self, answer] in
                    guard let self = self else { return }
                    self.aiAnswer = answer
                }
            } catch {
                prettyLog(error)
            }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.waitingAnswer = false
            }
        }
    }
    
    public func applyAITranslate(_ message: DialogItem.MessageItem) {
        waitingTranslation = TranslationInfo(id: message.id, waiting: true)
        
        let proxyServerURL = aiFeatures.translate.proxyServerURLPath // proxy Server URL
        let apiKey = aiFeatures.translate.openAIAPIKey
        
        var useCase: AIFeatureUseCaseProtocol?
        if proxyServerURL.isEmpty == false {
            useCase = TranslationByOpenAIProxyServer(proxyServerURL, content: message)
        } else if apiKey.isEmpty == false {
            useCase = TranslationByOpenAIAPI(apiKey, content: message)
        }
        
        guard let useCase else { return }
        
        Task { [weak self] in
            do {
                let translatedText = try await useCase.execute()
                var translatedMessage = message
                translatedMessage.translatedText = translatedText
                guard let self = self,
                      let index = self.dialog.messages.firstIndex(where: { $0.id == message.id }) else {
                    return
                }
                await MainActor.run { [self, index, translatedMessage] in
                    self.dialog.messages[index] = translatedMessage
                }
            } catch {
                prettyLog(error)
            }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.waitingTranslation = TranslationInfo(id: message.id, waiting: false)
            }
        }
    }
    
    public func applyAIRephrase(_ tone: QBAIRephrase.ToneInfo, content: String, needToUpdate: Bool) {
        if aiFeatures.rephrase.enable == false {
            return
        }
        
        waitingAnswer = true
        aiAnswer = ""
        
        if needToUpdate == true {
            rephrasedContent = [:]
            rephrasedContent[.original] = content
        }

        if let rephrased = rephrasedContent[tone] {
            waitingAnswer = false
            self.aiAnswer = rephrased
            return
        }
        
        if tone == .original { return }
        
        let proxyServerURL = aiFeatures.rephrase.proxyServerURLPath // proxy Server URL
        let apiKey = aiFeatures.rephrase.openAIAPIKey

        var useCase: AIFeatureUseCaseProtocol?
        if proxyServerURL.isEmpty == false {
            useCase = RephraseByOpenAIProxyServer(proxyServerURL, tone: tone, content: content)
        } else if apiKey.isEmpty == false {
            useCase = RephraseByOpenAIAPI(apiKey, tone: tone, content: content)
        }

        guard let useCase else { return }

        Task { [weak self] in
            do {
                let rephrased = try await useCase.execute()
                await MainActor.run { [weak self, rephrased] in
                    guard let self = self else { return }
                    self.rephrasedContent[tone] = rephrased
                    self.aiAnswer = rephrased
                }
            } catch {
                prettyLog(error)
            }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.waitingAnswer = false
            }
        }
    }
    
    private func filterTextHistory(from date: Date) -> [Message] {
        let messages = dialog.messages.filter { message in
            if message.isText == true, message.date <= date {
                return true
            }
            return false
        }
        return messages
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
        action == .play ? audioPlayer.play(audio: audioData) : audioPlayer.stop()
    }
    
    func stopPlayng() {
        audioPlayer.stop()
    }
}

extension MessageEntity {
    var isAttachmentMessage: Bool {
        return fileInfo != nil
    }
    
    func fileIsKindOf(type expected: FileType) -> Bool {
        if isAttachmentMessage,
           let type = fileInfo?.ext.type,
           type == expected {
            return true
        }
        return false
    }
    
    var isAudioMessage: Bool {
        fileIsKindOf(type: .audio)
    }
    
    var isVideoMessage: Bool {
        fileIsKindOf(type: .video)
    }
    
    var isImageMessage: Bool {
        fileIsKindOf(type: .image)
    }
    
    var isFileMessage: Bool {
        fileIsKindOf(type: .file)
    }
    
    var isChat: Bool {
        if isNotification == true || type == .divider {
            return false
        }
        return true
    }
    
    var isText: Bool {
        if isNotification == true
            || type == .divider
            || isAttachmentMessage == true {
            return false
        }
        return true
    }
    
    var isNotification: Bool {
        return eventType != .message
    }
}

private extension FileExtension {
    var name: String {
        let timeStamp = Date().timeStamp
        switch type {
        case .image: return timeStamp + "_Image.\(self)"
        case .video: return timeStamp + "_Video.\(self)"
        case .audio: return timeStamp + "_Audio.\(self)"
        case .file: return timeStamp + "_File.\(self)"
        }
    }
}

private extension Date {
    var timeStamp: String {
        return String(Int64(self.timeIntervalSince1970 * 1000))
    }
}

extension Date {
    func hasSame(_ components: Set<Calendar.Component>,
                 as date: Date,
                 using calendar: Calendar = .autoupdatingCurrent) -> Bool {
        return components.filter { calendar.component($0, from: date) != calendar.component($0, from: self) }.isEmpty
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
}
