//
//  MessageRowTime.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain

public struct MessageRowTime: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    let date: Date
    
    public init(date: Date) {
        self.date = date
    }
    public var body: some View {
        if settings.isHiddenTime == false {
                Text("\(date, formatter: Date.formatter)")
                    .foregroundColor(settings.time.foregroundColor)
                    .font(settings.time.font)
        } else {
            EmptyView()
        }
    }
}

import QuickBloxData

struct MessageRowTime_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageRowTime(date: Date())
            .previewDisplayName("Time")
            
            MessageRowTime(date: Date())
            .previewDisplayName("Time Dark")
            .preferredColorScheme(.dark)
        }
    }
}
