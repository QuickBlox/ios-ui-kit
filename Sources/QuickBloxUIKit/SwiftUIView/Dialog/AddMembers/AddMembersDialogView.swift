//
//  AddMembersDialogView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData

public struct AddMembersDialogView<ViewModel: AddMembersDialogProtocol>: View {
    @State public var settings
    = QuickBloxUIKit.settings.addMembersScreen

    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject private var viewModel: ViewModel

    @State var isPresented: Bool = false
    
    init(viewModel: ViewModel,
         settings: AddMembersScreenSettings
         = QuickBloxUIKit.settings.addMembersScreen) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.settings = settings
    }
    
    public var body: some View {
        container()
            .onViewDidLoad() {
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
            
            AddUserListView(items: viewModel.displayed,
                            isSynced: viewModel.isSynced,
                            isAdding: viewModel.isAdding,
                            searchText: $viewModel.search,
                            onSelect: { item in
                viewModel.selected = item
                isPresented.toggle()
            }, onAppearItem: { itemId in
                // action On Appear Item
            }, onNext: {
                // action On Next Page of Users
                viewModel.getNextUsers()
            }).blur(radius: isPresented ?settings.blurRadius : 0.0)
                .addUserAlert(isPresented: $isPresented,
                              name: viewModel.selected?.name ?? "",
                              onCancel: {
                    viewModel.selected = nil
                }, onTap: {
                    viewModel.addSelectedUser()
                })
        }
        
        .addMembersHeader()
        
        .disabled(viewModel.isProcessing == true)
        .if(viewModel.isProcessing == true) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
    }
}
