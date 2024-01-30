//
//  PrivateDialogInfoViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct PrivateDialogInfoHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.dialogInfoScreen.privateHeader
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
        .navigationTitle(settings.title.text)
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(false)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
