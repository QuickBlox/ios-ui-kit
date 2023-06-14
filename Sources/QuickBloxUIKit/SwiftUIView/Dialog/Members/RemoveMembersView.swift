//
//  RemoveMembersView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData

public struct RemoveMembersView<ViewModel: MembersDialogProtocol>: View {
    let settings = QuickBloxUIKit.settings.membersScreen
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject public var viewModel: ViewModel
    
    @State var isAlertPresented: Bool = false
    @State var isAddPresented: Bool = false
    
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
            
            RemoveUserListView(items: viewModel.displayed,
                               isAdmin: viewModel.dialog.isOwnedByCurrentUser,
                               ownerId: viewModel.dialog.ownerId,
                               onSelect: { item in
                // action Select Item
                if viewModel.dialog.participantsIds.contains(where: { $0 == item.id }) == false {
                    return
                }
                viewModel.selectedUser = item
                isAlertPresented.toggle()
            }, onAppearItem: { itemId in
                // action On Appear Item
            }, onNext: {
                // action On Next Page of Users
            }).blur(radius: isAlertPresented ? settings.blurRadius : 0.0)
        }
        
        .removeUserAlert(isPresented: $isAlertPresented,
                         name: viewModel.selectedUser?.name ?? "",
                         onCancel: {
            viewModel.selectedUser = nil
        }, onTap: {
            viewModel.removeUserFromDialog()
        })
        
        .membersHeader(onDismiss: {
            dismiss()
        }, onAdd: {
            isAddPresented.toggle()
        })
        
        NavigationLink(isActive: $isAddPresented) {
            if let dialog = viewModel.dialog as? Dialog {
                AddMembersView(viewModel: AddMembersDialogViewModel(dialog: dialog))
            }
        } label: {
            EmptyView()
        }
    }
}

//struct RemoveMembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            RemoveMembersView<PreviewDialog, User, RemoveUserListView<User>, RemoveUserRow>(viewModel: MembersDialogViewModel<User, PreviewDialog>(dialog: PreviewModel.groupDialog))
//                .previewDisplayName("Members View Light Delete")
//
//            RemoveMembersView<PreviewDialog, User, RemoveUserListView<User>, RemoveUserRow>(viewModel: MembersDialogViewModel<User, PreviewDialog>(dialog: PreviewModel.groupDialog))
//                .previewDisplayName("Members View Dark Delete")
//                .preferredColorScheme(.dark)
//        }
//    }
//}
