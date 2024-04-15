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
import Combine

struct NewDialog<ViewModel: NewDialogProtocol>: View {
    
    private var settings = QuickBloxUIKit.settings.dialogNameScreen
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: ViewModel

    private var type: DialogType
    
    @State private var isAlertPresented: Bool = false
    @State private var isCreatedDialog: Bool = false
    @State private var isSizeAlertPresented: Bool = false
    
    @State private var dialogName: String = ""
    
    @State private var attachmentAsset: AttachmentAsset? = nil
    
    init(_ viewModel: ViewModel,
         type: DialogType) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.type = type
    }
    
    public var body: some View {
        if isIphone {
            container()
        } else if isIPad {
            NavigationStack {
                container()
            }.accentColor(settings.header.leftButton.color)
        }
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
                    
                    DialogNameTextField(dialogName: $dialogName,
                                        isValidDialogName: viewModel.isValidDialogName,
                                        isFocused: isCreatedDialog)
                        .onChange(of: dialogName, perform: { newValue in
                            viewModel.update(newValue)
                        })
                }.padding([.leading, .trailing])
                
                Spacer()
            }
            .padding(.top)
            .mediaAlert(isAlertPresented: $isAlertPresented,
                        isExistingImage: viewModel.isExistingImage,
                        isHiddenFiles: settings.isHiddenFiles,
                        mediaTypes: [.images],
                        viewModel: viewModel,
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
            
            .permissionAlert(isPresented: $viewModel.permissionNotGranted.notGranted,
                             viewModel: viewModel)
            
            .onChange(of: viewModel.modelDialog, perform: { newModelDialog in
                if newModelDialog != nil {
                    isCreatedDialog = true
                }
            })
            
            .if(isCreatedDialog == true) { view in
                view.navigationDestination(isPresented: $isCreatedDialog) {
                    if let modelDialog = viewModel.modelDialog {
                        CreateDialogView(viewModel: CreateDialogViewModel(modeldDialog: Dialog(type: modelDialog.type,
                                                                                               name: modelDialog.name,
                                                                                               photo: modelDialog.photo)))
                        .onAppear {
                            isCreatedDialog = false
                        }
                    }
                }
            }

            .modifier(DialogNameHeader(type: type, disabled: !viewModel.isValidDialogName,
                                       onDismiss: {
                    dismiss()
                }, onNext: {
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
    @State var isFocused: Bool = false
    
    public var body: some View {
        VStack(spacing: settings.spacing / 2) {
            TextField(settings.textfieldPrompt, text: $dialogName, onEditingChanged: { (changed) in
                isFocused = changed
            })
            .padding(.top)
            
            Divider()
                .background(settings.hint.color)
            
            Text(settings.hint.text)
                .font(settings.hint.font)
                .foregroundColor(settings.hint.color)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
    }
}
