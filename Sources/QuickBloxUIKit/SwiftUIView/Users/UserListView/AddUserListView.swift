//
//  AddUserListView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine

public struct AddUserListView<UserItem: UserEntity> where UserItem: Hashable {
    @Environment(\.isSearching) private var isSearching: Bool
    
    let settings = QuickBloxUIKit.settings.createDialogScreen
    
    private var items: [UserItem]
    @Binding private var searchText: String
    
    // Actions
    private var onSelect: (UserItem) -> Void
    private var onAppearItem: ((String) -> Void)
    private var onNext: () -> Void
    
    @State private var visibleRows: Set<String> = []
    
    public init(items: [UserItem],
                searchText: Binding<String> = Binding.constant(""),
                onSelect: @escaping (UserItem) -> Void,
                onAppearItem: @escaping (String) -> Void,
                onNext: @escaping () -> Void) {
        self.items = items
        self._searchText = searchText
        self.onSelect = onSelect
        self.onAppearItem = onAppearItem
        self.onNext = onNext
    }
}

extension AddUserListView: View {
    public var body: some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            if items.isEmpty {
                VStack {
                    ProgressView().padding(.top)
                    Spacer()
                }
            } else {
                List {
                    ForEach(items) { item in
                        ZStack {
                            UserRowBuilder.create(row: .add,
                                                  wiht: item,
                                                  selected: false) { user in
                                onSelect(user)
                            }
                            Separator(isLastRow: items.last?.id == item.id)
                        }
                        .onAppear {
                            if visibleRows.contains(item.id) == false {
                                self.visibleRows.insert(item.id)
                                onAppearItem(item.id)
                            }
                            
                            if items.last?.id == item.id {
                                onNext()
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }.listStyle(.plain)
            }
        }
        .searchable(text: $searchText, prompt: "Search").autocorrectionDisabled(true)
        .onChange(of: isSearching, perform: { newValue in
            if newValue == false {
                searchText = ""
            }
        })
    }
}
