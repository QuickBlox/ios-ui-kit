//
//  DialogTypeViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct DialogTypeHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogTypeScreen.header
    
    let onCloseButtonTapped: () -> Void
    
    public init(
        onCloseButtonTapped: @escaping () -> Void) {
            self.onCloseButtonTapped = onCloseButtonTapped
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onCloseButtonTapped()
            } label: {
                if let title = settings.rightButton.title {
                    Text(title).foregroundColor(settings.rightButton.color)
                } else {
                    settings.rightButton.image
                        .resizable()
                        .scaleEffect(settings.rightButton.scale)
                        .tint(settings.rightButton.color)
                        .padding(settings.rightButton.padding)
                }
            }
        }
    }
}

public struct DialogTypeHeader: ViewModifier {
    
    public var settings = QuickBloxUIKit.settings.dialogTypeScreen.header
    
    let onClose: () -> Void
    
    public init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogTypeHeaderToolbarContent(onCloseButtonTapped: onClose)
        }
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarHidden(settings.isHidden)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
