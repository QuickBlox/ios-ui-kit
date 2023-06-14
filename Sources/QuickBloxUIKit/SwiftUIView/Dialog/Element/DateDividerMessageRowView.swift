//
//  DateDividerMessageRowView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct DateDividerMessageRowView<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    public init(message: MessageItem) {
        self.message = message
    }
    
    public var body: some View {
        VStack {
            Spacer()
            Text(message.text)
                .font(settings.dateFont)
                .foregroundColor(settings.dateForeground)
                .padding(settings.datePadding)
                .background(Capsule().fill(settings.dateBackground))
                .padding(.horizontal)
                .padding(.top, 22)
                .padding(.bottom, 0)
                .id(message.id)
        }.fixedSize(horizontal: false, vertical: true)
    }
}

struct DateDividerMessageRowView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            DateDividerMessageRowView(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Yesterday", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("Out Message")
            
            DateDividerMessageRowView(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "5 June", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("Out Dark Message")
                .preferredColorScheme(.dark)
        }
    }
}
