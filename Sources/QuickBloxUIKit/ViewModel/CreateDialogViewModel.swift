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
    var isAdding: Bool { get set }
    var modeldDialog: DialogItem { get }
    
    func syncUsers()
    func handleOnSelect(_ item: UserItem)
    func createDialog()
    func getNextUsers()
}

final class CreateDialogViewModel: CreateDialogProtocol {
    public typealias UserItem = User
    
    @Published public var search = ""
    @Published public var displayed: [User] = []
    @Published public var selected: Set<User> = []
    @Published public var  isProcessing: Bool = false
    @Published public var  isSynced: Bool = false
    @Published public var isAdding: Bool = false
    
    public var modeldDialog: Dialog
    
    public var cancellables = Set<AnyCancellable>()
    
    private var taskUsers: Task<Void, Never>?

    public var tasks = Set<Task<Void, Never>>()
    private var createTask: Task<Void, Never>?
    
    private var pagination: Pagination = Pagination(skip: 0)
    
    // use for PreviewProvider
    public init(modeldDialog: Dialog) {
        self.modeldDialog = modeldDialog
    }
    
    public func syncUsers() {
        displayMembers()
        
        $search.eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.displayMembers(by: text)
            }
            .store(in: &cancellables)
    }
    
    private func update(with newUsers: GetUsers<User, Pagination, UsersRepository>,
                        fileterIds: [String],
                        force: Bool) {
        taskUsers?.cancel()
        taskUsers = Task { [weak self] in
            do {
                let result = try await newUsers.execute()
                try Task.checkCancellation()
                
                let filtered = result.users.filter { fileterIds.contains($0.id) == false
                    && $0.isCurrent == false}
                let paginaiton = result.pagination
                
                await MainActor.run { [weak self, filtered, paginaiton, force] in
                    guard let self = self else { return }
                    self.pagination = paginaiton
                    self.isSynced = true
                    self.isAdding = false
                    if force {
                        var toDisplay: [User] = Array(self.selected)
                        toDisplay.append(contentsOf: filtered)
                        self.displayed = toDisplay
                    } else {
                        self.displayed.append(contentsOf: filtered)
                    }
                }
                
            } catch {
                prettyLog(error)
                if error is RepositoryException {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.isSynced = true
                        self.isAdding = false
                    }
                }
            }
            
            self?.taskUsers = nil
        }
    }
    
    public func getNextUsers() {
        if pagination.hasNext == false {
            return
        }
        pagination.next()
        
        self.isAdding = true
        
        let text = search.count > 2 ? search : ""
        
        let getUsers = GetUsers(name: text,
                                pagination: pagination,
                                repo: Repository.users)
        let ids: [String] = displayed.map { $0.id }
        
        update(with: getUsers, fileterIds: ids, force: false)
    }
    
    private func displayMembers(by text: String = "") {
        if isProcessing == true {
            return
        }
        
        if text.isEmpty || text.count > 2 {
            isSynced = false
            
            let getUsers = GetUsers(name: text,
                                    pagination: Pagination(skip: 0),
                                    repo: Repository.users)
            let ids: [String] = selected.map { $0.id }
            
            update(with: getUsers, fileterIds: ids, force: true)
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
                                          repo: Repository.dialogs)
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
