//
//  GroupDialogNonEditInfoViewViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 25.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct GroupDialogNonEditInfoHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.dialogInfoScreen.nonEditHeader
    
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
