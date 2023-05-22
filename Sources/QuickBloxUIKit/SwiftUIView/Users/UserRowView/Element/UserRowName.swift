//
//  UserRowName.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 02.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct UserRowName: View {
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow.name
    
    public var text: String
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var height: CGFloat = 18.0

    public var body: some View {
        Text(text)
            .font(font ?? settings.font)
            .foregroundColor(foregroundColor ?? settings.foregroundColor)
    }
}

struct UserRowName_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserRowName(text: "User Name")
            
            UserRowName(text: "User Name")
                .preferredColorScheme(.dark)
            UserRowName(text: "Foreground Color", foregroundColor: .red)
            UserRowName(text: "Font", font: .title)
        }.previewLayout(.fixed(width: 237, height: 18))
    }
}

public struct RoleUserRowName: View {
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow.roleName
    public var font: Font? = nil
    public var foregroundColor: Color? = nil

    public var body: some View {
        Text(settings.admin)
            .font(font ?? settings.font)
            .foregroundColor(foregroundColor ?? settings.foregroundColor)
    }
}
