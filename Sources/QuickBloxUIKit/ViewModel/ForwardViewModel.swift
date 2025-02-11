//
//  ForwardViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine
import Photos
import QuickBloxLog
import PhotosUI
import CoreTransferable

private struct ForwardViewModelConstant {
    static let forwardedMessage: String = "[Forwarded_Message]"
}

public enum ForwardIResult {
    case success
    case failure
}

public struct ForwardInfo: Equatable {
    var result: ForwardIResult = .failure
    var waiting: Bool = false
}

public protocol ForwardViewModelProtocol: QuickBloxUIKitViewModel {
    associatedtype DialogItem: DialogEntity
    associatedtype MessageItem: MessageEntity
    
    var syncState: SyncState { get set }
    var error: String { get set }
    var isProcessing: Bool { get set }
    var messages: [MessageItem] { get set }
    var displayedDialogs: [DialogItem] { get set }
    var selectedDialogs: [String] { get set }
    var search: String { get set }
    var isSynced: Bool { get set }
    var forwardInfo: ForwardInfo { get set }
    
    func sendMessage(_ text: String, originName: String)
    func handleOnSelect(_ itemId: String)
    func getDialogs()
    func cancelForward()
}

open class ForwardViewModel: ForwardViewModelProtocol {
    @Published public var messages: [Message] = []
    @Published public var isProcessing: Bool = false
    @Published public var syncState: SyncState = .synced
    @MainActor
    @Published public var forwardInfo: ForwardInfo = ForwardInfo()
    @Published public var error = ""
    @MainActor
    @Published public var displayedDialogs: [Dialog] = []
    @MainActor
    @Published public var selectedDialogs: [String] = []
    @Published public var search: String = ""
    @MainActor
    @Published public var isSynced: Bool = false
    
    private let dialogsRepo: DialogsRepository = Repository.dialogs
    private let usersRepo: UsersRepository = Repository.users
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    private var forwardedMessageKey = QuickBloxUIKit.feature.forward.forwardedMessageKey
    
    init(messages: [Message]) {
        self.messages = messages
        
        QuickBloxUIKit.syncState
            .receive(on: RunLoop.main)
            .sink { [weak self] syncState in
                if self?.syncState == syncState { return }
                self?.syncState = syncState
                if syncState == .synced {
                    
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {}
    
    public func sync() {}
    
    public func getDialogs() {
        let getDialogs = GetAllDialogsFromLocal(dialogsRepo: self.dialogsRepo)
        
        Task { @MainActor [weak self] in
            do {
                let dialogs = try await getDialogs.execute()
                await MainActor.run { [weak self, dialogs] in
                    self?.displayedDialogs = dialogs
                }
            } catch {
                prettyLog(error)
            }
            self?.isSynced = true
        }
    }
    
    //MARK: - Messages
    @MainActor public func sendMessage(_ text: String, originName: String) {
        guard selectedDialogs.isEmpty == false else { return }
        guard messages.isEmpty == false else { return }
        
        forwardInfo.waiting = true
        
        for dialogId in selectedDialogs {
            let message = Message(dialogId: dialogId,
                                  text:  text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  ? forwardedMessageKey : text.trimmingCharacters(in: .whitespacesAndNewlines),
                                  type: .chat,
                                  actionType: .forward,
                                  originSenderName: originName,
                                  originalMessages: messages)
            
            let sendForwardMessage = SendForwardMessage(message: message,
                                                        messageRepo: Repository.messages)
            
            Task {
                do {
                    try await sendForwardMessage.execute()
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.forwardInfo = ForwardInfo(result: .success)
                    }
                } catch {
                    prettyLog(error)
                    if error is RepositoryException {
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.forwardInfo = ForwardInfo(result: .failure)
                        }
                    }
                }
            }
        }
    }
    
    public func handleOnAppear(_ message: QuickBloxData.Message) {
        
    }
    
    @MainActor public func handleOnSelect(_ itemId: String) {
        didSelect(single: true, itemId: itemId)
    }
    
    @MainActor private func didSelect(single: Bool, itemId: String) {
        if selectedDialogs.contains(where: { $0 == itemId }) == true, single == false {
            selectedDialogs.removeAll(where: { $0 == itemId })
        } else {
            if single {
                selectedDialogs = []
            }
            selectedDialogs.append(itemId)
        }
    }
    
    public func cancelForward() {
        messages = []
    }
}
