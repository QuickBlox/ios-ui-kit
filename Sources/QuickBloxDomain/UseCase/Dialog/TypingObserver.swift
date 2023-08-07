//
//  TypingObserver.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Dispatch

private struct DialogQueue {
    static let typing = DispatchQueue(label: "com.typing.dialog.observer")
}

public class TypingObserver<Repo: DialogsRepositoryProtocol> {
    private let repo: Repo
    
    private var dialogId: String
    private let subject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var taskObserveTyping: Task<Void, Never>?
    
    public init(repo: Repo, dialogId: String) {
        self.repo = repo
        self.dialogId = dialogId
    }
    
    deinit {
        taskObserveTyping?.cancel()
        taskObserveTyping = nil
    }
    
    public func execute() -> AnyPublisher<String, Never> {
        subscribeToObserveTyping()
        observeTyping()
        return subject.eraseToAnyPublisher()
    }
    
    private func subscribeToObserveTyping() {
        Task {
            do {
                try await repo.subscribeToObserveTyping(dialog: dialogId)
            } catch  {
                prettyLog(error)
                throw error
            }
        }
    }
    
    private func observeTyping() {
        taskObserveTyping = Task { [weak self] in
            let sub = await self?.repo.remoteEventPublisher
                .receive(on: DialogQueue.typing)
                .sink { [weak self]  event in
                    switch event {
                    case .typing(let userId, dialogID: let dialogID):
                        if self?.dialogId == dialogID {
                            self?.subject.send(String(userId))
                        }
                    default:
                        break
                    }
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
}
