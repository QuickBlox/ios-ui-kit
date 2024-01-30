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

public struct DialogsView<ViewModel: DialogsListProtocol,
                          DetailView: View,
                          TypeView: View>: View {
    
    let settings = QuickBloxUIKit.settings.dialogsScreen
    let feature = QuickBloxUIKit.feature
    
    @Environment(\.keyboardShowing) var keyboardShowing
    @Environment(\.dismiss) var dismiss
    @Environment(\.isSearching) var isSearching
    
    let connectStatus = QuickBloxUIKit.settings.dialogsScreen.connectStatus

    @StateObject public var dialogsList: ViewModel
    
    public init(dialogsList: ViewModel,
                @ViewBuilder detailContent: @escaping (_ dialog: ViewModel.Item,
                                                       _ isInfoPresented: Binding<Bool>) -> DetailView,
                selectTypeContent: @escaping (@escaping() -> Void) -> TypeView,
                onBack: @escaping () -> Void,
                onSelect: @escaping (_ tabIndex: TabIndex) -> Void) {
        _dialogsList = StateObject(wrappedValue: dialogsList)
        self.detailContent = detailContent
        self.selectTypeContent = selectTypeContent
        self.onBack = onBack
        self.onSelect = onSelect
    }

    private var detailContent: (ViewModel.Item,
                                _ isInfoPresented: Binding<Bool>) -> DetailView
    private var selectTypeContent: (@escaping () -> Void) -> TypeView
    private var onBack: () -> Void
    public var onSelect: (_ tabIndex: TabIndex) -> Void
    
    @State private var isDialogTypePresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    @State private var dialogForDeleting: ViewModel.Item? = nil
    @State private var isInfoPresented: Bool = false
    
    @State private var searchText = ""
    @State private var submittedSearchTerm = ""
    @State private var needDismiss: Bool = false
    
    @State public var isPresentedItem: Bool = false
    
    @State private var selectedSegment: TabIndex = .dialogs
    
    @State private var selectedItem: ViewModel.Item?
    
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
                        
                        ForEach(settings.tabIndex.externalIndexes, id:\.self) { tabIndex in
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
                selectTypeContent({
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
        
        .onChange(of: selectedSegment, perform: { newValue in
            if newValue != .dialogs {
                onSelect(newValue)
            }
        })
        
        .onChange(of: dialogsList.selectedItem, perform: { newValue in
            if let newValueId = newValue?.id,
               let selectedItemId = selectedItem?.id,
               newValueId == selectedItemId {
                return
            }
            selectedItem = newValue
            isDialogTypePresented = false
        })
        
        .onChange(of: selectedItem, perform: { newValue in
            if newValue != nil {
                isDialogTypePresented = false
            }
            
            isPresentedItem = newValue != nil
            
            if let newValueId = newValue?.id,
               let selectedItemId = dialogsList.selectedItem?.id,
               newValueId == selectedItemId {
                return
            }
            dialogsList.selectedItem = newValue
        })
        
        .if(isIphone == true, transform: { view in
            view.navigationDestination(isPresented: $isPresentedItem) {
                if let dialog = dialogsList.selectedItem {
                detailContent(dialog, $isInfoPresented).onAppear {
                    isDialogTypePresented = false
                }
                .onDisappear {
                    if isInfoPresented == false {
                        dialogsList.selectedItem = nil
                    }
                }
            }
        }
    })
        
        .modifier(DialogListViewModifier(onDismiss: {
            onBack()
            dismiss()
        }, onTapDialogType: {
            isDialogTypePresented = true
        }))
        
        .navigationBarHidden(isDialogTypePresented)
        
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
            List(items, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    GroupDialogRowView(item)
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

                    }.foregroundColor(Color.clear)
                
                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                    return items.last?.id == item.id ? viewDimensions[.leading]
                    : viewDimensions[.listRowSeparatorLeading]
                }
                .listRowBackground(settings.backgroundColor)
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.plain)
            .deleteDisabled(dialogForDeleting != nil)
        }
    }
    
    public var body: some View {
        if isIphone {
            NavigationStack {
                container()
            }.accentColor(settings.header.leftButton.color)
        } else if isIPad {
            NavigationSplitView(columnVisibility: Binding.constant(.all)) {
                container()
            } detail: {
                if let dialog = selectedItem {
                    detailContent(dialog, $isPresentedItem).id(dialog.id)
                        .onAppear {
                            isDialogTypePresented = false
                        }
                        .onDisappear {
                            if isInfoPresented == false {
                                dialogsList.selectedItem = nil
                            }
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

//public struct DialogsViewViewBuilder<DialogItem: DialogEntity, UserItem: UserEntity, ListView: View, UserView: View> {
//    @MainActor @ViewBuilder
//    public static func `default`() -> some View {
//        DialogsView(dialogsList: DialogsViewModel(dialogs: PreviewModel.dialogs), content: { (dialogs, onTap, onAppear, onDelete)   in
//            DialogsViewBuilder.defaultListView(dialogs, onItemTap: { item in
//
//            }, onAppearItem: { itemId in
//
//            }, onDeleteItem: { itemId in
//
//            })
//        }, detailContent: { item in
//            DialogView<Dialog, User, UserListView<User, UserRow>, UserRow, Message>(dialog: item)
//        }, selectTypeContent: { onClose in
//            DialogTypeView<DialogItem, UserItem, ListView, UserView>(onClose: onClose)
//        })
//    }
//}
//
//struct DialogsView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            DialogsViewViewBuilder<Dialog, User, UserListView<User, UserRow>, UserRow>.default()
//                .previewDisplayName("Dialogs View Light")
//            DialogsViewViewBuilder<Dialog, User, UserListView<User, UserRow>, UserRow>.default()
//                .previewDisplayName("Dialogs View Dark")
//                .preferredColorScheme(.dark)
//        }
//    }
//}
