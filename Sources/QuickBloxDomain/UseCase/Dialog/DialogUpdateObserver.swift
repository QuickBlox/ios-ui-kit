//
//  DialogUpdateObserver.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 05.10.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Dispatch

private struct DialogQueue {
    static let update = DispatchQueue(label: "com.update.dialog.local.observer")
}

public class DialogUpdateObserver<Repo: DialogsRepositoryProtocol> {
    private let repo: Repo
    
    private let subject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var taskUpdate: Task<Void, Never>?
    
    public init(repo: Repo) {
        self.repo = repo
    }

    deinit {
        taskUpdate?.cancel()
        taskUpdate = nil
    }
    
    public func execute() -> AnyPublisher<String, Never> {
        processUpdateEvents()
       return subject.eraseToAnyPublisher()
    }
    
    private func processUpdateEvents() {
        taskUpdate = Task { [weak self] in
            let sub = await self?.repo.localDialogUpdatePublisher
                .receive(on: DialogQueue.update)
                .sink { [weak self]  dialogId in
                    self?.subject.send(dialogId)
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
}
