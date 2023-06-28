//
//  OutboundChatMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct OutboundChatMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    public init(message: MessageItem) {
        self.message = message
    }
    
    public var body: some View {
        
        HStack {
            
            Spacer(minLength: settings.outboundSpacer)
            
            if settings.isShowTime == true {
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack(spacing: 3) {
                        message.statusImage
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(message.statusForeground)
                            .scaledToFit()
                            .frame(width: 10, height: 5)
                        Text("\(message.date, formatter: Date.formatter)")
                            .foregroundColor(settings.time.foregroundColor)
                            .font(settings.time.font)
                    }.padding(.bottom, 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                
                if message.text.containtsLink == true {
                    Text(message.text.makeAttributedString(settings.outboundForeground,
                                                           linkColor: settings.outboundLinkForeground))
                        .lineLimit(nil)
                        .foregroundColor(settings.outboundForeground)
                        .font(settings.outboundFont)
                        .padding(settings.messagePadding)
                        .background(settings.outboundBackground)
                        .cornerRadius(settings.bubbleRadius, corners: settings.outboundCorners)
                        .padding(settings.outboundPadding)
                } else {
                    Text(message.text)
                        .lineLimit(nil)
                        .foregroundColor(settings.outboundForeground)
                        .font(settings.outboundFont)
                        .padding(settings.messagePadding)
                        .background(settings.outboundBackground)
                        .cornerRadius(settings.bubbleRadius, corners: settings.outboundCorners)
                        .padding(settings.outboundPadding)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
}

import QuickBloxData

struct OutboundChatMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message", userId: "testid", date: Date()))
                .previewDisplayName("Out Message")
            
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("In Message")
                .preferredColorScheme(.dark)
            
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "T", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("1")
            
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message ", userId: "2d3d4d5d6d", date: Date()))
                .previewDisplayName("In Dark Message")
                .preferredColorScheme(.dark)
        }
    }
}
