//
//  MessageRowStatus.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain

public struct MessageRowStatus<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var message: MessageItem
    
    public init(message: MessageItem) {
        self.message = message
    }
    
    public  var body: some View {
        if settings.isHiddenStatus == false {
                message.statusImage
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(message.statusForeground)
                    .scaledToFit()
                    .frame(width: 10, height: 5)
        } else {
            EmptyView()
        }
    }
}

import QuickBloxData

struct MessageRowStatus_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageRowStatus(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: true))
            .previewDisplayName("Delivered")
            
            MessageRowStatus(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: true))
            .previewDisplayName("Delivered Dark")
            .preferredColorScheme(.dark)
            
            MessageRowStatus(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: false))
            .previewDisplayName("Send")
            
            MessageRowStatus(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: false))
            .previewDisplayName("Send Dark")
            .preferredColorScheme(.dark)
            
            MessageRowStatus(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isRead: true))
            .previewDisplayName("Read Dark")
            
            MessageRowStatus(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isRead: true))
            .previewDisplayName("Read Dark")
            .preferredColorScheme(.dark)
        }
    }
}
