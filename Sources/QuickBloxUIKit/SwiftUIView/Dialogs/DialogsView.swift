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
    
    @Environment(\.keyboardShowing) var keyboardShowing
    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) var isSearching
    
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
        ZStack(alignment: .center) {
            settings.backgroundColor.ignoresSafeArea()
            HStack {
                if isIPad {
                    Spacer()
                }
                
                if feature.toolbar.enable {
                    TabView(selection: $selectedSegment) {
                        dialogsContentView().blur(radius: isDialogTypePresented ? settings.blurRadius : 0)
                            .toolbar(tabBarVisibility, for: .tabBar)
                            .toolbarBackground(settings.backgroundColor, for: .tabBar)
                            .toolbarBackground(tabBarVisibility, for: .tabBar)
                            .tag(TabIndex.dialogs)
                            .tabItem {
                                Label(TabIndex.dialogs.title, systemImage: TabIndex.dialogs.systemIcon)
                            }
                        
                        ForEach(feature.toolbar.externalIndexes, id:\.self) { tabIndex in
                            settings.backgroundColor.ignoresSafeArea()
                                .toolbar(tabBarVisibility, for: .tabBar)
                                .toolbarBackground(settings.backgroundColor, for: .tabBar)
                                .toolbarBackground(tabBarVisibility, for: .tabBar)
                                .tabItem {
                                    Label(tabIndex.title, systemImage: tabIndex.systemIcon)
                                }
                                .tag(tabIndex)
                        }
                    }
                    .accentColor(settings.header.rightButton.color)
                } else {
                    dialogsContentView().blur(radius: isDialogTypePresented ? settings.blurRadius : 0)
                }
            }
            
            if isDialogTypePresented == true {
                DialogTypeView(onClose: {
                    // action onDismiss
                    isDialogTypePresented = false
                })
            }
        }
        .addKeyboardVisibilityToEnvironment()
        
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
        
        .onAppear {
            selectedSegment = .dialogs
        }
        
        .onChange(of: selectedSegment, perform: { newSelectedSegment in
            if newSelectedSegment != .dialogs {
                onSelect(newSelectedSegment)
            }
        })
        
        .onChange(of: dialogsList.selectedItem, perform: { newSelectedItem in
            isDialogTypePresented = false
            isPresentedItem = newSelectedItem != nil
        })
        
        .if(dialogsList.dialogToBeDeleted != nil) { view in
            view.overlay() {
                CustomProgressView()
            }
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
                    if isIPad && dialogsList.selectedItem?.id == item.id {
                        return
                    }
                    dialogsList.selectedItem = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dialogsList.selectedItem = item
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
                    .modifier(DialogListHeader(onDismiss: {
                        onBack()
                        dismiss()
                    }, onTapDialogType: {
                        isDialogTypePresented = true
                    }))
                    .navigationBarHidden(isDialogTypePresented)
            }.accentColor(settings.header.leftButton.color)
        }
        else if isIPad {
            
            NavigationSplitView(columnVisibility: Binding.constant(.all)) {
                NavigationStack {
                    container()
                        .modifier(DialogListHeader(onDismiss: {
                            onBack()
                            dismiss()
                        }, onTapDialogType: {
                            isDialogTypePresented = true
                        }))
                        .navigationBarHidden(isDialogTypePresented)
                }
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
