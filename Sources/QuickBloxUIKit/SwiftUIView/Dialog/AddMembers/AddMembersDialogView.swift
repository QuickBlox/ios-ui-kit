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
    
    @StateObject public var viewModel: ViewModel
    
    @State var isPresented: Bool = false
    
    init(viewModel: ViewModel,
         settings: AddMembersScreenSettings
         = QuickBloxUIKit.settings.addMembersScreen) {
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
            
            AddUserListView(items: viewModel.displayed, isSynced: viewModel.isSynced, searchText: $viewModel.search,
                            onSelect: { item in
                viewModel.selected = item
                isPresented.toggle()
            }, onAppearItem: { itemId in
                // action On Appear Item
            }, onNext: {
                // action On Next Page of Users
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

struct AddMembersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddMembersDialogView(viewModel: AddMembersPreviewModel())
            .previewDisplayName("Members View Light Add")

            AddMembersDialogView(viewModel: AddMembersPreviewModel())
            .previewDisplayName("Members View Dark Add")
            .preferredColorScheme(.dark)
        }
    }
}

import Combine
private class AddMembersPreviewModel: AddMembersDialogProtocol {
    var  isSynced: Bool = false
    var isProcessing: Bool = false
    
    var displayed: [QuickBloxData.User] = PreviewModel.users
    
    var selected: QuickBloxData.User?
    
    var search: String = ""
    
    func addSelectedUser() { }
    
    var cancellables: Set<AnyCancellable> = []
    
    var tasks: Set<Task<Void, Never>> = []
    
    func sync() { }
}
