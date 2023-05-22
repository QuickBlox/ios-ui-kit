//
//  DialogsList.swift
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
    
    init(dialogsRepo: DialogsRepo)
}

open class DialogsList: DialogsListProtocol {
    @Published public var selectedItem: Dialog? = nil
    @Published public var dialogs: [Dialog] = []
    @Published public var syncState: SyncState = .syncing(stage: .disconnected)

    public let dialogsRepo: DialogsRepository
    
    private let leaveDialogObserve: LeaveDialogObserver<Dialog, DialogsRepository>!
    private let createDialogObserve: CreateDialogObserver<Dialog, DialogsRepository>!
    private var dialogsUpdates: DialogsUpdates<DialogsRepository>?
    private var updateDialogs: Task<Void, Never>?

    required public init(dialogsRepo: DialogsRepository) {
        self.dialogsRepo = dialogsRepo
        prettyLog("DialogsList INIT !!!!!!!!!!!")
        
        createDialogObserve = CreateDialogObserver(repo: dialogsRepo)
        leaveDialogObserve = LeaveDialogObserver(repo: dialogsRepo)
        
        createDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialog in
                prettyLog(label: "set selectedItem", dialog)
                self?.dialogs.insert(dialog, at: 0)
                self?.selectedItem = dialog
            }
            .store(in: &cancellables)
        
        leaveDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialogId in
                if dialogId == self?.selectedItem?.id {
                    self?.selectedItem = nil
                }
            }
            .store(in: &cancellables)
        
        updateDialogs = Task { [weak self] in
            guard let strSelf = self else { return }
            strSelf.dialogsUpdates = DialogsUpdates(repo: strSelf.dialogsRepo)
            await strSelf.dialogsUpdates?.execute()
                .receive(on: RunLoop.main)
                .assign(to: \DialogsList.dialogs, on: strSelf)
                .store(in: &strSelf.cancellables)
            strSelf.updateDialogs = nil
        }
        
        QuickBloxUIKit.syncState
            .receive(on: RunLoop.main)
            .assign(to: \DialogsList.syncState, on: self)
            .store(in: &cancellables)
    }
    
    //MARK: QuickBloxUIKitViewModel
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    public func sync() {
        
    }
}

extension DialogsList {
    public func deleteDialog(withID dialogId: String) {
        guard let index = dialogs.firstIndex(where: {$0.id == dialogId}) else {
            return
        }
        let leaveDialogCase = LeaveDialog(dialog: dialogs[index],
                                          repo: RepositoriesFabric.dialogs)
        dialogs.remove(at: index)
        let task = Task { do {
            try await leaveDialogCase.execute()
        } catch { prettyLog(error) } }
        tasks.insert(task)
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
