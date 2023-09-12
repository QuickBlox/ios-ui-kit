//
//  GroupDialogNonEditInfoViewViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct GroupDialogNonEditInfoHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogInfoScreen.nonEditHeader
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
                    settings.leftButton.image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(settings.leftButton.scale)
                        .tint(settings.leftButton.color)
                        .padding(settings.leftButton.padding)
                }
            }
            .frame(width: 32, height: 44)
        }
    }
}

public struct GroupDialogNonEditInfoHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.dialogInfoScreen.nonEditHeader
    
    let onDismiss: () -> Void
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            GroupDialogNonEditInfoHeaderToolbarContent(onDismiss: onDismiss)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
    }
}
