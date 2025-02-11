//
//  DialogsViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine
import QuickBloxLog

@MainActor
public protocol DialogsListProtocol: QuickBloxUIKitViewModel {
    associatedtype Item: DialogEntity
    associatedtype DialogsRepo: DialogsRepositoryProtocol
    
    var dialogs: [Item] { get set }
    var syncState: SyncState { get set }
    var dialogsRepo: DialogsRepo { get }
    var selectedItem: Item? { get set }
    var dialogToBeDeleted: Item? { get set }
    
    func deleteDialog(withID dialogId: String)
    init(dialogsRepo: DialogsRepo)
}

@MainActor
final class DialogsViewModel: DialogsListProtocol {
    @MainActor
    @Published public var selectedItem: Dialog? = nil
    @Published public var dialogToBeDeleted: Dialog? = nil
    @MainActor
    @Published public var dialogs: [Dialog] = []
    @Published public var syncState: SyncState = .synced
    public let dialogsRepo: DialogsRepository
    
    private let leaveDialogObserve: LeaveDialogObserver<Dialog, DialogsRepository>!
    private let createDialogObserve: CreateDialogObserver<Dialog, DialogsRepository>!
    private var dialogsUpdates: DialogsUpdates<DialogsRepository>?
    private var updateDialogs: Task<Void, Never>?
    private var deleteDialog: Task<Void, Never>?
    
    private var onAppear = false
    
    required public init(dialogsRepo: DialogsRepository) {
        self.dialogsRepo = dialogsRepo
        
        createDialogObserve = CreateDialogObserver(repo: dialogsRepo)
        leaveDialogObserve = LeaveDialogObserver(repo: dialogsRepo)
        
        createDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialog in
                if (isIPad == true || isMac == true) {
                    self?.selectedItem = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        DispatchQueue.main.async {
                            self?.selectedItem = dialog
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.selectedItem = dialog
                    }
                }
            }
            .store(in: &cancellables)
        
        leaveDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialogId in
                if dialogId == self?.selectedItem?.id {
                    if (isIPad == true || isMac == true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self?.selectedItem = nil
                        }
                    } else {
                        self?.selectedItem = nil
                    }
                }
                self?.dialogToBeDeleted = nil
            }
            .store(in: &cancellables)
        
        updateDialogs = Task { [weak self] in
            guard let strSelf = self else { return }
            strSelf.dialogsUpdates = DialogsUpdates(repo: strSelf.dialogsRepo)
            await strSelf.dialogsUpdates?.execute()
                .receive(on: RunLoop.main)
                .sink { [weak self] updated in
                    self?.dialogs = updated                }
                .store(in: &strSelf.cancellables)
            strSelf.updateDialogs = nil
        }
        
        QuickBloxUIKit.syncState
            .receive(on: RunLoop.main)
            .sink { [weak self] syncState in
                if self?.syncState == syncState { return }
                self?.syncState = syncState
            }
            .store(in: &cancellables)
    }
    
    //MARK: QuickBloxUIKitViewModel
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    public func sync() {
    }
    public func unsync() {
    }
}

extension DialogsViewModel {
    public func deleteDialog(withID dialogId: String) {
        guard let dialogToBeDeleted = dialogToBeDeleted else {
            return
        }
        
        let leaveDialogCase = LeaveDialog(dialog: dialogToBeDeleted,
                                          repo: Repository.dialogs)
        deleteDialog = Task { [weak self] in
            do {
                try await leaveDialogCase.execute()
            } catch {
                prettyLog(error)
            }
            self?.deleteDialog = nil
            await MainActor.run { [weak self] in
                self?.dialogToBeDeleted = nil
            }
        }
    }
}
