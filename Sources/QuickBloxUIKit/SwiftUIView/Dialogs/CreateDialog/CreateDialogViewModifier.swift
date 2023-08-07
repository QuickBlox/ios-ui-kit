//
//  CreateDialogViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 18.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct CreateDialogHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.createDialogScreen.header
    let onDismiss: () -> Void
    let onTapCreate: () -> Void
    var disabled: Bool = true
    
    public init(
        onDismiss: @escaping () -> Void,
        onTapCreate: @escaping () -> Void,
        disabled: Bool) {
            self.onDismiss = onDismiss
            self.onTapCreate = onTapCreate
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
                    settings.leftButton.image
                        .resizable()
                        .scaleEffect(settings.leftButton.scale)
                        .tint(settings.leftButton.color)
                        .padding(settings.leftButton.padding)
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapCreate()
            } label: {
                if let title = settings.rightButton.title {
                    Text(title).foregroundColor(settings.rightButton.color.opacity(disabled == true ? settings.opacity : 1.0))
                } else {
                    settings.rightButton.image
                        .resizable()
                        .scaleEffect(settings.rightButton.scale)
                        .tint(settings.rightButton.color.opacity(disabled == true ? settings.opacity : 1.0))
                        .padding(settings.rightButton.padding)
                }
            }.disabled(disabled)
        }
    }
}

public struct CreateDialogHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.createDialogScreen.header
    
    let onDismiss: () -> Void
    let onTapCreate: () -> Void
    var disabled: Bool = true
    
    public init(
        onDismiss: @escaping () -> Void,
        onTapCreate: @escaping () -> Void,
        disabled: Bool) {
            self.onDismiss = onDismiss
            self.onTapCreate = onTapCreate
            self.disabled = disabled
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            CreateDialogHeaderToolbarContent(onDismiss: onDismiss,
                                           onTapCreate: onTapCreate,
                                             disabled: disabled)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
    }
}
