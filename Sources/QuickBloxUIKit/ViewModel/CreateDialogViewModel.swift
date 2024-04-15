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

public protocol CreateDialogProtocol: ObservableObject {
    associatedtype UserItem: UserEntity
    associatedtype DialogItem: DialogEntity
    
    var search: String { get set }
    var displayed: [UserItem] { get set }
    var selected: Set<UserItem> { get set }
    var isProcessing: Bool { get set }
    var isSynced: Bool { get set }
    var modeldDialog: DialogItem { get }
    
    func syncUsers()
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
    public init(modeldDialog: Dialog) {
        self.modeldDialog = modeldDialog
    }
    
    public func syncUsers() {
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
        if modeldDialog.type == .private {
            if selected.contains(where: { $0.id == item.id }) {
                return
            } else {
                selected = []
                selected.insert(item)
            }
        } else {
            if selected.contains(where: { $0.id == item.id }) {
                selected.remove(item)
            } else {
                selected.insert(item)
            }
        }
    }
    
    // MARK: - Dialogs
    public func createDialog() {
        if modeldDialog.type == .private, selected.isEmpty == true { return }
        
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
                    self?.createTask = nil
                }
            } catch {
                prettyLog(error)
                await MainActor.run { [weak self] in
                    self?.isProcessing = false
                    self?.createTask = nil
                }
            }
        }
    }
}
