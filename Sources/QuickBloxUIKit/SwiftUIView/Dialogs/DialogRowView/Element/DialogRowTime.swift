//
//  DialogRowTime.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct DialogRowTime {
    
    public var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.time
    
    public var time: String? = nil
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var isShow: Bool
}

extension DialogRowTime: View {
    public var body: some View {
        if let time {
            Text(time)
                .font(font ?? settings.font)
                .foregroundColor(foregroundColor ?? settings.foregroundColor)
        } else {
            EmptyView()
        }
    }
}

extension DialogRowView {
    func time(_ time: String? = nil,
              font: Font? = nil,
              foregroundColor: Color? = nil,
              isShow: Bool = true) -> Self {
        var row = Self.init(self)
        row.timeView = DialogRowTime(time: time,
                                     font: font,
                                     foregroundColor: foregroundColor,
                                     isShow: isShow)
        return row
    }
}

struct DialogRowTime_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DialogRowTime(time: "Yesterday", isShow: true)
            DialogRowTime(time: "15:30", foregroundColor: .red, isShow: true)
            DialogRowTime(time: "15 Jun", font: .footnote, isShow: true)
        }.previewLayout(.fixed(width: 375, height: 13))
    }
}
