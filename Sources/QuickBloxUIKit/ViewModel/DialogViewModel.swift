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
import QBAITranslate
import QBAIAnswerAssistant

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

public struct AIAnswerInfo {
    var id: String = ""
    var waiting: Bool = false
}

public struct AIAnswerFailedInfo {
    var feature: AIFeatureType = .answerAssist
    var failed: Bool = false
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
    
    var syncState: SyncState { get set }
    var audioPlayer: AudioPlayer { get set }
    var targetMessage: DialogItem.MessageItem? { get set }
    var error: String { get set }
    var aiAnswerFailed: AIAnswerFailedInfo { get set }
    var dialog: DialogItem { get set }
    var withAnimation: Bool { get set }
    var typing: String { get set }
    var permissionNotGranted: PermissionInfo { get set }
    var aiAnswer: String { get set }
    var waitingAnswer: AIAnswerInfo { get set }
    var isProcessing: Bool { get set }
    var tones: [QBAIRephrase.AITone] { get set }
    
    func stopPlayng()
    func startRecording()
    func stopRecording()
    func deleteRecording()
    func sendMessage(_ text: String)
    func handleOnSelect(attachment: AttachmentAsset)
    func handleOnAppear(_ message: DialogItem.MessageItem)
    func playAudio(_ url: URL, action: MessageAttachmentAction)
    func sendStopTyping()
    func sendTyping()
    func unsubscribe()
    func applyAIAnswerAssist(_ message: DialogItem.MessageItem)
    func applyAITranslate(_ message: DialogItem.MessageItem)
    func applyAIRephrase(_ tone: QBAIRephrase.AITone, text: String, needToUpdate: Bool)
    func openSettings()
    func requestPermission(_ mediaType: AVMediaType, completion: @escaping (_ granted: Bool) -> Void)
}

public extension QBAIRephrase.AITone {
    static let original = QBAIRephrase.AITone(
    name: "Back to original text",
    description: "",
    icon: "✅"
  )
}

