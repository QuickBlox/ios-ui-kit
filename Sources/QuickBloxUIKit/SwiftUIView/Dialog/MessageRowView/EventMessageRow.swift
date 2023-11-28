//
//  EventMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct EventMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    public init(message: MessageItem) {
        self.message = message
    }
    
    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(message.text)
                    .multilineTextAlignment(.center)
                    .foregroundColor(settings.infoForeground)
                    .font(settings.infoFont)
                    .padding(.horizontal)
            }
            Spacer()
        }
        .id(message.id)
        .padding(.bottom, message.actionType == .reply && message.relatedId.isEmpty == false ? 2 : settings.spacerBetweenRows)
        
        .fixedSize(horizontal: false, vertical: true)
    }
}

import QuickBloxData

struct EventMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            EventMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Username join this chat", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("Out Message")
            
            EventMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Username join this chat", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("Out Dark Message")
                .preferredColorScheme(.dark)
        }
    }
}
