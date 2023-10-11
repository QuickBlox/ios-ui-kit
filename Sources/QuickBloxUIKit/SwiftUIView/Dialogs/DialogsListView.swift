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
    
    @StateObject public var dialogsList: DialogsList
    
    private var content: (DialogsList.Item) -> DialogItemView
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    @State private var onAppear: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    @State private var dialogForDeleting: DialogsList.Item? = nil
    
    private var detailContent: (DialogsList.Item,
                                _ onDismiss: @escaping () -> Void) -> DetailView
    
    private var items: [DialogsList.Item] {
        var dialogs: [DialogsList.Item] = []
        if onAppear == true {
            return dialogs
        }
        if settings.searchBar.isSearchable == false || submittedSearchTerm.isEmpty {
            dialogs = dialogsList.dialogs
        } else {
            dialogs = dialogsList.dialogs.filter { $0.name.lowercased()
                .contains(submittedSearchTerm.lowercased()) }
        }
        return dialogs
    }
    
    public init(dialogsList: DialogsList,
                @ViewBuilder detailContent: @escaping (_ dialog: DialogsList.Item,
                                                       _ onDismiss: @escaping () -> Void) -> DetailView,
                @ViewBuilder content: @escaping (DialogsList.Item) -> DialogItemView) {
        _dialogsList = StateObject(wrappedValue: dialogsList)
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
            .animation(.easeInOut(duration: 2), value: 1)
        })
            
            .onChange(of: dialogsList.selectedItem, perform: { newValue in
                if newValue == nil {
                    updateIfNeeded()
                }
            })
            
            if let dialog = dialogsList.selectedItem, isIphone {
                NavigationLink (
                    tag: dialog,
                    selection: $dialogsList.selectedItem
                ) {
                    detailContent(dialog, {
                        updateIfNeeded()
                        dialogsList.selectedItem = nil
                    })
                } label: {
                    EmptyView()
                }
        }
    }
    
    @ViewBuilder
    private func dialogsView() -> some View {
        if items.isEmpty,
           dialogsList.syncState == .synced,
           onAppear == false,
           dialogsList.dialogToBeDeleted == nil {
            EmptyDialogsView()
        } else {
            List {
                ForEach(items) { item in
                    Button {
                        dialogsList.selectedItem = item
                    } label: {
                        
                        ZStack {
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
                                    Separator(isLastRow: items.last?.id == item.id)
                        }
                    }
                }
                .if(dialogsList.dialogToBeDeleted == nil, transform: { view in
                    view.onDelete { _ in }
                })
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .deleteDisabled(dialogForDeleting != nil)
        }
    }
    
    private func updateIfNeeded() {
        if dialogsList.needUpdate == true {
            onAppear = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onAppear = false
                dialogsList.needUpdate = false
            }
        }
    }
}

struct CustomProgressView: View {
    var body: some View {
        ZStack {
            Color.black.frame(width: 100, height: 100)
                .cornerRadius(12)
                .opacity(0.6)
            ProgressView().controlSize(.large).tint(Color.white)
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

struct EmptyDialogsView: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen
    
    var body: some View {
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
    }
}

struct ListNavigationLink<Destination, Label>: View where Destination: View,  Label: View {
    @ViewBuilder var destination: () -> Destination
    @ViewBuilder var label: () -> Label
    
    var body: some View {
        label()
            .background(
                NavigationLink(destination: destination, label: {})
                    .opacity(0)
            )
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



