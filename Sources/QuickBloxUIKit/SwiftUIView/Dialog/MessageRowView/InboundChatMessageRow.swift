//
//  InboundChatMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct InboundChatMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    public init(message: MessageItem) {
        self.message = message
    }
    
    public var body: some View {
        
        HStack {
            
            MessageRowAvatar(message: message)
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    
                    MessageRowText(isOutbound: false, text: message.text)
                    
                    MessageRowTime(date: message.date)
                }
            }
            Spacer(minLength: settings.inboundSpacer)
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
}

import QuickBloxData

struct InboundChatMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text https://quickblox.com/blog/how-to-build-chat-app-with-ios-ui-kit/ Message", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("Message")
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("In Message")
                .preferredColorScheme(.dark)
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "T", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("1")
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message ", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("In Dark Message")
                .preferredColorScheme(.dark)
        }
    }
}
