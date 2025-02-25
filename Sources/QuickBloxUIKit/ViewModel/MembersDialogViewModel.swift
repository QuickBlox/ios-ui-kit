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
    var isProcessing: Bool { get set }
    
    func removeUserFromDialog()
    func getNextUsers()
}

final class MembersDialogViewModel: MembersDialogProtocol {
    @MainActor
    @Published public var displayed: [User] = []
    @Published public var selectedUser: User? = nil
    @Published public var dialog: Dialog
    @Published public var isProcessing: Bool = false
    
    public private(set) var usersRepo: UsersRepository = Repository.users
    public private(set) var dialogsRepo: DialogsRepository = Repository.dialogs
    
    private var updateDialogLocalObserve: DialogUpdateObserver<DialogsRepository>!
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    private var taskUpdate: Task<Void, Never>?
    
    private var pagination: Pagination = Pagination(skip: 0)
    
    init(dialog: Dialog,
         usersRepo: UsersRepository = Repository.users,
         dialogsRepo: DialogsRepository = Repository.dialogs) {
        self.dialog = dialog
        self.usersRepo = usersRepo
        self.dialogsRepo = dialogsRepo
        
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
    
    private func update(with newUsers: GetUsers<User, Pagination, UsersRepository>,
                        filterIds: [String] = [],
                        force: Bool) {
        Task { [weak self] in
            do {
                let result = try await newUsers.execute()
                try Task.checkCancellation()
                
                let filtered = result.users.filter { filterIds.contains($0.id) == false }
                let page = result.pagination
                
                await MainActor.run { [weak self, filtered, page, force] in
                    guard let self = self else { return }
                    self.pagination = page
                    self.isProcessing = false
                    if force {
                        self.displayed = filtered
                    } else {
                        self.displayed.append(contentsOf: filtered)
                    }
                }
            } catch {
                prettyLog(error)
                await MainActor.run { [weak self] in
                    self?.isProcessing = false
                }
            }
        }
    }
    
    public func getNextUsers() {
        if pagination.hasNext == false {
            return
        }
        
        pagination.next()
        
        let getUsers = GetUsers(ids: dialog.participantsIds,
                                pagination: pagination,
                                repo: Repository.users)
        let ids: [String] = displayed.map { $0.id }
        
        update(with: getUsers, filterIds: ids, force: false)
    }
    
    public func getDialog() {
        let getDialog = GetDialog(dialogId: self.dialog.id,
                                  dialogsRepo: self.dialogsRepo)
        
        Task { [weak self] in
            do {
                let dialog = try await getDialog.execute()
                
                await MainActor.run { [weak self, dialog] in
                    self?.dialog = dialog
                }
                
                guard let repo = self?.usersRepo else { return }

                let getUsers = GetUsers(ids: dialog.participantsIds,
                                        pagination: Pagination(skip: 0),
                                        repo: repo)
                self?.update(with: getUsers, force: true)
            } catch {
                prettyLog(error)
                await MainActor.run { [weak self] in
                    self?.isProcessing = false
                }
            }
        }
    }
    
    public func sync() {
        getDialog()
    }
    
    //MARK: - Users
    //MARK: - Public Methods
    public func removeUserFromDialog() {
        isProcessing = true
        guard let user = selectedUser else { return }
        dialog.pullIDs = [user.id]
        taskUpdate = Task { [weak self] in
            do {
                guard let dialog = self?.dialog else { return }
                let updateDialog = UpdateDialog(dialog: dialog,
                                                users: [user],
                                                repo: Repository.dialogs)
                try await updateDialog.execute()
            }  catch {
                prettyLog(error)
                await MainActor.run { [weak self] in
                    self?.isProcessing = false
                    self?.taskUpdate = nil
                }
            }
        }
    }
}
