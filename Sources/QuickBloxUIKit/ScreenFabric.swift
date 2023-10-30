//
//  ScreenFabric.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 18.06.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public class Fabric {
    public static var screen: ScreenFabric = ScreenFabric()
}

public class ScreenFabric { }

// Creating the screen for adding participants to a dialogue.
public extension ScreenFabric {
    @MainActor func addMembers<T: DialogEntity>(
        to entity: T,
        settings: AddMembersScreenSettings
        = QuickBloxUIKit.settings.addMembersScreen
    ) -> some View {
        let model = AddMembersDialogViewModel(Dialog(entity))
        return addMembersView(model: model,
                              settings:settings)
    }
    
    func addMembersView<T: AddMembersDialogProtocol>(
        model: T,
        settings: AddMembersScreenSettings
        = QuickBloxUIKit.settings.addMembersScreen
    ) -> some View {
        return AddMembersDialogView(viewModel: model,
                                    settings: settings)
    }
}

// Creating the screen for remove participants from a dialogue.
public extension ScreenFabric {
    @MainActor func members<T: DialogEntity>(
        to entity: T,
        settings: MembersScreenSettings
        = QuickBloxUIKit.settings.membersScreen
    ) -> some View {
        let model = MembersDialogViewModel(dialog: Dialog(entity))
        return membersView(model: model,
                              settings:settings)
    }
    
    func membersView<T: MembersDialogProtocol>(
        model: T,
        settings: MembersScreenSettings
        = QuickBloxUIKit.settings.membersScreen
    ) -> some View {
        return RemoveMembersView(viewModel: model,
                                    settings: settings)
    }
}
