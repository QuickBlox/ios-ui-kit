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
                          ListView: View,
                          DetailView: View,
                          TypeView: View>: View {
    
    let settings = QuickBloxUIKit.settings.dialogsScreen
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var dialogsList: ViewModel
    
    public init(dialogsList: ViewModel,
                @ViewBuilder content: @escaping (_ viewModel: ViewModel) -> ListView,
                @ViewBuilder detailContent: @escaping (_ dialog: ViewModel.Item,
                                                       _ onDismiss: @escaping () -> Void) -> DetailView,
                selectTypeContent: @escaping (@escaping() -> Void) -> TypeView,
                onBack: @escaping () -> Void,
                onAppear: @escaping (Bool) -> Void) {
        _dialogsList = StateObject(wrappedValue: dialogsList)
        self.content = content
        self.detailContent = detailContent
        self.selectTypeContent = selectTypeContent
        self.onBack = onBack
        self.onAppear = onAppear
    }
    
    private var content: (_ viewModel: ViewModel) -> ListView
    private var detailContent: (ViewModel.Item,
                                _ onDismiss: @escaping () -> Void) -> DetailView
    private var selectTypeContent: (@escaping () -> Void) -> TypeView
    private var onBack: () -> Void
    private var onAppear: (Bool) -> Void
    
    @State private var isDialogTypePresented: Bool = false
    
    @ViewBuilder
    private func container() -> some View {
        ZStack(alignment: .center) {
            settings.backgroundColor.ignoresSafeArea()
            content(dialogsList).blur(radius: isDialogTypePresented ? settings.blurRadius : 0)
            
            if isDialogTypePresented {
                selectTypeContent({
                    // action onDismiss
                    isDialogTypePresented.toggle()
                    onAppear(true)
                })
            }
        }
        
        .onChange(of: dialogsList.selectedItem, perform: { newValue in
            if newValue != nil {
                isDialogTypePresented = false
                onAppear(false)
            } else {
                onAppear(true)
            }
        })
        
        .navigationBar(titleColor: UIColor(settings.header.title.color),
                       barColor: UIColor(settings.header.backgroundColor),
                       shadowColor: UIColor(settings.dialogRow.dividerColor))
        
        .modifier(DialogListHeader(onDismiss: {
            onBack()
            dismiss()
        }, onTapDialogType: {
            isDialogTypePresented.toggle()
            onAppear(false)
        }))
        .navigationBarHidden(isDialogTypePresented)
        .onAppear {
            dialogsList.sync()
        }
        .onDisappear {
            dialogsList.unsync()
        }
        .disabled(dialogsList.dialogToBeDeleted != nil)
        .if(dialogsList.dialogToBeDeleted != nil) { view in
            view.overlay() {
                CustomProgressView()
            }
        }
    }
    
    public var body: some View {
        if #available(iOS 16, *) {
            if isIphone {
                NavigationView {
                    container()
                }.navigationViewStyle(.stack)
            } else if isIPad {
                NavigationSplitView(columnVisibility: Binding.constant(.all)) {
                    container()
                } detail: {
                    if let dialog = dialogsList.selectedItem {
                        detailContent(dialog, {
                            dialogsList.selectedItem = nil
                        })
                    }
                }.navigationSplitViewStyle(.balanced)
            }
        } else {
            NavigationView {
                container()
            }
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
