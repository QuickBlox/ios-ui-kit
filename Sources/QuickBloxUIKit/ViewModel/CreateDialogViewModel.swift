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

public protocol CreateDialogProtocol: ObservableObject
//: QuickBloxUIKitViewModel
{
    associatedtype UserItem: UserEntity
    associatedtype DialogItem: DialogEntity
    
    var search: String { get set }
    var displayed: [UserItem] { get set }
    var selected: Set<UserItem> { get set }
    var isProcessing: Bool { get set }
    var isSynced: Bool { get set }
    var modeldDialog: DialogItem { get }
    
    func sync()
    func handleOnSelect(_ item: UserItem)
    func createDialog()
}

final class CreateDialogViewModel: CreateDialogProtocol {
    public typealias UserItem = User
    
    @Published public var search = ""
    @Published public var displayed: [User] = []
    @Published public var selected: Set<User> = []
    @Published public var  isProcessing: Bool = false
    @Published public var  isSynced: Bool = false
    
    public var modeldDialog: Dialog
    
    public var cancellables = Set<AnyCancellable>()
    
    private var taskUsers: Task<Void, Never>?

    public var tasks = Set<Task<Void, Never>>()
    private var createTask: Task<Void, Never>?
    
    // use for PreviewProvider
    public init(users: [User],
         modeldDialog: Dialog) {
        self.modeldDialog = modeldDialog
    }
    
    public func sync() {
        displayMembers()
        
        $search.eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.displayMembers(by: text)
            }
            .store(in: &cancellables)
    }
    
    private func displayMembers(by text: String = "") {
        if isProcessing == true {
            return
        }
        
        if text.isEmpty || text.count > 2 {
            isSynced = false
            
            let getUsers = GetUsers(name: text, repo: RepositoriesFabric.users)
            
            taskUsers?.cancel()
            taskUsers = nil
            taskUsers = Task { [weak self] in
                do {
                    let users = try await getUsers.execute()
                    try Task.checkCancellation()
                    
                    await MainActor.run { [weak self, users] in
                        guard let self = self else { return }
                        var toDisplay: [User] = []
                        for user in self.selected {
                            toDisplay.append(user)
                        }
                        let filtered = users.filter {
                            self.selected.contains($0) == false
                            && $0.isCurrent == false
                        }
                        toDisplay.append(contentsOf: filtered)
                        self.displayed = toDisplay
                        self.isSynced = true
                    }
                    
                } catch {
                    prettyLog(error)
                    if error is RepositoryException {
                        await MainActor.run { [weak self] in
                            self?.isSynced = true
                        }
                    }
                }
            }
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
    public func createDialog() {
        isProcessing = true
        modeldDialog.participantsIds = selected.map { $0.id }
        if modeldDialog.photo.isEmpty {
            modeldDialog.photo = ""
        }
        createTask = Task { [weak self] in
            do {
                guard let dialog = self?.modeldDialog else { return }
                let create = CreateDialog(dialog: dialog,
                                          repo: RepositoriesFabric.dialogs)
                try await create.execute()
                
                await MainActor.run { [weak self] in
                    self?.isProcessing = false
                }
                self?.createTask = nil
            } catch {
                prettyLog(error)
                if error is RepositoryException {
                    await MainActor.run { [weak self] in
                        self?.isProcessing = false
                    }
                    self?.createTask = nil
                }
            }
            
        }
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
    
    @Published public var search = ""
    @Published public var selected: Set<User> = []
    @Published public var isProcessing = false
    @Published public var displayed: [User] = []
    @Published public var  isSynced: Bool = false
    
    func createDialog() {
        
    }
    
    init(users: [User],
         modeldDialog: PreviewDialog,
         dialogsRepo: DialogsRepository = RepositoriesFabric.dialogs,
         usersRepo: UsersRepository = RepositoriesFabric.users) {
        self.displayed = users
        self.modeldDialog = modeldDialog
        self.dialogsRepo = dialogsRepo
        self.usersRepo = usersRepo
        self.tasks = []
        self.cancellables = []
    }
}
