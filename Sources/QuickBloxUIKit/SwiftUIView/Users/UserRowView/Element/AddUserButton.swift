//
//  AddUserButton.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 27.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct AddUserButton: View {
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow.checkbox
    
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var backgroundColor: Color? = nil
    public let onTap: () -> Void

    public var body: some View {
            Button {
                onTap()
            } label: {
                settings.add.foregroundColor(settings.foregroundColorDelete)
            }.frame(width: settings.heightButton, height: settings.heightButton)
    }
}

struct AddUserButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddUserButton(onTap: {})
            AddUserButton(onTap: {})
                .preferredColorScheme(.dark)
            AddUserButton(onTap: {})
            AddUserButton(onTap: {})
                .preferredColorScheme(.dark)
            AddUserButton(onTap: {})
            AddUserButton(onTap: {})
                .preferredColorScheme(.dark)
        }
    }
}
