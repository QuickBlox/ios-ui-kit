//
//  MembersViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct MembersHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.membersScreen.header
    
    let onDismiss: () -> Void
    let onAdd: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void,
        onAdd: @escaping () -> Void) {
            self.onDismiss = onDismiss
            self.onAdd = onAdd
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onDismiss()
            } label: {
                if let title = settings.leftButton.title {
                    Text(title)
                        .foregroundColor(settings.leftButton.color)
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
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onAdd()
            } label: {
                if let title = settings.rightButton.title {
                    Text(title)
                        .foregroundColor(settings.rightButton.color)
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

public struct MembersHeader: ViewModifier {
    private var settings = QuickBloxUIKit.settings.membersScreen.header
    
    let onDismiss: () -> Void
    let onAdd: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void,
        onAdd: @escaping () -> Void) {
            self.onDismiss = onDismiss
            self.onAdd = onAdd
        }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            MembersHeaderToolbarContent(onDismiss: onDismiss,
                                        onAdd: onAdd)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
    }
}

extension View {
    func membersHeader(onDismiss: @escaping () -> Void,
                       onAdd: @escaping () -> Void) -> some View {
        self.modifier(MembersHeader(onDismiss: onDismiss,
                                       onAdd: onAdd))
    }
}

public struct RemoveUserAlert: ViewModifier {
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
                    })
                    Button(settings.remove, role: .destructive, action: {
                        onTap()
                    })
                } message: {
                    Text(settings.message)
                }
        }
    }
}

extension View {
    func removeUserAlert(
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
