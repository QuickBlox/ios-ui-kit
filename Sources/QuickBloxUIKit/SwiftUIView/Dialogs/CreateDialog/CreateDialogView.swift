//
//  CreateDialogView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 29.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData

struct CreateDialogView<ViewModel: CreateDialogProtocol,
                    DialogItem: DialogEntity,
                    UserItem: UserEntity>: View
where DialogItem == ViewModel.DialogItem, UserItem == ViewModel.UserItem {
    let settings = QuickBloxUIKit.settings.createDialogScreen

    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        if isIphone {
            container()
                .onViewDidLoad {
                    viewModel.syncUsers()
                }
        } else {
            NavigationStack {
                container()
                .onViewDidLoad {
                    viewModel.syncUsers()
                }
            }.accentColor(settings.header.leftButton.color)
        }
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            UserListView(viewModel: viewModel) { item, isSelected, onSelect in
                UserRow(item, isSelected: isSelected, onTap: onSelect)
            }
        }
        
        .disabled(viewModel.isProcessing == true)
        .if(viewModel.isProcessing == true) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
        
        .modifier(CreateDialogHeader(onDismiss: {
            dismiss()
        }, onTapCreate: {
            viewModel.createDialog()
        }, disabled: viewModel.isProcessing == true))
    }
}
