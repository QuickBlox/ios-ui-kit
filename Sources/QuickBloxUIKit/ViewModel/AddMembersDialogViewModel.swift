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

open class AddMembersDialogViewModel: AddMembersDialogProtocol {
    @Published public var search: String = ""
    @Published public var displayed: [User] = []
    @Published public var selected: User? = nil
    @Published public var isProcessing: Bool = false
    @Published public var  isSynced: Bool = false
    
    private var dialog: Dialog
    
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<Task<Void, Never>>()
    
    private var taskUsers: Task<Void, Never>?
    private var taskUpdate: Task<Void, Never>?
    
    // use for PreviewProvider
    public init(_ dialog: Dialog) {
        self.dialog = dialog
    }
    
    public func sync() {
        displayDialogMembers()
        
        $search.eraseToAnyPublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.displayDialogMembers(by: text)
            }
            .store(in: &cancellables)
    }
    
    private func displayDialogMembers(by text: String = "") {
        if text.isEmpty || text.count > 2 {
            isSynced = false
            
            let getUsers = GetUsers(name: text, repo: RepositoriesFabric.users)
            let ids = dialog.participantsIds
            
            taskUsers?.cancel()
            taskUsers = nil
            taskUsers = Task { [weak self] in
                do {
                    let duration = UInt64(0.3 * 1_000_000_000)
                    try await Task.sleep(nanoseconds: duration)
                    try Task.checkCancellation()
                    
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
        let updateDialog = UpdateDialog(dialog: dialog,
                                        users: [user],
                                        repo: RepositoriesFabric.dialogs)
        
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
