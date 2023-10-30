//
//  DialogListHeader.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct DialogListHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogsScreen.header
    
    let onDismiss: () -> Void
    let onTapDialogType: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void,
        onTapDialogType: @escaping () -> Void) {
            self.onDismiss = onDismiss
            self.onTapDialogType = onTapDialogType
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if settings.leftButton.hidden == false {
                Button {
                    onDismiss()
                } label: {
                    if let title = settings.leftButton.title {
                        Text(title).foregroundColor(settings.leftButton.color)
                    } else {
                        settings.leftButton.image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(settings.leftButton.scale)
                            .tint(settings.leftButton.color)
                            .padding(settings.leftButton.padding)
                    }
                }.frame(width: 32, height: 44)
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapDialogType()
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
            }.frame(width: 44, height: 44)
        }
    }
}

public struct DialogListHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.dialogsScreen.header
    
    let onDismiss: () -> Void
    let onTapDialogType: () -> Void
    
    public init(onDismiss: @escaping () -> Void,
                onTapDialogType: @escaping () -> Void
    ) {
        self.onDismiss = onDismiss
        self.onTapDialogType = onTapDialogType
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogListHeaderToolbarContent(onDismiss: onDismiss,
                                           onTapDialogType: onTapDialogType)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
    }
}

public extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

public var isIphone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}

public var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

public struct DeleteDialogAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.membersScreen.removeUser
    
    @Binding var isPresented: Bool
    var name: String
    let onCancel: () -> Void
    let onTap: () -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .alert(settings.alertTitle(name), isPresented: $isPresented) {
                    Button(settings.cancel, role: .cancel, action: {
                        onCancel()
                        isPresented = false
                    })
                    Button("Delete", role: .destructive, action: {
                        onTap()
                        isPresented = false
                    })
                } message: {
                    Text( "Are you sure you want to delete that dialog?")
                }
        }
    }
}

extension View {
    func deleteDialogAlert(
        isPresented: Binding<Bool>,
        name: String,
        onCancel: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) -> some View {
        self.modifier(RemoveUserAlert(isPresented: isPresented,
                                      name: name,
                                      onCancel: onCancel,
                                      onTap: onTap))
    }
}

struct CustomProgressView: View {
    var body: some View {
        ZStack {
            Color.black.frame(width: 100, height: 100)
                .cornerRadius(12)
                .opacity(0.6)
            ProgressView().controlSize(.large).tint(Color.white)
        }
    }
}

struct Separator: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    var isLastRow: Bool
    var body: some View {
        VStack {
            Spacer()
            HStack() {
                Spacer(minLength: isLastRow == false ? settings.separatorInset: 0.0)
                Rectangle()
                    .fill(settings.dividerColor.opacity(0.4))
                    .frame(height: 1.0, alignment: .trailing)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct EmptyDialogsView: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen
    
    var body: some View {
        Spacer()
        VStack(spacing: 16.0) {
            settings.messageImage
                .resizable()
                .scaledToFit()
                .foregroundColor(settings.messageImageColor)
                .frame(width: 60, height: 60)
            Text(settings.itemsIsEmpty)
                .font(settings.itemsIsEmptyFont)
                .foregroundColor(settings.itemsIsEmptyColor)
            
        }
        Spacer()
    }
}
