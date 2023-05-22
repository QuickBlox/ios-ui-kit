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


struct DialogQueue {
    static let create = DispatchQueue(label: "com.create.dialog.observer")
    static let leave = DispatchQueue(label: "com.leave.dialog.observer")
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
                    guard dialog.isOwnedByCurrentUser else { return }
                    self?.ids.remove(dialog.id)
                    self?.subject.send(dialog)
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
    
    private func processCreateEvents() {
        taskEvents = Task { [weak self] in
            let sub = await self?.repo.remoteEventPublisher
                .receive(on: DialogQueue.create)
                .sink { [weak self] event in
                    switch event {
                    case .create(dialogWithId: let id):
                        prettyLog(label: "create dialog with id \(id) event", id)
                        self?.ids.insert(id)
                    default:
                        break
                    }
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
}


public class LeaveDialogObserver<Item: DialogEntity,
                                  Repo: DialogsRepositoryProtocol>
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
                    case .leave(let dialogId, byUser: let isCurrentUser):
                        if isCurrentUser { self?.subject.send(dialogId) }
                    default:
                        break
                    }
                }
            guard let sub = sub else { return }
            self?.cancellables.insert(sub)
        }
    }
}
