//
//  NewDialog.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 29.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import PhotosUI
import QuickBloxData

struct NewDialog<ViewModel: NewDialogProtocol>: View {
    @Environment(\.dismiss) var dismiss
    
    private var settings = QuickBloxUIKit.settings.dialogNameScreen
    
    @StateObject public var viewModel: ViewModel
    
    private var type: DialogType
    
    @State private var isAlertPresented: Bool = false
    @State private var presentCreateDialog: Bool = false
    
    init(_ viewModel: ViewModel,
         type: DialogType) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.type = type
    }
    
    public var body: some View {
        container()
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            VStack {
                HStack(spacing: settings.spacing) {
                    DialogPhoto(selectedImage: $viewModel.selectedImage) {
                        isAlertPresented = true
                    }
                    
                    DialogNameTextField(dialogName: $viewModel.dialogName, isValidDialogName: viewModel.isValidDialogName)
                }.padding([.leading, .trailing])
                
                Spacer()
            }
            .padding(.top)
            
            .mediaAlert(isAlertPresented: $isAlertPresented,
                        isExistingImage: viewModel.isExistingImage,
                        isHiddenFiles: settings.isHiddenFiles,
                        mediaTypes: [UTType.image.identifier],
                        viewModel: viewModel,
                        onRemoveImage: {
                viewModel.removeExistingImage()
            }, onGetAttachment: { attachmentAsset in
                guard let avatar = attachmentAsset.image?
                    .cropToRect()
                    .resize(to: settings.avatarSize)
                     else { return }
                var asset = attachmentAsset
                asset.image = avatar
                
                viewModel.handleOnSelect(attachmentAsset: asset)
            })
            .permissionAlert(isPresented: $viewModel.permissionNotGranted.notGranted,
                             viewModel: viewModel)
            
            .modifier(DialogNameHeader(type: type, disabled: !viewModel.isValidDialogName, onDismiss: {
                dismiss()
            }, onNext: {
                presentCreateDialog.toggle()
                if type == .public {
                    //TODO: createPublicDialog method
                    viewModel.createPublicDialog()
                } else if type == .group {
                    viewModel.createDialogModel()
                }
            }))
            
            .disabled(viewModel.isProcessing == true)
            .if(viewModel.isProcessing == true) { view in
                view.overlay() {
                    CustomProgressView()
                }
            }
            
            if let modelDialog = viewModel.modelDialog {
                NavigationLink (
                    tag: modelDialog,
                    selection: $viewModel.modelDialog
                ) {
                    CreateDialogView(viewModel: CreateDialogViewModel(users: [], modeldDialog: Dialog(type: modelDialog.type,
                                                                                       name: modelDialog.name,
                                                                                       photo: modelDialog.photo)),
                                 content: {
                        viewModel in
                        
                        UserListView(viewModel: viewModel,
                                     content: { item, isSelected, onTap in
                            UserRow(item, isSelected: isSelected, onTap: onTap)
                        })})
                } label: {
                    EmptyView()
                }
            }
        }
    }
}

public struct DialogPhoto: View {
    public var settings = QuickBloxUIKit.settings.dialogNameScreen
    
    @Binding var selectedImage: Image?
    let onTap: () -> Void
    
    public init(selectedImage: Binding<Image?>, onTap: @escaping () -> Void) {
        _selectedImage = selectedImage
        self.onTap = onTap
    }
    
    public var body: some View {
        VStack {
            ZStack {
                (selectedImage ?? settings.avatarCamera)
                    .avatarModifier(height: settings.height)
                    .onTapGesture {
                        onTap()
                    }
            }
            Spacer()
        }
    }
}

public struct DialogNameTextField: View {
    public var settings = QuickBloxUIKit.settings.dialogNameScreen
    
    @Binding var dialogName: String
    var isValidDialogName: Bool
    @State private var isFocused: Bool = false
    
    public var body: some View {
        VStack(spacing: settings.spacing / 2) {
            TextField(settings.textfieldPrompt, text: $dialogName, onEditingChanged: { (changed) in
                isFocused = changed
            }).padding(.top)
            
            Divider()
                .frame(height: 1)
                .background(settings.dividerColor.opacity(settings.header.opacity))
            
            TextFieldHint(hint: (isValidDialogName || isFocused == false) ? "" : settings.hint)
            
            Spacer()
        }
    }
    
    private struct TextFieldHint: View {
        let hint: String
        var body: some View {
            return Text(hint)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

//struct NewDialog_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            NewDialog(type: .group)
//                .previewDisplayName("Default Light New Public Dialog View")
//            
//            NewDialog(type: .group)
//                .preferredColorScheme(.dark)
//                .previewDisplayName("Default Dark New Group Dialog View")
//        }
//    }
//}
