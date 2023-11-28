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
    
    func deleteDialog(withID dialogId: String)
    
    var dialogToBeDeleted: Item? { get set }
    
    init(dialogsRepo: DialogsRepo)
}

@MainActor
final class DialogsViewModel: DialogsListProtocol {
    
    @Published public var selectedItem: Dialog? = nil
    @Published public var dialogToBeDeleted: Dialog? = nil
    @MainActor
    @Published public var dialogs: [Dialog] = []
    @Published public var syncState: SyncState = .syncing(stage: SyncState.Stage.disconnected)
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
                
                if self?.onAppear == true { return }
                
                guard let dialog = self?.dialogs.first(where: { $0.id == dialogId }) else { return }
                self?.refresh(eventType: .create, with: dialog)
            }
            .store(in: &cancellables)
        
        updateDialogs = Task { [weak self] in
            guard let strSelf = self else { return }
            strSelf.dialogsUpdates = DialogsUpdates(repo: strSelf.dialogsRepo)
            await strSelf.dialogsUpdates?.execute()
                .receive(on: RunLoop.main)
                .sink { [weak self] updated in
                    self?.dialogs = updated
                    
                    if self?.onAppear == true { return }
                    self?.refresh(eventType: .update, with: nil)
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
        onAppear = true
    }
    public func unsync() {
        onAppear = false
    }
}

extension DialogsViewModel {
    public func deleteDialog(withID dialogId: String) {
        guard let dialogToBeDeleted = dialogToBeDeleted else {
            return
        }
        
        let leaveDialogCase = LeaveDialog(dialog: dialogToBeDeleted,
                                          repo: RepositoriesFabric.dialogs)
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
    
    private func refresh(eventType: MessageEventType, with dialog: Dialog?) {
        if eventType == .leave, let dialog,
                  let index = dialogs.firstIndex(where: {$0.id == dialog.id}) {
            dialogs.remove(at: index)
        }
        
        let updatedDialogs = dialogs
        
        DispatchQueue.main.async {
            self.dialogs = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dialogs = updatedDialogs
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
