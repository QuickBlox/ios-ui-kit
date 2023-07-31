//
//  DialogRowBadge.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct DialogRowBadge {
    
    public var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.unreadCount
    public var count: Int
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var backgroundColor: Color? = nil
    public var padding: EdgeInsets = .init(top: 2,
                                           leading: 6,
                                           bottom: 2,
                                           trailing: 6)
}

extension DialogRowBadge: View {
    public var body: some View {
        if (count <= 0) {
            EmptyView()
        } else {
            Text(count <= settings.maxCount ? "\(count)" : "\(settings.maxCount)+")
                .font(font ?? settings.font)
                .foregroundColor(foregroundColor ?? settings.foregroundColor)
                .padding(padding)
                .background(Capsule().fill(backgroundColor ?? settings.backgroundColor))
        }
    }
}

extension DialogRowView {
    func `badge`(maxCount: Int = QuickBloxUIKit.settings.dialogsScreen.dialogRow.unreadCount.maxCount,
                font: Font? = nil,
                foregroundColor: Color? = nil,
                backgroundColor: Color? = nil,
                padding: EdgeInsets = .init(top: 2,
                                            leading: 6,
                                            bottom: 2,
                                            trailing: 6)) -> Self {
        var row = Self.init(self)
        row.badgeView = DialogRowBadge(count: dialog.unreadMessagesCount,
                              font: font,
                              foregroundColor: foregroundColor,
                              backgroundColor: backgroundColor,
                              padding: padding)
        return row
    }
}


import QuickBloxData
import QuickBloxDomain

struct Badge_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            DialogRowBadge(count: 0)
            
            DialogRowBadge(count:3).previewSettings(name: "Count")
            
            DialogRowBadge(count:5).previewSettings(scheme: .dark, name: "Dark")
            
            DialogRowBadge(count:56, font: .title).previewSettings(name: "Font")
            
            DialogRowBadge(count:7, foregroundColor: .green)
                .previewSettings(name: "ForegroundColor")
            
            DialogRowBadge(count:102, backgroundColor: .green)
                .previewSettings(name: "BackgroundColor")
            
            DialogRowBadge(count:1001)
                .previewSettings(name: "MaxCount")
            
        }
    }
}
