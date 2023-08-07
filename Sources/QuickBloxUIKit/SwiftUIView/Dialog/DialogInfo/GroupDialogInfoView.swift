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
    @State private var isEdit: Bool = false
    
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
            
            .editDialogAlert(isPresented: $isEditDialogAlertPresented,
                             dialogName: $viewModel.dialogName,
                             isValidDialogName: $viewModel.isValidDialogName,
                             isExistingImage: viewModel.isExistingImage,
                             isHiddenFiles: settings.editDialogAlert.isHiddenFiles,
                             isEdit: $isEdit,
                             onRemoveImage: {
                viewModel.removeExistingImage()
            }, onGetAttachment: { attachmentAsset in
                guard let avatar = attachmentAsset.image?
                    .cropToRect()
                    .resize(to: settings.avatarSize)
                     else { return }
                var asset = attachmentAsset
                asset.image = avatar
                viewModel.handleOnSelect(attachmentAsset: attachmentAsset)
                viewModel.isProcessing.value = true
            }, onGetName: { name in
                viewModel.handleOnSelect(newName: name)
            })
            
            .onChange(of: viewModel.error, perform: { error in
                if error.isEmpty { return }
                errorPresented.toggle()
            })
            
            .errorAlert($viewModel.error, isPresented: $errorPresented)
            
            .modifier(DialogInfoHeader(onDismiss: {
                dismiss()
            }, onTapEdit: {
                isEditDialogAlertPresented = true
            }, disabled: isEdit))
            
            NavigationLink(isActive: $membersPresented) {
                Fabric.screen.members(to: viewModel.dialog)
            } label: {
                EmptyView()
            }
        }
    }
}

public struct SegmentDivider: View {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    public var body: some View {
        Divider().background(settings.dividerColor.opacity(0.3))
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
