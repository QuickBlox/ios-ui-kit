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

public struct DialogsListView<DialogsList: DialogsListProtocol, DialogItemView: View, DetailView: View> {
    @Environment(\.isSearching) private var isSearching: Bool
    @Environment(\.dismiss) var dismiss
    
    let settings = QuickBloxUIKit.settings.dialogsScreen
    let connectStatus = QuickBloxUIKit.settings.dialogsScreen.connectStatus
    
    @ObservedObject public var dialogsList: DialogsList
    
    private var content: (DialogsList.Item) -> DialogItemView
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    @State private var isDeleteAlertPresented: Bool = false
    @State private var dialogForDeleting: DialogsList.Item? = nil
    
    private var detailContent: (DialogsList.Item,
                                _ onDismiss: @escaping () -> Void) -> DetailView
    
    private var items: [DialogsList.Item] {
        if settings.searchBar.isSearchable == false || submittedSearchTerm.isEmpty {
            return dialogsList.dialogs
        } else {
            return dialogsList.dialogs.filter { $0.name.lowercased()
                .contains(submittedSearchTerm.lowercased()) }
        }
    }
    
    public init(dialogsList: DialogsList,
                @ViewBuilder detailContent: @escaping (_ dialog: DialogsList.Item,
                                                       _ onDismiss: @escaping () -> Void) -> DetailView,
                @ViewBuilder content: @escaping (DialogsList.Item) -> DialogItemView) {
        self.dialogsList = dialogsList
        self.content = content
        self.detailContent = detailContent
    }
}

extension DialogsListView: View {
    public var body: some View {
        
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            switch dialogsList.syncState {
            case .syncing(stage: let stage, error: _):
                VStack {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text(" " + connectStatus.connectionText(stage.rawValue) )
                            .foregroundColor(settings.dialogRow.lastMessage.foregroundColor)
                    }.padding(.top)
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
        .deleteDialogAlert(isPresented: $isDeleteAlertPresented,
                           name: dialogForDeleting?.name ?? "",
                           onCancel: {
            dialogForDeleting = nil
        }, onTap: {
            dialogsList.dialogToBeDeleted = dialogForDeleting
            if let dialogId = dialogsList.dialogToBeDeleted?.id {
                dialogsList.deleteDialog(withID: dialogId)
            }
            dialogForDeleting = nil
        })
        
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
            .navigationDestination(isPresented: Binding.constant(dialogsList.selectedItem != nil) ) {
            if let dialog = dialogsList.selectedItem {
                detailContent(dialog, {
                    dialogsList.selectedItem = nil
                })
            }
        }
    }
    
    @ViewBuilder
    private func dialogsView() -> some View {
        if items.isEmpty,
           dialogsList.syncState == .synced,
           dialogsList.dialogToBeDeleted == nil {
            EmptyDialogsView()
        } else {
            List {
                ForEach(items) { item in
                    Button {
                        dialogsList.selectedItem = item
                    } label: {
                        content(item)
                            .if(item.type != .public && dialogsList.dialogToBeDeleted == nil, transform: { view in
                                view.swipeActions(edge: .trailing) {
                                    Button(role: .destructive, action: {
                                        dialogForDeleting = item
                                        
                                        isDeleteAlertPresented = true
                                    } ) {
                                        settings.dialogRow.leaveImage
                                    }
                                }
                            })
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                        return items.last?.id == item.id ? viewDimensions[.leading]
                        : viewDimensions[.listRowSeparatorLeading]
                    }
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .deleteDisabled(dialogForDeleting != nil)
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
