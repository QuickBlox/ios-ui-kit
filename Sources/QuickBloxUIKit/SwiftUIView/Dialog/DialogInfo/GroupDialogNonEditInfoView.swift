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
    
    init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            VStack {
                
                InfoDialogAvatar(dialog: viewModel.dialog, isProcessing: $viewModel.isProcessing.value)
                
                ForEach(settings.groupActionSegments, id:\.self) { action in
                    InfoSegment(dialog: viewModel.dialog, action: action) { action in
                        switch action {
                        case .members: membersPresented.toggle()
                        case .searchInDialog: searchPresented.toggle()
                        case .leaveDialog: viewModel.deleteDialog()
                        case .notification: break
                        }
                    }
                }
                
                SegmentDivider()
            }
            
            .onChange(of: viewModel.error, perform: { error in
                if error.isEmpty { return }
                errorPresented.toggle()
            })
            
            .errorAlert($viewModel.error, isPresented: $errorPresented)
            
            .modifier(GroupDialogNonEditInfoHeader(onDismiss: {
                dismiss()
            }))
            
            NavigationLink(isActive: $membersPresented) {
                if let dialog = viewModel.dialog as? Dialog {
                    RemoveMembersView(viewModel: MembersDialogViewModel(dialog: dialog))
                }
            } label: {
                EmptyView()
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
