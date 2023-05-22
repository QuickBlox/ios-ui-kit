//
//  GroupDialogInfoView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct GroupDialogInfoView<ViewModel: DialogInfoProtocol>: View {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var isEditDialogAlertPresented: Bool = false
    @State private var membersPresented: Bool = false
    @State private var searchPresented: Bool = false
    
    init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                settings.backgroundColor.ignoresSafeArea()
                VStack {
                    
                    InfoDialogAvatar(dialog: viewModel.dialog,
                                     selectedImage: $viewModel.selectedImage,
                                     selectedName: $viewModel.dialogName)
                    
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
                    
                    NavigationLink(isActive: $membersPresented) {
                        if let dialog = viewModel.dialog as? Dialog {
                            RemoveMembersView(viewModel: MembersDialogViewModel(dialog: dialog, type: .remove))
                        }
                    } label: {
                        EmptyView()
                    }
                }
                
                .editDialogAlert(isPresented: $isEditDialogAlertPresented,
                                 dialogName: $viewModel.dialogName,
                                 isValidDialogName: $viewModel.isValidDialogName,
                                 isExistingImage: viewModel.isExistingImage,
                                 onRemoveImage: {
                    viewModel.removeExistingImage()
                }, onGetAttachment: { attachmentAsset in
                    viewModel.handleOnSelect(attachmentAsset: attachmentAsset)
                }, onGetName: { name in
                    viewModel.handleOnSelect(newName: name)
                })
                
                .dialogInfoHeader(onDismiss: {
                    dismiss()
                }, onTapEdit: {
                    isEditDialogAlertPresented.toggle()
                }, disabled: (viewModel.dialog.type != .group
                              && viewModel.dialog.isOwnedByCurrentUser == false) || viewModel.dialog.isOwnedByCurrentUser == false)
            }
        }
    }
}

public struct SegmentDivider: View {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    public var body: some View {
        Divider()
            .frame(height: 1)
            .background(settings.dividerColor.opacity(0.4))
        Spacer()
    }
}

//struct DialogInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            GroupDialogInfoView<Dialog,
//                                User,
//                                RemoveUserListView<User>,
//                                RemoveUserRow>(DialogInfoViewModel<Dialog>(Dialog(id: "dffdfdfdfdf",
//                                                                                  type: .group,
//                                                                                  name: "Test Group Light Dialog")))
//                                .previewDisplayName("Dialog Info View")
//            GroupDialogInfoView<Dialog,
//                                User, RemoveUserListView<User>,
//                                RemoveUserRow>(DialogInfoViewModel<Dialog>(Dialog(id: "dffdfdfdfdf",
//                                                                                  type: .group,
//                                                                                  name: "Test Group Dark Dialog")))
//                                .previewDisplayName("Dialog Info View Dark")
//                                .preferredColorScheme(.dark)
//        }
//    }
//}
