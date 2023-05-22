//
//  UserListView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 18.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine

public struct UserListView<ViewModel: CreateDialogProtocol, UserItem: UserEntity, UserView: View> where UserItem == ViewModel.UserItem {
    @Environment(\.isSearching) private var isSearching: Bool
    
    @ObservedObject public var viewModel: ViewModel
    
    let settings = QuickBloxUIKit.settings.createDialogScreen
    
    private var content: (_ item: UserItem,
                          _ isSelected: Bool,
                          _ onSelect: @escaping (_ user: UserItem) -> Void) -> UserView
    
    @State private var visibleRows: Set<String> = []
    
    
    
    public init(viewModel: ViewModel,
                @ViewBuilder content: @escaping (_ item: UserItem,
                                                 _ isSelected: Bool,
                                                 _ onSelect: @escaping (_ user: UserItem) -> Void) -> UserView) {
        self.viewModel = viewModel
        self.content = content
    }
}

extension UserListView: View {
    public var body: some View {
        container()
            .onAppear { viewModel.sync() }
            .onDisappear {  viewModel.unsync() }
    }
    
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            if viewModel.diaplayed.isEmpty {
                VStack {
                    ProgressView().padding(.top)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.diaplayed) { item in
                        ZStack {
                            content(item, viewModel.selected.contains(item), { user in
                                viewModel.handleOnSelect(user)
                            })
                            Separator(isLastRow: viewModel.diaplayed.last?.id == item.id)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search").autocorrectionDisabled(true)
        .onChange(of: isSearching, perform: { newValue in
            if newValue == false {
                viewModel.searchText = ""
            }
        })
    }
}

import QuickBloxData
//public struct UsersViewBuilder {
//    @ViewBuilder
//    public static func defaultListView(_ users: [User],
//                                       onSelect: @escaping (String) -> Void,
//                                       onAppearItem: @escaping (String) -> Void,
//                                       onNext: @escaping () -> Void) -> UserListView<User, some View> {
//
//        UserListView(items: users,
//                     content: { item, isSelected, onSelect in
//            UserRow(item, isSelected: isSelected, onTap: onSelect)
//        },
//                     onSelect: onSelect,
//                     onAppearItem: onAppearItem,
//                     onNext: onNext)
//    }
//}
