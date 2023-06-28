//
//  DialogListHeader.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct DialogListHeaderToolbarContent: ToolbarContent {
    
    private var header = QuickBloxUIKit.settings.dialogsScreen.header
    
    let onDismiss: () -> Void
    let onTapDialogType: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void,
        onTapDialogType: @escaping () -> Void) {
            self.onDismiss = onDismiss
            self.onTapDialogType = onTapDialogType
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onDismiss()
            } label: {
                if let title = header.leftButton.title {
                    Text(title).foregroundColor(header.leftButton.color)
                } else {
                    header.leftButton.image.tint(header.leftButton.color)
                }
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(header.title.text)
                .font(header.title.font)
                .foregroundColor(header.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapDialogType()
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

public struct DialogListHeader: ViewModifier {
    
    private var header = QuickBloxUIKit.settings.dialogsScreen.header
    
    let onDismiss: () -> Void
    let onTapDialogType: () -> Void
    
    public init(onDismiss: @escaping () -> Void,
                onTapDialogType: @escaping () -> Void) {
        self.onDismiss = onDismiss
        self.onTapDialogType = onTapDialogType
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogListHeaderToolbarContent(onDismiss: onDismiss,
                                           onTapDialogType: onTapDialogType)
        }
        .navigationBarTitleDisplayMode(header.displayMode)
        .navigationBarBackButtonHidden(true)
    }
}

public extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func setupNavigationBarAppearance(titleColor: UIColor,
                                      barColor: UIColor,
                                      shadowColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = barColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.shadowColor = shadowColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

public var isIphone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}

public var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}
