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
    
    let onAdd: () -> Void
    
    public init(onAdd: @escaping () -> Void) {
        self.onAdd = onAdd
    }
    
    public var body: some ToolbarContent {
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
    
    let onAdd: () -> Void
    
    public init(onAdd: @escaping () -> Void) {
        self.onAdd = onAdd
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            MembersHeaderToolbarContent(onAdd: onAdd)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(false)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
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
