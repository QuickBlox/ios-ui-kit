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
    public var isHidden: Bool
}

extension DialogRowTime: View {
    public var body: some View {
        if settings.isHidden == true  {
            EmptyView()
        } else if let time {
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
              isHidden: Bool = false) -> Self {
        var row = Self.init(self)
        row.timeView = DialogRowTime(time: time,
                                     font: font,
                                     foregroundColor: foregroundColor,
                                     isHidden: isHidden)
        return row
    }
}

struct DialogRowTime_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DialogRowTime(time: "Yesterday", isHidden: false)
            DialogRowTime(time: "15:30", foregroundColor: .red, isHidden: false)
            DialogRowTime(time: "15 Jun", font: .footnote, isHidden: false)
        }.previewLayout(.fixed(width: 375, height: 13))
    }
}
