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

public protocol DialogsListProtocol: QuickBloxUIKitViewModel {
    associatedtype Item: DialogEntity
    associatedtype DialogsRepo: DialogsRepositoryProtocol
    
    var dialogs: [Item] { get set }
    var syncState: SyncState { get set }
    
    var dialogsRepo: DialogsRepo { get }
    
    var selectedItem: Item? { get set }
    
    func deleteDialog(withID dialogId: String)
    
    var dialogToBeDeleted: Item? { get set }
    
    init(dialogsRepo: DialogsRepo)
}

open class DialogsViewModel: DialogsListProtocol {
    
    @Published public var selectedItem: Dialog? = nil
    @Published public var dialogToBeDeleted: Dialog? = nil
    @Published public var dialogs: [Dialog] = []
    @Published public var syncState: SyncState = .synced
    
    public let dialogsRepo: DialogsRepository
    
    private let leaveDialogObserve: LeaveDialogObserver<Dialog, DialogsRepository>!
    private let createDialogObserve: CreateDialogObserver<Dialog, DialogsRepository>!
    private var dialogsUpdates: DialogsUpdates<DialogsRepository>?
    private var updateDialogs: Task<Void, Never>?
    private var deleteDialog: Task<Void, Never>?

    required public init(dialogsRepo: DialogsRepository) {
        self.dialogsRepo = dialogsRepo
        
        createDialogObserve = CreateDialogObserver(repo: dialogsRepo)
        leaveDialogObserve = LeaveDialogObserver(repo: dialogsRepo)
        
        createDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialog in
                if self?.selectedItem == nil {
                    self?.selectedItem = dialog
                }
            }
            .store(in: &cancellables)
        
        leaveDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialogId in
                if dialogId == self?.selectedItem?.id {
                    self?.selectedItem = nil
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
                    if self?.deleteDialog != nil {
                        return
                    }
                    self?.dialogs = updated
                }
                .store(in: &strSelf.cancellables)
            strSelf.updateDialogs = nil
        }
        
        QuickBloxUIKit.syncState
            .receive(on: RunLoop.main)
            .sink { [weak self] syncState in
                self?.syncState = syncState
            }
            .store(in: &cancellables)
    }
    
    //MARK: QuickBloxUIKitViewModel
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    public func sync() {
    }
}

extension DialogsViewModel {
    public func deleteDialog(withID dialogId: String) {
        guard let dialogToBeDeleted = dialogToBeDeleted else {
            return
        }
        
        let leaveDialogCase = LeaveDialog(dialog: dialogToBeDeleted,
                                          repo: RepositoriesFabric.dialogs)
        updateDialogs = Task { [weak self] in
            do {
                try await leaveDialogCase.execute()
                self?.updateDialogs = nil
                await MainActor.run { [weak self] in
                    guard let strSelf = self else { return }
                    if let index = strSelf.dialogs.firstIndex(where: {$0.id == dialogId}) {
                        strSelf.dialogs.remove(at: index)
                    }
                    
                    strSelf.dialogToBeDeleted = nil
                }
            } catch {
                prettyLog(error)
                if error is RepositoryException {
                    self?.updateDialogs = nil
                    await MainActor.run { [weak self] in
                        guard let strSelf = self else { return }
                        if let index = strSelf.dialogs.firstIndex(where: {$0.id == dialogId}) {
                            strSelf.dialogs.remove(at: index)
                        }
                        strSelf.dialogToBeDeleted = nil
                    }
                }
            }
        }
    }
}


//class DialogsListMock: DialogsListProtocol {
//    @Published var selectedItem: Dialog? = nil
//    @Published var dialogs: [PreviewDialog] = []
//    @Published var syncState: SyncState = .syncing(stage: .disconnected)
//    var dialogsRepo: QuickBloxData.DialogsRepository
//    func deleteDialog(withID dialogId: String) { }
//    required init(dialogsRepo: DialogsRepository) {
//        self.dialogsRepo = dialogsRepo
//    }
//    var cancellables = Set<AnyCancellable>()
//    var tasks = Set<Task<Void, Never>>()
//    func sync() { }
//    
//    convenience init(dialogs: [PreviewDialog]) {
//        self.init(dialogsRepo: RepositoriesFabric.dialogs)
//        self.dialogs = dialogs
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            let info = "Display error information."
//            let exeption = RepositoryException.unexpected(info)
//            self.syncState = .syncing(stage: .connecting,
//                                      error: exeption)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.syncState = .syncing(stage: .update)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            self.syncState = .synced
//        }
//    }
//}
