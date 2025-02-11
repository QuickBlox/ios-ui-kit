//
//  SelectDialogsListView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 08.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine

public struct SelectDialogsListView {
//public struct SelectDialogsListView<ViewModel: DialogViewModelProtocol> {
    @Environment(\.isSearching) private var isSearching: Bool
    
    let settings = QuickBloxUIKit.settings.dialogsScreen
    
    @EnvironmentObject var viewModel: ForwardViewModel
    
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    
    private var items: [Dialog] {
        if settings.searchBar.isSearchable == false || submittedSearchTerm.isEmpty {
            return viewModel.displayedDialogs
        } else {
            return viewModel.displayedDialogs.filter { $0.name.lowercased()
                .contains(submittedSearchTerm.lowercased()) }
        }
    }
}

extension SelectDialogsListView: View {
    public var body: some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            if viewModel.displayedDialogs.isEmpty && viewModel.isSynced == true {
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
                    ForEach(items) { item in
                        ZStack {
                            SelectDialogRowView(item, isSelected: viewModel.selectedDialogs.contains(item.id)) { itemId in
                                viewModel.handleOnSelect(itemId)
                            }
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            return items.last?.id == item.id ? viewDimensions[.leading]
                            : viewDimensions[.listRowSeparatorLeading]
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }.listStyle(.plain)
                .if(settings.searchBar.isSearchable,
                    transform: { view in
                    view.searchable(text: $searchText,
                                    prompt: settings.searchBar.searchTextField.placeholderText)
                    .onSubmit(of: .search) {
                        submittedSearchTerm = searchText
                    }.onChange(of: searchText) { value in
                        if searchText.isEmpty && !isSearching {
                            submittedSearchTerm = ""
                        }
                    }
                    .autocorrectionDisabled(true)
                })
            }
        }
    }
}
