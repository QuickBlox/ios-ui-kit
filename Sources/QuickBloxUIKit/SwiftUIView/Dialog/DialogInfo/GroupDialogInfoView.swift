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
    @State private var isSizeAlertPresented: Bool = false
    @State private var membersPresented: Bool = false
    @State private var searchPresented: Bool = false
    @State private var errorPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    
    @State private var attachmentAsset: AttachmentAsset? = nil
    
    init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
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
            
            .deleteDialogAlert(isPresented: $isDeleteAlertPresented,
                               name: viewModel.dialog.name,
                               onCancel: {
                isDeleteAlertPresented = false
            }, onTap: {
                viewModel.deleteDialog()
            })
            
            .editDialogAlert(isPresented: $isEditDialogAlertPresented, viewModel: viewModel,
                             dialogName: $viewModel.dialogName,
                             isValidDialogName: $viewModel.isValidDialogName,
                             isExistingImage: viewModel.isExistingImage,
                             isHiddenFiles: settings.editDialogAlert.isHiddenFiles,
                             onRemoveImage: {
                viewModel.removeExistingImage()
            }, onGetAttachment: { attachmentAsset in
                let sizeMB = attachmentAsset.size
                if sizeMB.truncate(to: 2) > settings.maximumMB {
                    if attachmentAsset.image != nil {
                        self.attachmentAsset = attachmentAsset
                    }
                    isSizeAlertPresented = true
                } else {
                    viewModel.handleOnSelect(attachmentAsset: attachmentAsset)
                }
            }, onGetName: { name in
                viewModel.handleOnSelect(newName: name)
            })
            
            .onChange(of: viewModel.error, perform: { error in
                if error.isEmpty { return }
                errorPresented.toggle()
            })
            
            .largeImageSizeAlert(isPresented: $isSizeAlertPresented,
                                 onUseAttachment: {
                if let attachmentAsset {
                    viewModel.handleOnSelect(attachmentAsset: attachmentAsset)
                    self.attachmentAsset = nil
                }
            }, onCancel: {
                self.attachmentAsset = nil
            })
            
            .errorAlert($viewModel.error, isPresented: $errorPresented)
            .permissionAlert(isPresented: $viewModel.permissionNotGranted.notGranted,
                             viewModel: viewModel)
            
            .modifier(DialogInfoHeader(onDismiss: {
                dismiss()
            }, onTapEdit: {
                isEditDialogAlertPresented = true
            }))
            
            .disabled(viewModel.isProcessing == true)
            .if(viewModel.isProcessing == true) { view in
                view.overlay() {
                    CustomProgressView()
                }
            }
            
            .environmentObject(viewModel)
            
            .navigationDestination(isPresented: $membersPresented) {
                if membersPresented == true {
                    Fabric.screen.members(to: viewModel.dialog)
                }
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
