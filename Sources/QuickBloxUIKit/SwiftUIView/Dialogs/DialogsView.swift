//
//  DialogsView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 30.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct DialogsView<ViewModel: DialogsListProtocol>: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen
    let feature = QuickBloxUIKit.feature
    
    let connectStatus = QuickBloxUIKit.settings.dialogsScreen.connectStatus
    
    @StateObject private var dialogsList: ViewModel
    
    var onModifyContent: ((AnyView, Binding<Bool>) -> AnyView)?
    
    public init(dialogsList: ViewModel,
                modifyContent: ((AnyView, Binding<Bool>) -> AnyView)? = nil,
                onBack: @escaping () -> Void) {
        _dialogsList = StateObject(wrappedValue: dialogsList)
        self.onModifyContent = modifyContent
        self.onBack = onBack
    }
    
    private var onBack: () -> Void
    
    @State private var isDialogTypePresented: Bool = false {
        didSet {
            isNavigationBarPresented = !isDialogTypePresented
        }
    }
    @State private var isDeleteAlertPresented: Bool = false
    @State private var dialogForDeleting: ViewModel.Item? = nil
    
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    
    @State var isNavigationBarPresented: Bool = true
    @State public var isPresentedItem: Bool = false
    
    private var items: [ViewModel.Item] {
        if settings.searchBar.isSearchable == false || submittedSearchTerm.isEmpty {
            return dialogsList.dialogs
        } else {
            return dialogsList.dialogs.filter { $0.name.lowercased()
                .contains(submittedSearchTerm.lowercased()) }
        }
    }
    
    @ViewBuilder
    private func container() -> some View {
        var defaultView: AnyView = AnyView(EmptyView())
        if isDialogTypePresented == true {
            defaultView = AnyView(DialogTypeView(onClose: {
                // action onDismiss
                isDialogTypePresented = false
            }))
        } else {
            defaultView = AnyView(dialogsContentView().blur(radius: isDialogTypePresented ? settings.blurRadius : 0))
        }
        
        if let modify = onModifyContent {
            defaultView = modify(defaultView, $isNavigationBarPresented)
        }
        
        return  defaultView
            .onChange(of: dialogsList.selectedItem, perform: { newSelectedItem in
                isDialogTypePresented = false
                isPresentedItem = newSelectedItem != nil
            })
            .modifier(DialogListHeader(onDismiss: {
                onBack()
            }, onTapDialogType: {
                isDialogTypePresented = true
            }))
            .navigationBarHidden(!isNavigationBarPresented)
    }
    
    @ViewBuilder
    private func dialogsContentView() -> some View {
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
                        dialogsListView()
                    }
                }
            case .synced:
                dialogsListView()
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
        
        .addSearchBar(
            isSearchable: settings.searchBar.isSearchable,
            searchText: $searchText,
            placeholder: settings.searchBar.searchTextField.placeholderText,
            submittedSearchTerm: $submittedSearchTerm
        )
        .if(dialogsList.dialogToBeDeleted != nil) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
    }
    
    @ViewBuilder
    private func dialogsListView() -> some View {
        if items.isEmpty,
           dialogsList.syncState == .synced,
           dialogsList.dialogToBeDeleted == nil {
            EmptyDialogsView()
        } else {
            List(items) { item in
                Button {
                    if (isIPad == true || isMac == true) && dialogsList.selectedItem?.id == item.id {
                        return
                    }
                    dialogsList.selectedItem = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dialogsList.selectedItem = item
                        isPresentedItem = true
                    }
                } label: {
                    DialogsRowBuilder.defaultRow(item)
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
                .listRowBackground(settings.backgroundColor)
                .listRowInsets(EdgeInsets())
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .deleteDisabled(dialogForDeleting != nil)
        }
    }
    
    public var body: some View {
        if isIphone {
            NavigationStack {
                container()
                    .navigationDestination(isPresented: $isPresentedItem) {
                        if let dialog = dialogsList.selectedItem as? Dialog {
                            switch dialog.type {
                            case .group:
                                GroupDialogView(viewModel: DialogViewModel(dialog: dialog))
                            case .private:
                                PrivateDialogView(viewModel: DialogViewModel(dialog: dialog))
                            default:
                                EmptyView()
                            }
                        }
                    }
            }
            .accentColor(settings.header.leftButton.color)
        }
        else {
            NavigationSplitView(columnVisibility: Binding.constant(.all)) {
                container()
            } detail: {
                if let dialog = dialogsList.selectedItem as? Dialog {
                    switch dialog.type {
                    case .group:
                        GroupDialogView(viewModel: DialogViewModel(dialog: dialog))
                    case .private:
                        PrivateDialogView(viewModel: DialogViewModel(dialog: dialog))
                    default:
                        EmptyDialogView()
                    }
                } else {
                    EmptyDialogView()
                }
            }
            .navigationSplitViewStyle(.balanced)
            .accentColor(settings.header.leftButton.color)
        }
    }
}
