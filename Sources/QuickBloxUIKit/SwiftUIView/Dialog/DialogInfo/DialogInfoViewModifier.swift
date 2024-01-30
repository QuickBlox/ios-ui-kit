//
//  DialogInfoViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxLog
import UniformTypeIdentifiers
import Combine

struct DialogInfoHeaderToolbarContent: ToolbarContent {
    
    let settings = QuickBloxUIKit.settings.dialogInfoScreen.header
    let onTapEdit: () -> Void
    public init(onTapEdit: @escaping () -> Void) {
        self.onTapEdit = onTapEdit
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapEdit()
            } label: {
                if let title = settings.rightButton.title {
                    Text(title).foregroundColor(settings.rightButton.color)
                } else {
                    settings.rightButton.image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(settings.rightButton.scale)
                        .tint(settings.rightButton.color)
                        .padding(settings.rightButton.padding)
                }
            }
            .frame(width: 44, height: 44)
        }
    }
}

public struct DialogInfoHeader: ViewModifier {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen.header
    
    let onTapEdit: () -> Void
    public init(onTapEdit: @escaping () -> Void) {
        self.onTapEdit = onTapEdit
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogInfoHeaderToolbarContent(onTapEdit: onTapEdit)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(false)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

public struct InfoDialogAvatar: View {
    public var settings = QuickBloxUIKit.settings.dialogInfoScreen.avatar
    
    @EnvironmentObject var viewModel: DialogInfoViewModel
    
    public var body: some View {
        VStack(spacing: 8.0) {
            if viewModel.isProcessing == true {
                ZStack {
                    Color.gray
                        .frame(width: settings.height, height: settings.height)
                        .clipShape(Circle())
                    
                    ProgressView()
                }
            } else {
                AvatarView(image: viewModel.avatar ?? viewModel.dialog.placeholder,
                           height: settings.height,
                           isHidden: settings.isHidden)
            }
            
            Text(viewModel.dialog.validName)
                .font(settings.font)
                .foregroundColor(settings.color)
        }
        .frame(height: settings.containerHeight)
        .padding(settings.padding)
    }
}

public enum DialogInfoAction {
    case notification, members, searchInDialog, leaveDialog
}

public struct InfoSegment<Item: DialogEntity>: View {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    var dialog: Item
    let action: DialogInfoAction
    
    let onTap: (_ action: DialogInfoAction) -> Void
    
    @ViewBuilder
    public var body: some View {
        Button {
            onTap(action)
        } label: {
            HStack(spacing: settings.segmentSpacing) {
                
                switch action {
                case .notification:
                    
                    EmptyView()
                    
                case .members:
                    
                    settings.members.image.foregroundColor(settings.members.imageColor)
                    Text(settings.members.title).foregroundColor(settings.members.foregroundColor)
                    Spacer()
                    Text("\(dialog.participantsIds.count)")
                        .foregroundColor(settings.members.countColor)
                        .font(settings.members.countFont)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, settings.members.tralingSpacing)
                    settings.members.arrowRight
                        .foregroundColor(settings.members.arrowColor)
                        .padding(.trailing, settings.members.tralingSpacing)
                    
                case .searchInDialog:
                    
                    settings.search.image.foregroundColor(settings.search.imageColor)
                    Text(settings.search.title).foregroundColor(settings.search.foregroundColor)
                    Spacer()
                    
                case .leaveDialog:
                    settings.leave.image.foregroundColor(settings.leave.imageColor)
                    
                    Text(settings.leave.title).foregroundColor(settings.leave.foregroundColor)
                    Spacer()
                    
                }
            }
            .frame(height: settings.segmentHeight)
            .padding([.leading, .trailing], settings.segmentSpacing)
        }
    }
}

public struct EditDialogAlert<ViewModel: PermissionProtocol>: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogInfoScreen.editDialogAlert
    
    let viewModel: ViewModel
    
    @Binding var isPresented: Bool
    @Binding var dialogName: String
    @Binding var isValidDialogName: Bool
    
    let isExistingImage: Bool
    let isHiddenFiles: Bool
    
    @State var isAlertNamePresented: Bool = false
    @State var isMediaAlertPresented: Bool = false
    
    let onRemoveImage: () -> Void
    let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
    let onGetName: (_ name: String) -> Void
    let onCancelName: () -> Void
    
    let mediaPickerActions: [MediaPickerAction] = [.image, .name]
    
