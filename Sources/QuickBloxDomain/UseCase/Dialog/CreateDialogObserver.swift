//
//  CreateDialogObserver.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Dispatch

private struct DialogQueue {
    static let create = DispatchQueue(label: "com.create.dialog.observer")
}

public class CreateDialogObserver<Item: DialogEntity,
                                  Repo: DialogsRepositoryProtocol>
where Item == Repo.DialogEntityItem {
    private let repo: Repo
    
    private var ids: Set<String> = []
    private let subject = PassthroughSubject<Item, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var taskUpdate: Task<Void, Never>?
    private var taskEvents: Task<Void, Never>?
    
    public init(repo: Repo) {
        self.repo = repo
    }
    
    deinit {
        taskUpdate?.cancel()
        taskUpdate = nil
        taskEvents?.cancel()
        taskEvents = nil
    }
    
    public func execute() -> AnyPublisher<Item, Never> {
        processCreateEvents()
        processDialog()
        return subject.eraseToAnyPublisher()
    }
    
    private func processDialog() {
        taskUpdate = Task { [weak self] in
            let sub = await self?.repo.localDialogsPublisher
                .receive(on: DialogQueue.create)
                .compactMap { $0.first(where: {
                    guard let ids = self?.ids else { return false }
                    return ids.contains($0.id)
                }) }
                .sink { [weak self] dialog in
                    prettyLog(label: "dialog is owner", dialog.isOwnedByCurrentUser)
                    self?.ids.remove(dialog.id)
                    self?.subject.send(dialog)
                }
            guard let sub = sub, let strSelf = self else { return }
            strSelf.cancellables.insert(sub)
        }
    }
    
    private func processCreateEvents() {
        taskEvents = Task { [weak self] in
            let sub = await self?.repo.remoteEventPublisher
                .receive(on: DialogQueue.create)
                .sink { [weak self] event in
                    switch event {
                    case .create(let id, let isCurrent, _):
                        prettyLog(label: "create dialog with id \(id) by current User \(isCurrent) event", id)
                        self?.ids.insert(id)
                    default:
                        break
                    }
                }
            guard let sub = sub, let strSelf = self else { return }
            strSelf.cancellables.insert(sub)
        }
    }
}
