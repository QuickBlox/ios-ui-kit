//
//  LeaveDialogObserver.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Dispatch

private struct DialogQueue {
    static let leave = DispatchQueue(label: "com.leave.dialog.observer")
}

public class LeaveDialogObserver<Item: DialogEntity, Repo: DialogsRepositoryProtocol>
where Item == Repo.DialogEntityItem {
    private let repo: Repo
    
    private let subject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var taskLeave: Task<Void, Never>?
    
    public init(repo: Repo) {
        self.repo = repo
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
                .receive(on: DialogQueue.leave)
                .sink { [weak self]  event in
                    switch event {
                    case .leave(let dialogId):
                        self?.subject.send(dialogId)
                    case .removed(let dialogId):
                        self?.subject.send(dialogId)
                    default:
                        break
                    }
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
}
