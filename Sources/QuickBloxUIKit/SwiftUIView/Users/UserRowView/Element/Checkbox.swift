//
//  Checkbox.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 02.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct Checkbox: View {
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow.checkbox
    
    public var isSelected: Bool
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var backgroundColor: Color? = nil
    public var onTap: () -> Void
    
    public var body: some View {
        Button {
            onTap()
        } label: {
            if isSelected {
                settings.selected
                    .font(font ?? settings.font)
                    .foregroundColor(foregroundColor ?? settings.foregroundColorSelected)
                    .frame(width: settings.heightSelected, height: settings.heightSelected)
                    .background(backgroundColor ?? settings.backgroundColor)
                    .scaledToFit()
                    .clipShape(Circle())
            } else {
                Circle()
                    .strokeBorder(settings.strokeBorder, lineWidth: settings.lineWidth)
                    .frame(width: settings.heightSelected, height: settings.heightSelected)
            }
        }.frame(width: settings.heightButton, height: settings.heightButton)
    }
}

struct Checkbox_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Checkbox(isSelected: false, onTap: {})
            Checkbox(isSelected: false, onTap: {})
                .preferredColorScheme(.dark)
            Checkbox(isSelected: true, onTap: {})
            Checkbox(isSelected: true, onTap: {})
                .preferredColorScheme(.dark)
            Checkbox(isSelected: true, onTap: {})
            Checkbox(isSelected: true, onTap: {})
                .preferredColorScheme(.dark)
        }
    }
}
