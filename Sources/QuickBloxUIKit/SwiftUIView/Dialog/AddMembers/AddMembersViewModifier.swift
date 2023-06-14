//
//  AddMembersViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct AddMembersHeaderToolbarContent: ToolbarContent {
    
    private var header = QuickBloxUIKit.settings.addMembersScreen.header
    
    let onDismiss: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
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
    }
}

public struct AddMembersHeader: ViewModifier {
    private var header = QuickBloxUIKit.settings.addMembersScreen.header
    
    let onDismiss: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            AddMembersHeaderToolbarContent(onDismiss: onDismiss)
        }
        .navigationTitle(header.title.text)
        .navigationBarTitleDisplayMode(header.displayMode)
        .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func addMembersHeader(onDismiss: @escaping () -> Void) -> some View {
        self.modifier(AddMembersHeader(onDismiss: onDismiss))
    }
}

public struct AddUserAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.addMembersScreen.addUser
    
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
                    Button(settings.add, action: {
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
    func addUserAlert(
        isPresented: Binding<Bool>,
        name: String,
        onCancel: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) -> some View {
        self.modifier(AddUserAlert(isPresented: isPresented,
                                      name: name,
                                      onCancel: onCancel,
                                      onTap: onTap))
    }
}
