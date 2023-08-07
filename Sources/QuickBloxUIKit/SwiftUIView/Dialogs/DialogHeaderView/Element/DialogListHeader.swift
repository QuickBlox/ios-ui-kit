//
//  DialogListHeader.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct DialogListHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogsScreen.header
    
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
        
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapDialogType()
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

public struct DialogListHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.dialogsScreen
    
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(settings.header.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.header.isHidden)
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
    
    func navigationBar(titleColor: UIColor,
                                      barColor: UIColor,
                                      shadowColor: UIColor) -> some View {
        
        self.modifier(NavigationBarColor(titleColor: titleColor,
                                         barColor: barColor,
                                         shadowColor: shadowColor))
    }
}

public var isIphone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}

public var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

struct NavigationBarColor: ViewModifier {

  init(titleColor: UIColor, barColor: UIColor, shadowColor: UIColor) {
    let appearance = UINavigationBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = barColor
      appearance.titleTextAttributes = [.foregroundColor: titleColor]
      appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
      appearance.shadowColor = shadowColor
                   
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().tintColor = titleColor
  }

  func body(content: Content) -> some View {
    content
  }
}
