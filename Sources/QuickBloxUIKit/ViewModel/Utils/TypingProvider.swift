//
//  TypingProvider.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine

class TypingProvider: ObservableObject {
    let settings = QuickBloxUIKit.settings.dialogScreen.typing
    
    public let objectWillChange = PassthroughSubject<String, Never>()
    
    var typing = "" {
        didSet {
            objectWillChange.send(typing)
        }
    }
    
    var typingTimers: [String :Timer] = [:] {
        didSet {
            setupTyping(Array(typingTimers.keys))
        }
    }
    
    private var dialogId: String
    private var typingUsers: [String: User] = [:]
    private var usersRepo: UsersRepository
    
    init(dialogId: String, usersRepo: UsersRepository) {
        self.dialogId = dialogId
        self.usersRepo = usersRepo
    }
    
    public func typingUser(_ userId: String) {
        let typing: (_ userId: String) -> Void = { [weak self] userId in
            guard let self = self else { return }
            if self.typingTimers[userId] != nil {
                self.typingTimers[userId]?.invalidate()
            }
            let timer = Timer.scheduledTimer(withTimeInterval: settings.timeInterval, repeats: false) { (timer) in
                self.removeTimer(userId)
            }
            self.typingTimers[userId] = timer
        }
        
        guard typingUsers[userId] != nil else {
            Task { [weak self] in
                guard let self = self else { return }
                let getUser = GetUser(id: userId, repo: self.usersRepo)
                let user = try await getUser.execute()
                self.typingUsers[userId] = user
                typing(userId)
            }
            return
        }
        typing(userId)
    }
    
    public func stopTypingUser(_ userId: String) {
        removeTimer(userId)
    }
    
    private func removeTimer(_ userId: String) {
        if let timer = typingTimers[userId] {
            timer.invalidate()
            typingTimers[userId] = nil
        }
    }
    
    private func setupTyping(_ typingIDs: [String]) {
        switch typingIDs.count {
        case 0:
            typing = ""
        case 1:
            typing = getName(typingIDs[0]) + settings.typingOne
        case 2:
            typing = getName(typingIDs[0]) + " and " + getName(typingIDs[1]) + settings.typingTwo
        case 3:
            typing = getName(typingIDs[0]) + ", " + getName(typingIDs[1]) + " and " + getName(typingIDs[2]) + settings.typingTwo
        default:
            typing = getName(typingIDs[0]) + ", " + getName(typingIDs[1]) + settings.typingFour
        }
    }
    
    private func getUser(_ userId: String, repo: UsersRepository) {
        Task { [weak self] in
            let getUser = GetUser(id: userId, repo: repo)
            let user = try await getUser.execute()
            self?.typingUsers[userId] = user
        }
    }
    
    private func getName(_ userId: String) -> String {
        guard let name = typingUsers[userId]?.name else { return userId }
        return name
    }
    
    //MARK: - Typing Current User
    private var stopTimer: Timer?
    
    @objc public func sendStopTyping() {
        stopTimer?.invalidate()
        stopTimer = nil
        
        Task {
            let sendStopTyping = SendStopTyping(dialogId: dialogId, repo: RepositoriesFabric.dialogs)
            try await sendStopTyping.execute()
        }
    }
    
    public func sendTyping() {
        Task {
            let sendTyping = SendTyping(dialogId: dialogId, repo: RepositoriesFabric.dialogs)
            try await sendTyping.execute()
        }
        stopTimer?.invalidate()
        stopTimer = nil
        stopTimer = Timer.scheduledTimer(timeInterval: settings.timeInterval,
                                         target: self,
                                         selector: #selector(sendStopTyping),
                                         userInfo: nil,
                                         repeats: false)
    }
}
