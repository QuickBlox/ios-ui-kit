//
//  DialogRowName.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct DialogRowName {
    
    public var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.name
    
    public var text: String
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var height: CGFloat = 18.0
}

extension DialogRowName: View {
    public var body: some View {
        Text(text)
            .font(font ?? settings.font)
            .foregroundColor(foregroundColor ?? settings.foregroundColor)
            .frame(height: height)
    }
}

extension DialogRowView {
    func name(text: String? = nil,
              font: Font? = nil,
              foregroundColor: Color? = nil) -> Self {
        var row = Self.init(self)
        row.nameView = DialogRowName(text: text ?? dialog.name,
                                     font: font,
                                     foregroundColor: foregroundColor)
        return row
    }
}

struct DialogRowNameView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DialogRowName(text: "Private Dialog")
            DialogRowName(text: "Foreground Color", foregroundColor: .red)
            DialogRowName(text: "Font", font: .title)
        }.previewLayout(.fixed(width: 237, height: 18))
    }
}
