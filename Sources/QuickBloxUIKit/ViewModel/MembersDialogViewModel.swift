//
//  MembersDialogViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 22.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine
import QuickBloxLog

public protocol MembersDialogProtocol: QuickBloxUIKitViewModel {
    associatedtype UserItem: UserEntity
    associatedtype DialogItem: DialogEntity
    
    var displayed: [UserItem] { get set }
    var dialog: DialogItem { get set }
    var selectedUser: UserItem? { get set }
    
    func removeUserFromDialog()
}

open class MembersDialogViewModel: MembersDialogProtocol {
    @MainActor
    @Published public var displayed: [User] = []
    @Published public var selectedUser: User? = nil
    @Published public var dialog: Dialog
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    public private(set) var usersRepo: UsersRepository =
    RepositoriesFabric.users
    public let dialogsRepo: DialogsRepository
    
    private let updateDialogObserve: UpdateDialogObserver<Dialog, DialogsRepository>!
    
    private var taskUsers: Task<Void, Never>?
    private var taskUpdate: Task<Void, Never>?
    private var syncDialog: SyncDialog<Dialog,
                                       DialogsRepository,
                                       UsersRepository,
                                       MessagesRepository,
                                       Pagination>?
    private var syncSub: AnyCancellable?
    
    // use for PreviewProvider
    init(dialog: Dialog,
         usersRepo: UsersRepository = RepositoriesFabric.users,
         dialogsRepo: DialogsRepository = RepositoriesFabric.dialogs) {
        self.dialog = dialog
        self.usersRepo = usersRepo
        self.dialogsRepo = dialogsRepo
        self.syncDialog = nil
        
        updateDialogObserve = UpdateDialogObserver(repo: dialogsRepo, dialogId: dialog.id)
        
        updateDialogObserve.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialogId in
                if dialogId == self?.dialog.id {
                    self?.sync()
                }
            }
        .store(in: &cancellables)
    }
    
    public func sync() {
        syncDialog = SyncDialog(dialogId: dialog.id,
                                dialogsRepo: RepositoriesFabric.dialogs,
                                usersRepo: RepositoriesFabric.users,
                                messageRepo: RepositoriesFabric.messages)
        syncSub = syncDialog?.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] dialog in
                self?.dialog = dialog
                self?.showUsers(dialog)
            }
    }
    
    public func unsync() {
        syncSub?.cancel()
        syncSub = nil
        syncDialog = nil
    }
    
    //MARK: - Users
    //MARK: - Public Methods
    public func removeUserFromDialog() {
        taskUpdate = Task { [weak self] in
            do {
                guard let user = self?.selectedUser else { return }
                guard let dialog = self?.dialog else { return }
                let updateDialog = UpdateDialog(dialog: dialog,
                                                users: [user],
                                                repo: RepositoriesFabric.dialogs)
                try await updateDialog.execute()
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.sync()
                }
            }  catch { prettyLog(error) }
            self?.taskUpdate = nil
        }
    }
    
    //MARK: - Private Methods
    private func showUsers(_ dialog: Dialog,
                           name: String = "") {
        taskUsers?.cancel()
        taskUsers = nil
        taskUsers = Task { [weak self] in
            do {
                guard let repo = self?.usersRepo else { return }
                try Task.checkCancellation()
                let duration = UInt64(0.3 * 1_000_000_000)
                try await Task.sleep(nanoseconds: duration)
                try Task.checkCancellation()
                
                var getUsers: GetUsers<UserItem, UsersRepository>
                getUsers = GetUsers(ids: dialog.participantsIds,
                                    repo: repo)
                
                try Task.checkCancellation()
                let users = try await getUsers.execute()
                try Task.checkCancellation()
                
                await MainActor.run { [weak self, users] in
                    guard let self = self else { return }
                    self.displayed = users
                }
            } catch { prettyLog(error) }
        }
    }
    
    func search(_ name: String, pageNumber: UInt) {
        showUsers(dialog, name: name)
    }
}
