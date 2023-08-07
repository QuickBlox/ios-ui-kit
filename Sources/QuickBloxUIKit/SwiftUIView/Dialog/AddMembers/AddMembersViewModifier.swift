//
//  AddMembersViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct AddMembersHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.addMembersScreen.header
    
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
                if let title = settings.leftButton.title {
                    Text(title)
                        .foregroundColor(settings.leftButton.color)
                } else {
                    settings.leftButton.image
                        .resizable()
                        .scaleEffect(settings.leftButton.scale)
                        .tint(settings.leftButton.color)
                        .padding(settings.leftButton.padding)
                }
            }
        }
    }
}

public struct AddMembersHeader: ViewModifier {
    private var settings = QuickBloxUIKit.settings.addMembersScreen.header
    
    let onDismiss: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            AddMembersHeaderToolbarContent(onDismiss: onDismiss)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
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
