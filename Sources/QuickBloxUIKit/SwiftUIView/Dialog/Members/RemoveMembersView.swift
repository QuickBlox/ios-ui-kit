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
    @State public var settings = QuickBloxUIKit.settings.membersScreen
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject public var viewModel: ViewModel
    
    @State var isAlertPresented: Bool = false
    @State var isAddPresented: Bool = false
    
    init(viewModel: ViewModel,
         settings: MembersScreenSettings
         = QuickBloxUIKit.settings.membersScreen) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.settings = settings
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
            Fabric.screen.addMembers(to: viewModel.dialog)
        } label: {
            EmptyView()
        }
    }
}

struct RemoveMembersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RemoveMembersView(viewModel: MembersPreviewModel())
                .previewDisplayName("Members View Light Delete")

            RemoveMembersView(viewModel: MembersPreviewModel())
                .previewDisplayName("Members View Dark Delete")
                .preferredColorScheme(.dark)
        }
    }
}

import Combine
private class MembersPreviewModel: MembersDialogProtocol {
    var dialog: QuickBloxData.Dialog = Dialog(id:"2b3c4d5e",
                                              type: .group,
                                              name: "Group Dialog",
                                              ownerId: "2b3c4d5e",
                                              lastMessage: LastMessage(id: "123456",
                                                                       text: "I'm not even going to pretend to understand what you're talking about.",
                                                                       dateSent: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                                                       userId: "23456"),
                                              unreadMessagesCount: 1)
    
    var selectedUser: QuickBloxData.User?
    var displayed: [QuickBloxData.User] = PreviewModel.users
    
    func removeUserFromDialog() {}

    var cancellables: Set<AnyCancellable> = []

    var tasks: Set<Task<Void, Never>> = []

    func sync() { }
}
