//
//  AddMembersView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData

public struct AddMembersView<ViewModel: MembersDialogProtocol>: View {
    let settings = QuickBloxUIKit.settings.addMembersScreen
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject public var viewModel: ViewModel
    
    @State var isPresented: Bool = false
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        container()
            .onAppear {
                viewModel.sync()
            }
            .onDisappear {
                viewModel.unsync()
            }
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            AddUserListView(items: viewModel.displayed, searchText: $viewModel.searchText,
                            onSelect: { item in
                // action Select Item
                viewModel.selectedUser = item
                isPresented.toggle()
            }, onAppearItem: { itemId in
                // action On Appear Item
            }, onNext: {
                // action On Next Page of Users
            }).blur(radius: isPresented ?settings.blurRadius : 0.0)
                .addUserAlert(isPresented: $isPresented,
                              name: viewModel.selectedUser?.name ?? "",
                              onCancel: {
                    viewModel.selectedUser = nil
                }, onTap: {
                    viewModel.addUserToDialog()
                })
        }
        .addMembersHeader(onDismiss: {
            dismiss()
        })
    }
}

//struct AddMembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            AddMembersView<PreviewDialog, User, AddUserListView<User>>(viewModel: MembersDialogViewModel<User, PreviewDialog>(dialog: PreviewModel.groupDialog))
//            .previewDisplayName("Members View Light Add")
//
//            AddMembersView<PreviewDialog, User, AddUserListView<User>>(viewModel: MembersDialogViewModel<User, PreviewDialog>(dialog: PreviewModel.groupDialog))
//            .previewDisplayName("Members View Dark Add")
//            .preferredColorScheme(.dark)
//        }
//    }
//}
