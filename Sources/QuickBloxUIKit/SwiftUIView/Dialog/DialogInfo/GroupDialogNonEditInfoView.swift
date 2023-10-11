//
//  GroupDialogNonEditInfoView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct GroupDialogNonEditInfoView<ViewModel: DialogInfoProtocol>: View {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var membersPresented: Bool = false
    @State private var searchPresented: Bool = false
    @State private var errorPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    
    init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                settings.backgroundColor.ignoresSafeArea()
                VStack {
                    
                    InfoDialogAvatar()
                    
                    ForEach(settings.groupActionSegments, id:\.self) { action in
                        InfoSegment(dialog: viewModel.dialog, action: action) { action in
                            switch action {
                            case .members: membersPresented.toggle()
                            case .searchInDialog: searchPresented.toggle()
                            case .leaveDialog: isDeleteAlertPresented = true
                            case .notification: break
                            }
                        }
                    }
                    
                    SegmentDivider()
                }
                
                .onAppear {
                    viewModel.sync()
                }
                
                .onChange(of: viewModel.error, perform: { error in
                    if error.isEmpty { return }
                    errorPresented.toggle()
                })
                
                .errorAlert($viewModel.error, isPresented: $errorPresented)
                
                .deleteDialogAlert(isPresented: $isDeleteAlertPresented,
                                   name: viewModel.dialog.name,
                                   onCancel: {
                    isDeleteAlertPresented = false
                }, onTap: {
                    viewModel.deleteDialog()
                })
                
                .disabled(viewModel.isProcessing == true)
                .if(viewModel.isProcessing == true) { view in
                    view.overlay() {
                        CustomProgressView()
                    }
                }
                
                .modifier(GroupDialogNonEditInfoHeader(onDismiss: {
                    dismiss()
                }))
                
                .environmentObject(viewModel)
                
                if membersPresented == true {
                    NavigationLink(isActive: $membersPresented) {
                        Fabric.screen.members(to: viewModel.dialog)
                    } label: {
                        EmptyView()
                    }
                }
            }
        }
    }
}

//struct GroupDialogNonEditInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            GroupDialogNonEditInfoView<Dialog,
//                                User,
//                                RemoveUserListView<User>,
//                                RemoveUserRow>(DialogInfoViewModel<Dialog>(Dialog(id: "dffdfdfdfdf",
//                                                                                  type: .group,
//                                                                                  name: "Test Group Light Dialog")))
//                                .previewDisplayName("Dialog Info View")
//            GroupDialogNonEditInfoView<Dialog,
//                                User, RemoveUserListView<User>,
//                                RemoveUserRow>(DialogInfoViewModel<Dialog>(Dialog(id: "dffdfdfdfdf",
//                                                                                  type: .group,
//                                                                                  name: "Test Group Dark Dialog")))
//                                .previewDisplayName("Dialog Info View Dark")
//                                .preferredColorScheme(.dark)
//        }
//    }
//}