open class DialogViewModel: DialogViewModelProtocol {
    @Published public var waitingAnswer: AIAnswerInfo = AIAnswerInfo()
    @Published public var dialog: Dialog
    @Published public var targetMessage: QuickBloxData.Message?
    @Published public var audioPlayer = AudioPlayer()
    @Published public var deleteDialog: Bool = false
    @Published public var typing: String = ""
    @Published public var aiAnswer: String = ""
    @Published public var permissionNotGranted: PermissionInfo = PermissionInfo(mediaType: .audio)
    @Published public var isProcessing: Bool = false
    @Published public var syncState: SyncState = .synced
    @Published public var error = ""
    @Published public var aiAnswerFailed: AIAnswerFailedInfo = AIAnswerFailedInfo() {
            didSet {
                if aiAnswerFailed.failed == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        self.aiAnswerFailed.failed = false
                    }
                }
            }
        }
    
    public var tones: [QBAIRephrase.AITone] = {
        let tones: [any QBAIRephrase.Tone]  =
        [QBAIRephrase.AITone.original] + QuickBloxUIKit.feature.ai.rephrase.tones
        return tones as? [QBAIRephrase.AITone] ?? []
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
    private var updateDialogObserve: UpdateDialogObserver<Dialog, DialogsRepository>!
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    private var typingProvider: TypingProvider
    
    private var isTypingEnable = true
    
    private var rephrasedContent: [QBAIRephrase.AITone: String] = [:]
    
    private var draftAttachmentMessage: QuickBloxData.Message? = nil
    
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
                self?.syncState = syncState
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
    }
    
    public func sync() {
        
        if syncDialog == nil {
            syncDialog = SyncDialog(dialogId: dialog.id,
                                    dialogsRepo: dialogsRepo,
                                    usersRepo: usersRepo,
                                    messageRepo: RepositoriesFabric.messages)
        }
        
        syncDialog?.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialog in
                
                var withAnimation = false
                
                if dialog.messages.isEmpty == false {
                    if let messagesCount = self?.dialog.displayedMessages.count,
                       dialog.displayedMessages.count - messagesCount == 1 {
                        withAnimation = true
                    } else {
                        withAnimation = false
                    }
                    self?.dialog = dialog
                    if let draftAttachmentMessage = self?.draftAttachmentMessage {
                        self?.dialog.messages.append(draftAttachmentMessage)
                    }
                }
                self?.withAnimation = withAnimation
                self?.targetMessage = dialog.displayedMessages.last
                if let userId = self?.targetMessage?.userId,
                   self?.targetMessage?.isOwnedByCurrentUser == false {
                    self?.typingProvider.stopTypingUser(userId)
                }
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
            guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
            
            UIGraphicsEndImageContext()
            
            var compressionQuality: CGFloat = 1.0
            let maxFileSize: Int = 10 * 1024 * 1024 // 10MB in bytes
            var finalImageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            
            while let data = finalImageData, data.count > maxFileSize && compressionQuality > 0.0 {
                compressionQuality -= 0.1
                finalImageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            }
            
            guard let imageData = finalImageData else {
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
            do {
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
                
                dialog.messages.removeAll(where: { $0.id == draftAttachmentMessage?.id })
                draftAttachmentMessage = nil
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.isProcessing = false
                }
            } catch {
                prettyLog(error)
                if error is RepositoryException {
                    await MainActor.run { [weak self, error] in
                        guard let self = self else { return }
                        self.error = error.localizedDescription
                        dialog.messages.removeAll(where: { $0.id == self.draftAttachmentMessage?.id })
                        draftAttachmentMessage = nil
                        self.isProcessing = false
                    }
                }
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
    
    public func handleOnAppear(_ message: QuickBloxData.Message) {
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
        
        waitingAnswer = AIAnswerInfo(id: message.id, waiting: true)
        aiAnswer = ""
        
        let messages = filterTextHistory(from: message.date)
        
        let answerAssist = QuickBloxUIKit.feature.ai.answerAssist
        
        var settings: QBAIAnswerAssistant.AISettings?
        
        if answerAssist.serverPath.isEmpty == false {
            
            settings = QBAIAnswerAssistant.AISettings(token: "",
                                           serverPath: answerAssist.serverPath,
                                           apiVersion: answerAssist.apiVersion,
                                           organization: answerAssist.organization,
                                           model: answerAssist.model,
                                           temperature: answerAssist.temperature,
                                           maxRequestTokens: answerAssist.maxRequestTokens,
                                           maxResponseTokens: answerAssist.maxResponseTokens)
        } else if answerAssist.apiKey.isEmpty == false {
            
            settings = QBAIAnswerAssistant.AISettings(apiKey: answerAssist.apiKey,
                                           apiVersion: answerAssist.apiVersion,
                                           organization: answerAssist.organization,
                                           model: answerAssist.model,
                                           temperature: answerAssist.temperature,
                                           maxRequestTokens: answerAssist.maxRequestTokens,
                                           maxResponseTokens: answerAssist.maxResponseTokens)
        }
        
        guard let settings = settings else {
            waitingAnswer = AIAnswerInfo(id: message.id, waiting: false)
            self.aiAnswer = message.text
            return
        }
        
        let useCase = AnswerAssist(messages, settings: settings)
        
        Task { [weak self] in
            do {
                let answer = try await useCase.execute()
                await MainActor.run { [weak self, answer] in
                    guard let self = self else { return }
                    self.aiAnswer = answer
                }
            } catch {
                prettyLog(error)
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.aiAnswerFailed = AIAnswerFailedInfo(feature: .answerAssist, failed: true)
                }            }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.waitingAnswer = AIAnswerInfo(id: message.id, waiting: false)
            }
        }
    }
    
    public func applyAITranslate(_ message: DialogItem.MessageItem) {
        waitingAnswer = AIAnswerInfo(id: message.id, waiting: true)
        
        let messages = filterTextHistory(from: message.date)
        
        let translate = QuickBloxUIKit.feature.ai.translate
        
        var settings: QBAITranslate.AISettings?
        
        if translate.serverPath.isEmpty == false {
            
            settings = QBAITranslate.AISettings(token: "",
                                           serverPath: translate.serverPath,
                                           language: translate.language,
                                           apiVersion: translate.apiVersion,
                                           organization: translate.organization,
                                           model: translate.model,
                                           temperature: translate.temperature,
                                           maxRequestTokens: translate.maxRequestTokens,
                                           maxResponseTokens: translate.maxResponseTokens)
        } else if translate.apiKey.isEmpty == false {
            
            settings = QBAITranslate.AISettings(apiKey: translate.apiKey,
                                           language: translate.language,
                                           apiVersion: translate.apiVersion,
                                           organization: translate.organization,
                                           model: translate.model,
                                           temperature: translate.temperature,
                                           maxRequestTokens: translate.maxRequestTokens,
                                           maxResponseTokens: translate.maxResponseTokens)
        }
        
        guard let settings = settings else {
            waitingAnswer = AIAnswerInfo(id: message.id, waiting: false)
            self.aiAnswer = message.text
            return
        }
        
        let useCase = Translate(message.text, content: messages, settings: settings)
        
        Task { [weak self] in
            do {
                let translatedText = try await useCase.execute()
                if translatedText == "Translation failed." {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.aiAnswerFailed = AIAnswerFailedInfo(feature: .translate, failed: true)
                        self.waitingAnswer = AIAnswerInfo(id: message.id, waiting: false)
                    }
                    return
                }
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
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.aiAnswerFailed = AIAnswerFailedInfo(feature: .translate, failed: true)
                }
            }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.waitingAnswer = AIAnswerInfo(id: message.id, waiting: false)
            }
        }
    }
    
    public func applyAIRephrase(_ tone: QBAIRephrase.AITone, text: String, needToUpdate: Bool) {
        
        let messages = filterTextHistory(from: Date())
        
        waitingAnswer = AIAnswerInfo(id: "", waiting: true)
        aiAnswer = ""
        
        if needToUpdate == true || rephrasedContent[.original] == nil {
            rephrasedContent = [:]
            rephrasedContent[.original] = text
        }

        if let rephrased = rephrasedContent[tone] {
            waitingAnswer = AIAnswerInfo(id: "", waiting: false)
            self.aiAnswer = rephrased
            return
        }
        
        if tone == .original {
            waitingAnswer = AIAnswerInfo(id: "", waiting: false)
            return
        }
        
        let rephrase = QuickBloxUIKit.feature.ai.rephrase
        
        var settings: QBAIRephrase.AISettings?
        
        if rephrase.serverPath.isEmpty == false {
            settings = QBAIRephrase.AISettings(token: "",
                                               serverPath: rephrase.serverPath,
                                               tone: tone,
                                               apiVersion: rephrase.apiVersion,
                                               organization: rephrase.organization,
                                               model: rephrase.model,
                                               temperature: rephrase.temperature,
                                               maxRequestTokens: rephrase.maxRequestTokens,
                                               maxResponseTokens: rephrase.maxResponseTokens)
        } else if rephrase.apiKey.isEmpty == false {
            
            settings = QBAIRephrase.AISettings(apiKey: rephrase.apiKey,
                                               tone: tone,
                                               apiVersion: rephrase.apiVersion,
                                               organization: rephrase.organization,
                                               model: rephrase.model,
                                               temperature: rephrase.temperature,
                                               maxRequestTokens: rephrase.maxRequestTokens,
                                               maxResponseTokens: rephrase.maxResponseTokens)
        }
        
        guard let settings = settings else {
            waitingAnswer = AIAnswerInfo(id: "", waiting: false)
            self.aiAnswer = text
            return
        }
        
        let useCase = Rephrase(text, content: messages, settings: settings)
        
        Task { [weak self] in
            do {
                let rephrased = try await useCase.execute()
                await MainActor.run { [weak self, rephrased] in
                    guard let self = self else { return }
                    
                    if rephrased == "Rephrase failed." {
                        self.aiAnswerFailed = AIAnswerFailedInfo(feature: .rephrase, failed: true)
                        self.waitingAnswer = AIAnswerInfo(id: "", waiting: false)
                        return
                    }
                    self.rephrasedContent[tone] = rephrased
                    self.aiAnswer = rephrased
                }
            } catch {
                prettyLog(error)
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.aiAnswerFailed = AIAnswerFailedInfo(feature: .rephrase, failed: true)
                }
            }
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.waitingAnswer = AIAnswerInfo(id: "", waiting: false)
            }
        }
    }
    
    private func filterTextHistory(from date: Date) -> [QuickBloxData.Message] {
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
        switch mediaType {
        case .audio:
            MediaPermissions.requestPermissionToMicrophone { granted in
                DispatchQueue.main.async {
                    self.permissionNotGranted = PermissionInfo(mediaType: mediaType,
                                                               notGranted: granted == false)
                    
                    
                    completion(granted)
                }
            }
            
        case .video:
            MediaPermissions.requestPermissionToCamera { granted in
                DispatchQueue.main.async {
                    self.permissionNotGranted = PermissionInfo(mediaType: mediaType,
                                                               notGranted: granted == false)
                    
                    
                    completion(granted)
                }
                
            }
        default:
            completion(false)
        }
    }
    
    public func openSettings() {
        MediaPermissions.openSettings()
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
    
    func playAudio(_ url: URL, action: MessageAttachmentAction) {
        action == .play ? audioPlayer.play(audioURL: url) : audioPlayer.stop()
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
