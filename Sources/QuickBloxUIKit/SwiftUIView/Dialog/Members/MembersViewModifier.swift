//
//  MembersViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct MembersHeaderToolbarContent: ToolbarContent {
    
    private var header = QuickBloxUIKit.settings.membersScreen.header
    
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
                if let title = header.leftButton.title {
                    Text(title)
                        .foregroundColor(header.leftButton.color)
                } else {
                    header.leftButton.image.tint(header.leftButton.color)
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onAdd()
            } label: {
                if let title = header.rightButton.title {
                    Text(title)
                        .foregroundColor(header.rightButton.color)
                } else {
                    header.rightButton.image.tint(header.rightButton.color)
                }
            }
        }
    }
}

public struct MembersHeader: ViewModifier {
    private var header = QuickBloxUIKit.settings.membersScreen.header
    
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
        .navigationTitle(header.title.text)
        .navigationBarTitleDisplayMode(header.displayMode)
        .navigationBarBackButtonHidden(true)
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
                        isPresented = false
                    })
                    Button(settings.remove, role: .destructive, action: {
                        onTap()
                        isPresented = false
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
