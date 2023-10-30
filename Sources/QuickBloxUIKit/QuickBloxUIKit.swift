//
//  PreviewUtils.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine
import QuickBloxLog

@MainActor
public protocol QuickBloxUIKitViewModel: ObservableObject {
    var cancellables: Set<AnyCancellable> { get set}
    var tasks: Set<Task<Void, Never>> { get set}
    func sync()
    func unsync()
}

extension QuickBloxUIKitViewModel {
    public func unsync() {
        prettyLog("Unsync Use Cases")
        
        tasks.forEach { if $0.isCancelled == false { $0.cancel() } }
        tasks.removeAll()
    }
}

//Identifies if XCode is running for previews
var previewAware: Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

public var settings: ScreensProtocol = ScreenSettings(Theme())
public var feature: Feature = Feature()

class Sync {
    var state: AnyPublisher<SyncState, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    private var subject: PassthroughSubject<SyncState, Never>
    = PassthroughSubject<SyncState, Never>()
    
    private let useCase: SyncData<DialogsRepository,
                                  UsersRepository,
                                  MessagesRepository,
                                  ConnectionRepository,
                                  Pagination>
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init() {
        useCase = SyncData(dialogsRepo: RepositoriesFabric.dialogs,
                           usersRepo: RepositoriesFabric.users,
                           messagesRepo: RepositoriesFabric.messages,
                           connectRepo: RepositoriesFabric.connection)
        useCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] state in
                self?.subject.send(state)
            })
            .store(in: &cancellables)
    }
}

var syncState: AnyPublisher<SyncState, Never> {
    syncData()
    return sync!.state
}

var sync: Sync?

private func syncData() {
    if sync == nil {
        sync = Sync()
    }
}

let imageCache = ImageCache.shared

//FIXME: add dialogsView screen
@MainActor @ViewBuilder
public func dialogsView(onExit: (() -> Void)? = nil, onAppear: ((Bool) -> Void)? = nil) -> some View {
    DialogsView(dialogsList: DialogsViewModel(dialogsRepo: RepositoriesFabric.dialogs),
                content: { dialogsList in
        DialogsListView(dialogsList: dialogsList, detailContent: { item, onDismiss in
            if item.type == .group {
                GroupDialogView(viewModel: DialogViewModel(dialog: item), onDismiss: onDismiss)
            } else if item.type == .private {
                PrivateDialogView(viewModel: DialogViewModel(dialog: item), onDismiss: onDismiss)
            }
        },
                        content: DialogsRowBuilder.defaultRow)
    }, detailContent: { item, onDismiss in
        if item.type == .group {
            GroupDialogView(viewModel: DialogViewModel(dialog: item), onDismiss: onDismiss)
        } else if item.type == .private {
            PrivateDialogView(viewModel: DialogViewModel(dialog: item), onDismiss: onDismiss)
        }
    }, selectTypeContent: { onClose in
        DialogTypeView(onClose: onClose)
    }, onBack: {
        onExit?()
    }, onAppear: { appear in
        onAppear?(appear)
    })
    .onAppear {
        syncData()
    }
}
