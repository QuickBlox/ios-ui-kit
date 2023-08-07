//
//  StopTypingObserver.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Dispatch

private struct DialogQueue {
    static let stopTyping = DispatchQueue(label: "com.stopTyping.dialog.observer")
}

public class StopTypingObserver<DialogsRepo: DialogsRepositoryProtocol> {
    private let dialogsRepo: DialogsRepo
    
    private var dialogId: String
    private let subject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var taskObserveStopTyping: Task<Void, Never>?
    
    public init(dialogsRepo: DialogsRepo, dialogId: String) {
        self.dialogsRepo = dialogsRepo
        self.dialogId = dialogId
    }
    
    deinit {
        taskObserveStopTyping?.cancel()
        taskObserveStopTyping = nil
    }
    
    public func execute() -> AnyPublisher<String, Never> {
        observeStopTyping()
       return subject.eraseToAnyPublisher()
    }
    
    private func observeStopTyping() {
        taskObserveStopTyping = Task { [weak self] in
            let sub = await self?.dialogsRepo.remoteEventPublisher
                .receive(on: DialogQueue.stopTyping)
                .sink { [weak self]  event in
                    switch event {
                    case .stopTyping(let userId, dialogID: let dialogID):
                        if self?.dialogId == dialogID { self?.subject.send(String(userId)) }
                    default:
                        break
                    }
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
}
