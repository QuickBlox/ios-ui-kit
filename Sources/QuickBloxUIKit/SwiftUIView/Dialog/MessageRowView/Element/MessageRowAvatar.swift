//
//  MessageRowAvatar.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxLog

public struct MessageRowAvatar<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var message: MessageItem
    
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    
    public init(message: MessageItem) {
        self.message = message
    }
    public var body: some View {
        if settings.isHiddenAvatar == false {
            VStack(spacing: settings.spacing) {
                Spacer()
                avatar.resizable()
                    .scaledToFill()
                    .frame(width: settings.avatar.height,
                           height: settings.avatar.height)
                    .clipShape(Circle())
                    .task {
                        let size = CGSizeMake(settings.avatar.height,
                                              settings.avatar.height)
                        do { avatar = try await message.avatar(size: size) } catch { prettyLog(error) }
                    }
            }.padding(.leading)
        }
    }
}

import QuickBloxData

struct MessageRowAvatar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageRowAvatar(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: true))
            .previewDisplayName("Delivered")
            
            MessageRowAvatar(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: true))
            .previewDisplayName("Delivered Dark")
            .preferredColorScheme(.dark)
            
            MessageRowAvatar(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: false))
            .previewDisplayName("Send")
            
            MessageRowAvatar(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isDelivered: false))
            .previewDisplayName("Send Dark")
            .preferredColorScheme(.dark)
            
            MessageRowAvatar(message: Message(id: UUID().uuidString,
                                              dialogId: "1f2f3ds4d5d6d",
                                              text: "Test text Message",
                                              userId: "testid",
                                              date: Date(),
                                              isRead: true))
            .previewDisplayName("Read Dark")
            
            MessageRowAvatar(message: Message(id: UUID().uuidString,
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
