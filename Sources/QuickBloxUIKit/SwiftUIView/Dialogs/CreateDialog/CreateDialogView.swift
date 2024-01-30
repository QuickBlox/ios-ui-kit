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
                    UserItem: UserEntity,
                    ListView: View>: View
where DialogItem == ViewModel.DialogItem, UserItem == ViewModel.UserItem {
    let settings = QuickBloxUIKit.settings.createDialogScreen
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) private var isSearching: Bool
    @State private var onTapCreate: Bool = false
    
    let onDismiss: () -> Void
    
    @StateObject public var viewModel: ViewModel
    
    init(viewModel: ViewModel,
         onDismiss: @escaping () -> Void,
        @ViewBuilder content: @escaping (_ viewModel: ViewModel) -> ListView) {
        self.content = content
        self.onDismiss = onDismiss
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var content: (_ viewModel: ViewModel) -> ListView
    
    public var body: some View {
        if isIphone {
            container()
        } else if isIPad {
            NavigationStack {
                container()
            }.accentColor(settings.header.leftButton.color)
        }
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            content(viewModel)
        }
        
        .disabled(viewModel.isProcessing == true)
        .if(viewModel.isProcessing == true) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
        
        .modifier(CreateDialogHeader(onDismiss: {
            dismiss()
            onDismiss()
        }, onTapCreate: {
            onTapCreate.toggle()
            viewModel.createDialog()
        }, disabled: viewModel.isProcessing == true))
    }
}

struct CreateDialog_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            CreateDialog(viewModel: CreateDialogViewModelMock(users: PreviewModel.users, modeldDialog: PreviewModel.groupDialog)) { items, searchText, selected, onSelect, onAppearItem, onNext in
//                UserListView(items: PreviewModel.users, selected: Binding.constant(Set(PreviewModel.selectedUsersIds)), content: { item, isSelected, onTap in
//                    UserRow(item, isSelected: isSelected, onTap: onTap)
//                }, onSelect: onSelect, onAppearItem: onAppearItem, onNext: onNext)
//            }
//            .previewDisplayName("Create Dialog View")
//            
//            CreateDialog(viewModel: CreateDialogViewModelMock(users: PreviewModel.users, modeldDialog: PreviewModel.groupDialog)) { items, searchText, selected, onSelect, onAppearItem, onNext in
//                UserListView(items: PreviewModel.users, selected: Binding.constant(Set(PreviewModel.selectedUsersIds)), content: { item, isSelected, onTap in
//                    UserRow(item, isSelected: isSelected, onTap: onTap)
//                }, onSelect: onSelect, onAppearItem: onAppearItem, onNext: onNext)
//            }
//            .preferredColorScheme(.dark)
//            .previewDisplayName("Dark Create Dialog View")
        }
    }
}

