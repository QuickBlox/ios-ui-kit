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

class Sync {
    let state: AnyPublisher<SyncState, Never>
    private let useCase: SyncData<DialogsRepository,
                                  UsersRepository,
                                  ConnectionRepository,
                                  Pagination>
    
    init() {
        self.useCase = SyncData(dialogsRepo: RepositoriesFabric.dialogs,
                                usersRepo: RepositoriesFabric.users,
                                connectRepo: RepositoriesFabric.connection)
        self.state = useCase.execute()
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

//FIXME: add dialogsView screen
@ViewBuilder
public func dialogsView() -> some View {
    DialogsView(dialogsList: DialogsList(dialogsRepo: RepositoriesFabric.dialogs),
                content: { dialogsList in
        DialogsListView(dialogsList: dialogsList,
                        content: DialogsRowBuilder.defaultRow)
    }, detailContent: { item, isPresented in
        DialogView(viewModel: DialogViewModel(dialog: item), isDialogPresented: isPresented)
    }, selectTypeContent: { onClose in
        DialogTypeView(onClose: onClose)
    }).onAppear {
        syncData()
    }
}