    public func body(content: Content) -> some View {
        ZStack {
            content.blur(radius: (isPresented || isMediaAlertPresented || isAlertNamePresented) ? settings.blurRadius : 0.0)
                .disabled(isPresented || isMediaAlertPresented || isAlertNamePresented)
            
                .if(isIphone == true, transform: { view in
                    view.confirmationDialog(settings.title, isPresented: $isPresented, actions: {
                        Button(settings.changeImage, role: .none) {
                            isMediaAlertPresented = true
                        }
                        Button(settings.changeDialogName, role: .none, action: {
                            isAlertNamePresented = true
                        })
                        Button(settings.cancel, role: .cancel) {
                            isPresented = false
                            isAlertNamePresented = false
                            isMediaAlertPresented = false
                        }
                    })
                })
            
                .if(isIPad == true && isPresented == true, transform: { view in
                    ZStack {
                        view.disabled(true)
                            .overlay(
                                VStack(spacing: 8) {
                                    VStack {
                                        ForEach(mediaPickerActions, id:\.self) { action in
                                            MediaPickerSegmentView(action: action) { action in
                                                switch action {
                                                case .image:
                                                    isMediaAlertPresented = true
                                                case .name:
                                                    isAlertNamePresented = true
                                                default: print("default")
                                                }
                                            }
                                            
                                            if mediaPickerActions.last != action {
                                                Divider()
                                            }
                                        }
                                    }
                                    .background(RoundedRectangle(cornerRadius: settings.cornerRadius).fill(settings.iPadBackgroundColor))
                                    .frame(width: settings.buttonSize.width)
                                    
                                    VStack {
                                        Button {
                                            isPresented = false
                                            isAlertNamePresented = false
                                            isMediaAlertPresented = false
                                        } label: {
                                            
                                            HStack {
                                                Text(settings.cancel).foregroundColor(settings.iPadCancelColor)
                                            }
                                            .frame(width: settings.buttonSize.width, height: settings.buttonSize.height)
                                        }
                                    }
                                    .background(RoundedRectangle(cornerRadius: settings.cornerRadius).fill(settings.iPadBackgroundColor))
                                    .frame(width: settings.buttonSize.width)
                                }
                                    .frame(width: settings.buttonSize.width)
                                    .shadow(color: settings.shadowColor.opacity(0.6), radius: settings.blurRadius)
                            )
                    }
                })
            
                .mediaAlert(isAlertPresented: $isMediaAlertPresented,
                            isExistingImage: isExistingImage,
                            isHiddenFiles: isHiddenFiles,
                            mediaTypes: [.images],
                            viewModel: viewModel,
                            onRemoveImage: {
                    onRemoveImage()
                    isPresented = false
                }, onGetAttachment: { attachmentAsset in
                    onGetAttachment(attachmentAsset)
                    isPresented = false
                })
                
                    .if(isAlertNamePresented, transform: { view in
                        view
                            .editNameAlert(isAlertNamePresented: $isAlertNamePresented,
                                           name: $dialogName,
                                           onGetName: { name in
                                onGetName(name)
                                isPresented = false
                            }, onCancel: onCancelName)
                    })
        }
    }
}

extension View {
    func editDialogAlert<ViewModel: PermissionProtocol>(
        isPresented: Binding<Bool>,
        viewModel: ViewModel,
        dialogName: Binding<String>,
        isValidDialogName: Binding<Bool>,
        isExistingImage: Bool,
        isHiddenFiles: Bool,
        onRemoveImage: @escaping () -> Void,
        onGetAttachment: @escaping (_ attachmentAsset: AttachmentAsset) -> Void,
        onGetName: @escaping (_ name: String) -> Void,
        onCancelName: @escaping () -> Void
    ) -> some View {
        self.modifier(EditDialogAlert(viewModel: viewModel,
                                      isPresented: isPresented,
                                      dialogName: dialogName,
                                      isValidDialogName: isValidDialogName,
                                      isExistingImage: isExistingImage,
                                      isHiddenFiles: isHiddenFiles,
                                      onRemoveImage: onRemoveImage,
                                      onGetAttachment: onGetAttachment,
                                      onGetName: onGetName,
                                      onCancelName: onCancelName))
    }
}

public struct EditNameAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogInfoScreen.editNameAlert
    let regex = QuickBloxUIKit.feature.regex
    
    @Binding var isAlertNamePresented: Bool
    @Binding var name: String
    @State var isValidDialogName: Bool = true
    
    let onGetName: (_ name: String) -> Void
    let onCancel: () -> Void
    
    init(isAlertNamePresented: Binding<Bool>, name: Binding<String>, onGetName: @escaping (_: String) -> Void, onCancel: @escaping () -> Void) {
        _isAlertNamePresented = isAlertNamePresented
        _name = name
        self.isValidDialogName = regex.dialogName.isEmpty ? true : name.wrappedValue.isValid(regexes: [regex.dialogName])
        self.onGetName = onGetName
        self.onCancel = onCancel
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content.blur(radius: isAlertNamePresented ? settings.blurRadius : 0.0)
                .alert(settings.title, isPresented: $isAlertNamePresented) {
                    TextField(settings.textfieldPrompt, text: $name)
                        .onChange(of: name) { newValue in
                            isValidDialogName = regex.dialogName.isEmpty ? true : newValue.isValid(regexes: [regex.dialogName])
                        }
                    Button(settings.cancel, action: {
                        isAlertNamePresented = false
                        onCancel()
                    })
                    Button(settings.ok, action: {
                        isAlertNamePresented = false
                        onGetName(name)
                    }).disabled(isValidDialogName == false)
                } message: {
                    Text(settings.hint)
                }
        }
    }
}

extension View {
    func editNameAlert(
        isAlertNamePresented: Binding<Bool>,
        name: Binding<String>,
        onGetName: @escaping (_ name: String) -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(EditNameAlert(isAlertNamePresented: isAlertNamePresented,
                                    name: name,
                                    onGetName: onGetName,
                                    onCancel: onCancel))
    }
}

extension Binding {
    func didSet(_ didSet: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                didSet(newValue)
            }
        )
    }
}
