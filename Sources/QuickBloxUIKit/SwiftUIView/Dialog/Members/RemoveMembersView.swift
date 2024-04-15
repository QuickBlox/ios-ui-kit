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

    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject private var viewModel: ViewModel
    @State var isAlertPresented: Bool = false
    @State var isAddPresented: Bool = false
    
    init(viewModel: ViewModel,
         settings: MembersScreenSettings
         = QuickBloxUIKit.settings.membersScreen) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.settings = settings
    }
    
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
        
        .if(isAddPresented == true, transform: { view in
            view.navigationDestination(isPresented: $isAddPresented) {
                Fabric.screen.addMembers(to: viewModel.dialog)
            }
        })
        
        .modifier(MembersHeader(onAdd: {
            isAddPresented = true
        }))
        
        .disabled(viewModel.isProcessing == true)
        .if(viewModel.isProcessing == true) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
        .onViewDidLoad() {
            viewModel.sync()
        }
        .onDisappear {
            viewModel.unsync()
        }
    }
}
