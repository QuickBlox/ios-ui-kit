//
//  UpdateDialogObserver.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 10.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Dispatch

private struct DialogQueue {
    static let update = DispatchQueue(label: "com.update.dialog.observer")
}

public class UpdateDialogObserver<Item: DialogEntity, Repo: DialogsRepositoryProtocol>
where Item == Repo.DialogEntityItem {
    private let repo: Repo
    
    private var dialogId: String
    private let subject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var taskLeave: Task<Void, Never>?
    
    public init(repo: Repo, dialogId: String) {
        self.repo = repo
        self.dialogId = dialogId
    }
    
    deinit {
        taskLeave?.cancel()
        taskLeave = nil
    }
    
    public func execute() -> AnyPublisher<String, Never> {
        processLeaveEvents()
       return subject.eraseToAnyPublisher()
    }
    
    private func processLeaveEvents() {
        taskLeave = Task { [weak self] in
            let sub = await self?.repo.remoteEventPublisher
                .receive(on: DialogQueue.update)
                .sink { [weak self]  event in
                    switch event {
                    case .update(let dialogId):
                        if self?.dialogId == dialogId { self?.subject.send(dialogId) }
                    default:
                        break
                    }
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
}
