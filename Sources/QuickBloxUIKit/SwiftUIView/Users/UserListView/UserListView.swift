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

public struct UserListView<ViewModel: CreateDialogProtocol,
                           UserItem: UserEntity,
                           UserView: View> where UserItem == ViewModel.UserItem {
    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject public var viewModel: ViewModel
    
    let settings = QuickBloxUIKit.settings.createDialogScreen
    
    private var content: (_ item: UserItem,
                          _ isSelected: Bool,
                          _ onSelect: @escaping (_ user: UserItem) -> Void) -> UserView
    private var onNext: () -> Void
    
    @State private var visibleRows: Set<String> = []
    
    
    
    public init(viewModel: ViewModel,
                @ViewBuilder content: @escaping (_ item: UserItem,
                                                 _ isSelected: Bool,
                                                 _ onSelect: @escaping (_ user: UserItem) -> Void) -> UserView,
                onNext: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.content = content
        self.onNext = onNext
    }
}

extension UserListView: View {
    public var body: some View {
        container()
    }
    
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            if viewModel.displayed.isEmpty && viewModel.isSynced == true {
                Spacer()
                VStack(spacing: 16.0) {
                    settings.messageImage
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(settings.messageImageColor)
                        .frame(width: 60, height: 60)
                    Text(settings.itemsIsEmpty)
                        .font(settings.itemsIsEmptyFont)
                        .foregroundColor(settings.itemsIsEmptyColor)
                    
                }
                Spacer()
            } else  if viewModel.isSynced == false {
                VStack {
                    HStack(spacing: 12) {
                        ProgressView()
                    }.padding(.top)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.displayed) { item in
                        ZStack {
                            content(item, viewModel.selected.contains(item), { user in
                                viewModel.handleOnSelect(user)
                            })
                            Separator(isLastRow: viewModel.displayed.last?.id == item.id)
                        }
                        .onAppear {
                            if viewModel.displayed.last?.id == item.id {
                                onNext()
                            }
                        }
                        .listRowBackground(settings.backgroundColor)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }
                    
                    if viewModel.isAdding {
                        VStack {
                            ProgressView()
                                .padding(.vertical, 12)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.search, prompt: "Search").autocorrectionDisabled(true)
        .onChange(of: isSearching, perform: { newValue in
            if newValue == false {
                viewModel.search = ""
            }
        })
    }
}
