//
//  CreateDialogViewModel.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import QuickBloxLog
import Combine

public protocol CreateDialogProtocol: QuickBloxUIKitViewModel {
    associatedtype UserItem: UserEntity
    associatedtype UsersRepo: UsersRepositoryProtocol
    associatedtype DialogItem: DialogEntity
    associatedtype DialogsRepo: DialogsRepositoryProtocol
    
    var searchText: String { get set }
    var diaplayed: [UserItem] { get set }
    var selected: Set<UserItem> { get set }
    var isProcessing: CurrentValueSubject<Bool, Never> { get set }
    
    var dialogsRepo: DialogsRepo { get }
    var usersRepo: UsersRepo { get }
    
    var modeldDialog: DialogItem { get }
    
    func handleOnSelect(_ item: UserItem)
    
    func createGroupDialog()
    func createPrivateDialog()
}

open class CreateDialogViewModel: CreateDialogProtocol {
    @Published public var searchText = ""
    @MainActor
    @Published public var diaplayed: [User] = []
    @Published public var selected: Set<User> = []
    @Published public var isProcessing = CurrentValueSubject<Bool, Never>(false)
    
    public var modeldDialog: Dialog
    
    public var cancellables = Set<AnyCancellable>()
    
    //MARK: - Properties
    private var isLoadAll = false
    
    private var taskUsers: Task<Void, Never>?
    public var tasks: Set<Task<Void, Never>>
    
    var isSearchingPublisher: AnyPublisher<Bool, Never> {
        $searchText
            .map { searchText in
                if searchText.count > 2 {
                    self.showUsers(by: searchText)
                }
                return searchText.isEmpty == false
            }
            .eraseToAnyPublisher()
    }
    
    public private(set) var dialogsRepo: DialogsRepository =
    RepositoriesFabric.dialogs
    public private(set) var usersRepo: UsersRepository =
    RepositoriesFabric.users
    
    // use for PreviewProvider
    init(users: [User],
         modeldDialog: Dialog,
         dialogsRepo: DialogsRepository = RepositoriesFabric.dialogs,
         usersRepo: UsersRepository = RepositoriesFabric.users) {
        self.modeldDialog = modeldDialog
        self.dialogsRepo = dialogsRepo
        self.usersRepo = usersRepo
        self.tasks = []
    }
    
    public func sync() {
        isSearchingPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { isSearching in
                if isSearching == false {
                    self.showUsers()
                }
            })
            .store(in: &cancellables)
    }
    
    private func show(users: [User]) {
        Task {
            await MainActor.run { [users] in
                self.diaplayed = users
            }
        }
    }
    
    private func showUsers(by name: String = "") {
        taskUsers?.cancel()
        taskUsers = nil
        taskUsers = Task {
            do {
                prettyLog(label: "Need show users by name", name)
                try Task.checkCancellation()
                let duration = UInt64(0.3 * 1_000_000_000)
                try await Task.sleep(nanoseconds: duration)
                try Task.checkCancellation()
                var getUsers: GetUsers<UserItem, UsersRepo>
                if name.isEmpty {
                    getUsers = GetUsers(repo: RepositoriesFabric.users)
                } else {
                    getUsers = GetUsers(name: name,
                                        repo: RepositoriesFabric.users)
                }
                try Task.checkCancellation()
                let users = try await getUsers.execute()
                try Task.checkCancellation()
                await MainActor.run { [users] in
                    var toDisplay: [User] = []
                    for user in self.selected {
                        toDisplay.append(user)
                    }
                    let filtered = users.filter {
                        self.selected.contains($0) == false
                        && $0.isCurrent == false
                    }
                    toDisplay.append(contentsOf: filtered)
                    self.diaplayed = toDisplay
                }
            } catch { print(error) }
        }
    }
    
    deinit {
        taskUsers?.cancel()
        taskUsers = nil
    }
    
    //MARK: - Users
    //MARK: - Public Methods
    public func handleOnSelect(_ item: User) {
        didSelect(single: modeldDialog.type == .private, item: item)
    }
    
    // MARK: - Dialogs
    //TODO: remove dublicated methods
    public func createGroupDialog() {
        createDialog()
    }
    
    public func createPrivateDialog() {
        createDialog()
    }
    
    public func createDialog() {
        isProcessing.value = true
        modeldDialog.participantsIds = selected.map { $0.id }
        let task = Task {
            do {
                let create = CreateDialog(dialog: self.modeldDialog,
                                          repo: dialogsRepo)
                try await create.execute()
                self.isProcessing.value = false
            } catch { prettyLog(error) }
        }
        tasks.insert(task)
    }
}

extension CreateDialogViewModel {
    public convenience init(modeldDialog: Dialog) {
        self.init(users: [],
                  modeldDialog: modeldDialog)
    }
    
    func didSelect(single: Bool, item: User) {
        if selected.contains(item) == true {
            selected.remove(item)
        } else {
            if single {
                selected = []
            }
            selected.insert(item)
        }
    }
}

class CreateDialogViewModelMock: CreateDialogProtocol {
    var cancellables: Set<AnyCancellable>
    
    var tasks: Set<Task<Void, Never>>
    
    func sync() {
        
    }
    
    func handleOnSelect(_ item: User) {
        
    }
    
    var createdDialog: PreviewDialog? = nil
    
    var dialogsRepo: DialogsRepository = RepositoriesFabric.dialogs
    
    var usersRepo: UsersRepository = RepositoriesFabric.users
    
    var modeldDialog: PreviewDialog
    
    typealias UserItem = User
    
    typealias UsersRepo = UsersRepository
    
    typealias DialogItem = PreviewDialog
    
    typealias DialogsRepo = DialogsRepository
    
    @Published public var searchText = ""
    @Published public var selected: Set<User> = []
    @Published public var isProcessing = CurrentValueSubject<Bool, Never>(false)
    @Published public var diaplayed: [User] = []
    
    func createGroupDialog() {

    }
    
    func createPrivateDialog() {
 
    }
    
    init(users: [User],
         modeldDialog: PreviewDialog,
         dialogsRepo: DialogsRepository = RepositoriesFabric.dialogs,
         usersRepo: UsersRepository = RepositoriesFabric.users) {
        self.diaplayed = users
        self.modeldDialog = modeldDialog
        self.dialogsRepo = dialogsRepo
        self.usersRepo = usersRepo
        self.tasks = []
        self.cancellables = []
    }
}
