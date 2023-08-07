//
//  DialogsListView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import Combine

public struct DialogsListView<DialogsList: DialogsListProtocol, DialogItemView: View> {
    @Environment(\.isSearching) private var isSearching: Bool
    
    let settings = QuickBloxUIKit.settings.dialogsScreen
    
    @StateObject public var dialogsList: DialogsList
    
    private var content: (DialogsList.Item) -> DialogItemView
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    
    private var items: [DialogsList.Item] {
        var dialogs: [DialogsList.Item] = []
        if settings.searchBar.isSearchable == false || submittedSearchTerm.isEmpty {
            dialogs = dialogsList.dialogs
        } else {
            dialogs = dialogsList.dialogs.filter { $0.name.lowercased()
                .contains(submittedSearchTerm.lowercased()) }
        }
        return dialogs
    }
    
    public init(dialogsList: DialogsList,
                @ViewBuilder content: @escaping (DialogsList.Item) -> DialogItemView) {
        _dialogsList = StateObject(wrappedValue: dialogsList)
        self.content = content
    }
}

extension DialogsListView: View {
    public var body: some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            switch dialogsList.syncState {
            case .syncing(stage: let stage, error: let error):
                VStack {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text(" " + stage.rawValue)
                            .foregroundColor(settings.dialogRow.lastMessage.foregroundColor)
                    }.padding(.top)
                    if let info = error?.errorDescription {
                        Text(info).font(.subheadline).padding()
                    }
                    if items.isEmpty {
                        Spacer()
                    } else {
                        dialogsView()
                    }
                }
            case .synced:
                dialogsView()
            }
        }
        .if(settings.searchBar.isSearchable &&
            dialogsList.dialogs.isEmpty == false,
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
            .animation(.easeInOut(duration: 2), value: 1)
        })
    }
    
    @ViewBuilder
    private func dialogsView() -> some View {
        if items.isEmpty && dialogsList.syncState == .synced {
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
            
        } else {
            List {
                ForEach(items) { item in
                    Button {
                        dialogsList.selectedItem = item
                    } label: {
                        ZStack {
                            content(item)
                                .if((item).type != .public , transform: { view in
                                    view.swipeActions(edge: .trailing) {
                                        Button(role: .destructive, action: {
                                            dialogsList.deleteDialog(withID: item.id)
                                        } ) {
                                            settings.dialogRow.leaveImage
                                        }
                                    }
                                })
                            Separator(isLastRow: items.last?.id == item.id)
                        }
                    }
                }
                .onDelete { _ in }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }.listStyle(.plain)
        }
    }
}


struct Separator: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    var isLastRow: Bool
    var body: some View {
        VStack {
            Spacer()
            HStack() {
                Spacer(minLength: isLastRow == false ? settings.separatorInset: 0.0)
                Rectangle()
                    .fill(settings.dividerColor.opacity(0.4))
                    .frame(height: 1.0, alignment: .trailing)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

//struct DialogsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            DialogsListView(dialogsList: DialogsListMock(dialogs: PreviewModel.dialogs),
//                            content: DialogsRowBuilder.defaultRow)
//            .previewDisplayName("Default Row")
//
//            DialogsListView(dialogsList: DialogsListMock(dialogs: PreviewModel.dialogs),
//                            content: DialogsRowBuilder.defaultRow)
//            .preferredColorScheme(.dark)
//            .previewDisplayName("Default Dark Row")
//        }
//    }
//}
