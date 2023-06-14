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
    associatedtype DialogItem: DialogEntity
    associatedtype UsersRepo: UsersRepositoryProtocol
    
    var displayed: [UserItem] { get set }
    var dialog: DialogItem { get set }
    var selectedUser: UserItem? { get set }
    var usersRepo: UsersRepo { get }
    
    var searchText: String { get set }
    func addUserToDialog()
}

open class AddMembersDialogViewModel: AddMembersDialogProtocol {
    @Published public var searchText = ""
    @MainActor
    @Published public var displayed: [User] = []
    @Published public var selectedUser: User? = nil
    @Published public var isLoading = CurrentValueSubject<Bool, Never>(false)
    
    @Published public var dialog: Dialog
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    public private(set) var usersRepo: UsersRepository =
    RepositoriesFabric.users
    
    private var taskUsers: Task<Void, Never>?
    private var taskUpdate: Task<Void, Never>?
    private var syncDialog: SyncDialog<Dialog,
                                       DialogsRepository,
                                       UsersRepository,
                                       MessagesRepository,
                                       Pagination>?
    private var syncSub: AnyCancellable?
    
    var isSearchingPublisher: AnyPublisher<Bool, Never> {
        $searchText
            .map { searchText in
                if searchText.count > 2 {
                    self.search(searchText, pageNumber: 1)
                }
                return searchText.isEmpty == false
            }
            .eraseToAnyPublisher()
    }
    
    // use for PreviewProvider
    init(dialog: Dialog,
         usersRepo: UsersRepository = RepositoriesFabric.users) {
        self.dialog = dialog
        self.usersRepo = usersRepo
        self.syncDialog = nil
    }
    
    public func sync() {
        showUsers(dialog)
        isSearchingPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] isSearching in
                if isSearching == false {
                    self?.search("", pageNumber: 1)
                }
            })
            .store(in: &cancellables)
    }
    
    public func unsync() {
        syncSub?.cancel()
        syncSub = nil
        syncDialog = nil
    }
    
    //MARK: - Users
    //MARK: - Public Methods
    @MainActor public func addUserToDialog() {
        taskUpdate = Task { [weak self] in
            do {
                guard let user = self?.selectedUser else { return }
                guard let dialog = self?.dialog else { return }
                let updateDialog = UpdateDialog(dialog: dialog,
                                                users: [user],
                                                repo: RepositoriesFabric.dialogs)
                try await updateDialog.execute()
                await MainActor.run {
                    if let users = self?.displayed.filter({ $0.id != user.id }) {
                        self?.displayed = users
                    }
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
                
                var getUsers: GetUsers<UserItem, UsersRepo>
                
                if name.isEmpty {
                    getUsers = GetUsers(repo: repo)
                } else {
                    getUsers = GetUsers(name: name, repo: repo)
                }
                
                try Task.checkCancellation()
                let users = try await getUsers.execute()
                try Task.checkCancellation()
                
                var toDisplay: [User] = []
                
                let filtered = users.filter {
                    dialog.participantsIds.contains($0.id) == false
                }
                toDisplay.append(contentsOf: filtered)
                
                await MainActor.run { [weak self, toDisplay] in
                    guard let self = self else { return }
                    self.displayed = toDisplay
                }
            } catch { prettyLog(error) }
        }
    }
    
    func fetchWithPage(_ pageNumber: UInt) {
        
    }

    func append( _ users: [User]) {
        
    }
    
    func search(_ name: String, pageNumber: UInt) {
        showUsers(dialog, name: name)
    }
    
    func searchNext(_ name: String) {
    }
    
    
    // MARK: - Dialogs
    func updateDialog() {
    }
}
