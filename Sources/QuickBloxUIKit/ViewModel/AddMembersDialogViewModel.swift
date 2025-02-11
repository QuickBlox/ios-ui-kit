//
//  AddMembersDialogViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine
import QuickBloxLog

public protocol AddMembersDialogProtocol: QuickBloxUIKitViewModel {
    associatedtype UserItem: UserEntity
    
    var displayed: [UserItem] { get set }
    var selected: UserItem? { get set }
    var isProcessing: Bool { get set }
    var isSynced: Bool { get set }
    
    var search: String { get set }
    func addSelectedUser()
}

final class AddMembersDialogViewModel: AddMembersDialogProtocol {
    @Published public var search: String = ""
    @Published public var displayed: [User] = []
    @Published public var selected: User? = nil
    @Published public var isProcessing: Bool = false
    @Published public var isSynced: Bool = false
    
    private var dialog: Dialog
    
    public private(set) var dialogsRepo: DialogsRepository = Repository.dialogs
    private var updateDialogLocalObserve: DialogUpdateObserver<DialogsRepository>!
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    private var taskUsers: Task<Void, Never>?
    private var taskUpdate: Task<Void, Never>?
    
    // use for PreviewProvider
    public init(_ dialog: Dialog) {
        self.dialog = dialog
        
        if dialog.type == .group {
            updateDialogLocalObserve = DialogUpdateObserver(repo: dialogsRepo)
            
            updateDialogLocalObserve.execute()
                .receive(on: RunLoop.main)
                .sink { [weak self] dialogId in
                    if dialogId == self?.dialog.id {
                        self?.getDialog()
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    public func sync() {
        displayDialogMembers()
        
        $search.eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.displayDialogMembers(by: text)
            }
            .store(in: &cancellables)
    }
    
    public func getDialog() {
        let getDialog = GetDialog(dialogId: self.dialog.id,
                                  dialogsRepo: self.dialogsRepo)
        
        Task { [weak self] in
            do {
                let dialog = try await getDialog.execute()
                await MainActor.run { [weak self, dialog] in
                    self?.dialog = dialog
                    self?.displayDialogMembers()
                }
            } catch {
                prettyLog(error)
            }
        }
    }
    
    private func displayDialogMembers(by text: String = "") {
        if text.isEmpty || text.count > 2 {
            isSynced = false
            
            let getUsers = GetUsers(name: text, repo: Repository.users)
            let ids = dialog.participantsIds
            
            taskUsers?.cancel()
            taskUsers = Task { [weak self] in
                do {
                    let users = try await getUsers.execute()
                    try Task.checkCancellation()
                    
                    let filtered = users.filter { ids.contains($0.id) == false }
                    
                    await MainActor.run { [weak self, filtered] in
                        guard let self = self else { return }
                        self.displayed = filtered
                        self.isProcessing = false
                        self.isSynced = true
                    }
                } catch {
                    prettyLog(error)
                    if error is RepositoryException {
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.isProcessing = false
                            self.isSynced = true
                        }
                    }
                }
                self?.taskUsers = nil
            }
        }
    }
    
    deinit {
        taskUsers?.cancel()
        taskUsers = nil
        
        taskUpdate?.cancel()
        taskUpdate = nil
    }
    
    //MARK: - Users
    //MARK: - Public Methods
    @MainActor public func addSelectedUser() {
        guard let user = selected else { return }
        isProcessing = true
        dialog.pushIDs = [user.id]
        let updateDialog = UpdateDialog(dialog: dialog,
                                        users: [user],
                                        repo: Repository.dialogs)
        
        taskUpdate?.cancel()
        taskUpdate = nil
        taskUpdate = Task {
            do {
                try await updateDialog.execute()
                try Task.checkCancellation()
                await MainActor.run { [weak self, user] in
                    guard let self = self else { return }
                    self.dialog.participantsIds.append(user.id)
                    self.displayed = self.displayed.filter({ $0.id != user.id })
                    self.isProcessing = false
                }
            }  catch {
                prettyLog(error)
                if error is RepositoryException {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.isProcessing = false
                    }
                }
            }
        }
    }
}
