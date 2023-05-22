//
//  DialogTypeViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct DialogTypeHeaderToolbarContent: ToolbarContent {
    
    private var header = QuickBloxUIKit.settings.dialogTypeScreen.header
    
    let onCloseButtonTapped: () -> Void
    
    public init(
        onCloseButtonTapped: @escaping () -> Void) {
            self.onCloseButtonTapped = onCloseButtonTapped
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(header.title.text)
                .font(header.title.font)
                .foregroundColor(header.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onCloseButtonTapped()
            } label: {
                if let title = header.rightButton.title {
                    Text(title).foregroundColor(header.rightButton.color)
                } else {
                    header.rightButton.image.tint(header.rightButton.color)
                }
            }
        }
    }
}

public struct DialogTypeHeader: ViewModifier {
    
    public var header = QuickBloxUIKit.settings.dialogTypeScreen.header
    
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogTypeHeaderToolbarContent(onCloseButtonTapped: onClose)
        }.navigationBarTitleDisplayMode(header.displayMode)
    }
}


public struct MaterialModifier: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogTypeScreen
    
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(settings.backgroundColor)
            .opacity(settings.opacity)
    }
}

extension Spacer {
    func materialModifier() -> some View {
        modifier(MaterialModifier())
    }
}
