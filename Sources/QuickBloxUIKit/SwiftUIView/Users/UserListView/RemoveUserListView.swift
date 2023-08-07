//
//  RemoveUserListView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 27.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine

public struct RemoveUserListView<UserItem: UserEntity> where UserItem: Hashable {
    
    let settings = QuickBloxUIKit.settings.createDialogScreen
    
    private var items: [UserItem]
    private var isAdmin: Bool
    private var ownerId: String
    
    // Actions
    private var onSelect: (UserItem) -> Void
    private var onAppearItem: ((String) -> Void)
    private var onNext: () -> Void
    
    @State private var visibleRows: Set<String> = []
    
    public init(items: [UserItem],
                isAdmin: Bool,
                ownerId: String,
                onSelect: @escaping (UserItem) -> Void,
                onAppearItem: @escaping (String) -> Void,
                onNext: @escaping () -> Void) {
        self.items = items
        self.isAdmin = isAdmin
        self.ownerId = ownerId
        self.onSelect = onSelect
        self.onAppearItem = onAppearItem
        self.onNext = onNext
    }
}

extension RemoveUserListView: View {
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
                            RemoveUserRow(item, isAdmin: isAdmin, ownerId: ownerId, isSelected: false) { user in
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
    }
}
