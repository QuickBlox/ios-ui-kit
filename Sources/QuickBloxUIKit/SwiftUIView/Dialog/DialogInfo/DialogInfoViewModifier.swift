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

struct DialogInfoHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogInfoScreen.header
    let onDismiss: () -> Void
    let onTapEdit: () -> Void
    var disabled: Bool = true
    
    public init(
        onDismiss: @escaping () -> Void,
        onTapEdit: @escaping () -> Void,
        disabled: Bool) {
            self.onDismiss = onDismiss
            self.onTapEdit = onTapEdit
            self.disabled = disabled
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onDismiss()
            } label: {
                if let title = settings.leftButton.title {
                    Text(title).foregroundColor(settings.leftButton.color)
                } else {
                    settings.leftButton.image.tint(settings.leftButton.color)
                }
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapEdit()
            } label: {
                if let title = settings.rightButton.title {
                    Text(title).foregroundColor(settings.rightButton.color.opacity(disabled == true ? settings.opacity : 1.0))
                } else {
                    settings.rightButton.image.tint(settings.rightButton.color.opacity(disabled == true ? settings.opacity : 1.0))
                }
            }.disabled(disabled)
        }
    }
}

public struct DialogInfoHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.createDialogScreen.header
    
    let onDismiss: () -> Void
    let onTapEdit: () -> Void
    var disabled: Bool = true
    
    public init(
        onDismiss: @escaping () -> Void,
        onTapEdit: @escaping () -> Void,
        disabled: Bool) {
            self.onDismiss = onDismiss
            self.onTapEdit = onTapEdit
            self.disabled = disabled
        }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogInfoHeaderToolbarContent(onDismiss: onDismiss,
                                           onTapEdit: onTapEdit,
                                           disabled: disabled)
        }
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func dialogInfoHeader(onDismiss: @escaping () -> Void,
                          onTapEdit: @escaping () -> Void,
                          disabled: Bool) -> some View {
        self.modifier(DialogInfoHeader(onDismiss: onDismiss,
                                       onTapEdit: onTapEdit,
                                       disabled: disabled))
    }
}

public struct InfoDialogAvatar<Item: DialogEntity>: View {
    public var settings = QuickBloxUIKit.settings.dialogInfoScreen.avatar
    
    var dialog: Item
    @Binding var selectedImage: Image?
    @Binding var selectedName: String
    let placeholder = QuickBloxUIKit.settings.dialogsScreen.dialogRow.avatar.groupAvatar
    
    @State public var avatar: Image? = nil
    
    public init(dialog: Item, selectedImage: Binding<Image?>, selectedName: Binding<String>) {
        self.dialog = dialog
        _selectedImage = selectedImage
        _selectedName = selectedName
    }
    
    public var body: some View {
        VStack(spacing: 8.0) {
            if let selectedImage {
                AvatarView(image: (selectedImage),
                           height: settings.height,
                           isShow: settings.isShow)
            } else {
                if dialog.photo.isEmpty == false {
                    AvatarView(image: (avatar ?? placeholder),
                               height: settings.height,
                               isShow: settings.isShow)
                    .task {
                        if dialog.photo.isEmpty == false {
                            do { avatar = try await dialog.avatar } catch { prettyLog(error) }
                        }
                    }
                } else {
                    AvatarView(image: (placeholder),
                               height: settings.height,
                               isShow: settings.isShow)
                }
            }
            
            if selectedName.isEmpty == false {
                Text(selectedName)
                    .font(settings.font)
                    .foregroundColor(settings.color)
            } else {
                Text(dialog.name)
                    .font(settings.font)
                    .foregroundColor(settings.color)
            }
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

public struct EditDialogAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogInfoScreen.editDialogAlert
    
    @Binding var isPresented: Bool
    @Binding var dialogName: String
    @Binding var isValidDialogName: Bool
    let isExistingImage: Bool
    
    @State var isAlertNamePresented: Bool = false
    @State var isMediaAlertPresented: Bool = false
    
    let onRemoveImage: () -> Void
    let onGetAttachment: (_ attachmentAsset: AttachmentAsset) -> Void
    let onGetName: (_ name: String) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: (isPresented || isMediaAlertPresented || isAlertNamePresented) ? settings.blurRadius : 0.0)
                .confirmationDialog(settings.title, isPresented: $isPresented, actions: {
                    Button(settings.changeImage, role: .none) {
                        isMediaAlertPresented = true
                    }
                    Button(settings.changeDialogName, role: .none, action: {
                        isAlertNamePresented = true
                    })
                    Button(settings.cancel, role: .cancel) {
                        isAlertNamePresented = false
                        isMediaAlertPresented = false
                    }
                })
                .editNameAlert(isAlertNamePresented: $isAlertNamePresented,
                               name: $dialogName,
                               isValidDialogName: $isValidDialogName,
                               onGetName: { name in
                    onGetName(name)
                })
            
                .mediaAlert(isAlertPresented: $isMediaAlertPresented,
                            isExistingImage: isExistingImage,
                            onRemoveImage: {
                    onRemoveImage()
                }, onGetAttachment: { attachmentAsset in
                    onGetAttachment(attachmentAsset)
                })
        }
    }
}

extension View {
    func editDialogAlert(
        isPresented: Binding<Bool>,
        dialogName: Binding<String>,
        isValidDialogName: Binding<Bool>,
        isExistingImage: Bool,
        onRemoveImage: @escaping () -> Void,
        onGetAttachment: @escaping (_ attachmentAsset: AttachmentAsset) -> Void,
        onGetName: @escaping  (_ name: String) -> Void
    ) -> some View {
        self.modifier(EditDialogAlert(isPresented: isPresented,
                                      dialogName: dialogName,
                                      isValidDialogName: isValidDialogName,
                                      isExistingImage: isExistingImage,
                                      onRemoveImage: onRemoveImage,
                                      onGetAttachment: onGetAttachment,
                                      onGetName: onGetName))
    }
}

public struct EditNameAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogInfoScreen.editNameAlert
    
    @State var isErrorAlertPresented: Bool = false
    @Binding var isAlertNamePresented: Bool
    @Binding var name: String
    @Binding var isValidDialogName: Bool
    
    let onGetName: (_ name: String) -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content.blur(radius: (isAlertNamePresented || isErrorAlertPresented) ? settings.blurRadius : 0.0)
                .alert(settings.title, isPresented: $isAlertNamePresented) {
                    TextField(settings.textfieldPrompt, text: $name)
                    Button(settings.cancel, action: {
                        isAlertNamePresented = false
                    })
                    Button(settings.ok, action: {
                        if isValidDialogName == true {
                            isAlertNamePresented = false
                            onGetName(name)
                        } else {
                            isErrorAlertPresented = true
                        }
                    })
                } message: {
                    Text("")
                }
                .alert(settings.errorValidation, isPresented: $isErrorAlertPresented) {
                    Button(settings.cancel, action: {
                        isAlertNamePresented = false
                        isErrorAlertPresented = false
                    })
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
        isValidDialogName: Binding<Bool>,
        onGetName: @escaping  (_ name: String) -> Void
    ) -> some View {
        self.modifier(EditNameAlert(isAlertNamePresented: isAlertNamePresented,
                                    name: name,
                                    isValidDialogName: isValidDialogName,
                                    onGetName: onGetName))
    }
}
