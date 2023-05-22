//
//  PrivateDialogInfoViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct PrivateDialogInfoHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogInfoScreen.privateHeader
    let onDismiss: () -> Void
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
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
    }
}

public struct PrivateDialogInfoHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.createDialogScreen.header
    
    let onDismiss: () -> Void
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            PrivateDialogInfoHeaderToolbarContent(onDismiss: onDismiss)
        }
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func privateDialogInfoHeader(onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(PrivateDialogInfoHeader(onDismiss: onDismiss))
    }
}
