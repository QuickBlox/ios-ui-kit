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
    
    @Environment(\.dismiss) var dismiss
    
    let connectStatus = QuickBloxUIKit.settings.dialogsScreen.connectStatus
    
    @StateObject private var dialogsList: ViewModel
    
    public init(dialogsList: ViewModel,
                onBack: @escaping () -> Void,
                onSelect: @escaping (_ tabIndex: TabIndex) -> Void) {
        _dialogsList = StateObject(wrappedValue: dialogsList)
        self.onBack = onBack
        self.onSelect = onSelect
    }
    
    private var onBack: () -> Void
    public var onSelect: (_ tabIndex: TabIndex) -> Void
    
    @State private var isDialogTypePresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    @State private var dialogForDeleting: ViewModel.Item? = nil
    
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    
    @State public var isPresentedItem: Bool = false
    @State private var selectedSegment: TabIndex = .dialogs
    
    @State private var tabBarVisibility: Visibility = .visible
    
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
        if isDialogTypePresented == true {
            DialogTypeView(onClose: {
                // action onDismiss
                isDialogTypePresented = false
            })
        } else if feature.toolbar.enable {
            TabView(selection: $selectedSegment) {
                if (isIPad == true || isMac == true) {
                    Spacer()
                }
                dialogsContentView().blur(radius: isDialogTypePresented ? settings.blurRadius : 0)
                    .toolbarBackground(settings.backgroundColor, for: .tabBar)
                    .toolbarBackground(tabBarVisibility, for: .tabBar)
                    .tabItem {
                        Label(TabIndex.dialogs.title, systemImage: TabIndex.dialogs.systemIcon)
                    }
                    .tag(TabIndex.dialogs)
                
                ForEach(feature.toolbar.externalIndexes, id:\.self) { tabIndex in
                    settings.backgroundColor.ignoresSafeArea()
                        .toolbarBackground(settings.backgroundColor, for: .tabBar)
                        .toolbarBackground(tabBarVisibility, for: .tabBar)
                        .tabItem {
                            Label(tabIndex.title, systemImage: tabIndex.systemIcon)
                        }
                        .tag(tabIndex)
                }
            }
            .onChange(of: selectedSegment, perform: { newSelectedSegment in
                onSelect(newSelectedSegment)
            })
            .accentColor(settings.header.rightButton.color)
        } else {
            dialogsContentView().blur(radius: isDialogTypePresented ? settings.blurRadius : 0)
        }
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
                    .onChange(of: dialogsList.selectedItem, perform: { newSelectedItem in
                        isDialogTypePresented = false
                        isPresentedItem = newSelectedItem != nil
                    })
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
                    .modifier(DialogListHeader(onDismiss: {
                        onBack()
                        dismiss()
                    }, onTapDialogType: {
                        isDialogTypePresented = true
                    }))
                    .navigationBarHidden(isDialogTypePresented)
            }
            .accentColor(settings.header.leftButton.color)
        }
        else {
            NavigationSplitView(columnVisibility: Binding.constant(.all)) {
                container()
                    .onChange(of: dialogsList.selectedItem, perform: { newSelectedItem in
                        isDialogTypePresented = false
                        isPresentedItem = newSelectedItem != nil
                    })
                    .modifier(DialogListHeader(onDismiss: {
                        onBack()
                        dismiss()
                    }, onTapDialogType: {
                        isDialogTypePresented = true
                    }))
                    .navigationBarHidden(isDialogTypePresented)
            } detail: {
                if let dialog = dialogsList.selectedItem as? Dialog {
                    switch dialog.type {
                    case .group:
                        GroupDialogView(viewModel: DialogViewModel(dialog: dialog))
                    case .private:
                        PrivateDialogView(viewModel: DialogViewModel(dialog: dialog))
                    default:
                        EmptyView()
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
