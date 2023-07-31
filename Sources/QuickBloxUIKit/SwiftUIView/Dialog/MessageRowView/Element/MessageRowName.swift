//
//  MessageRowName.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxLog

public struct MessageRowName<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var message: MessageItem
    @State public var userName: String?
    
    public init(message: MessageItem) {
        self.message = message
    }
    public var body: some View {
        if settings.isHiddenName == false {
            Text(userName ?? String(message.userId))
                .foregroundColor(settings.name.foregroundColor)
                .font(settings.name.font)
                .padding(settings.inboundNamePadding)
                .task {
                    do { userName = try await message.userName } catch { prettyLog(error) }
                }
        } else {
            EmptyView()
        }
    }
}

import QuickBloxData

struct MessageRowName_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageRowName(message: Message(id: UUID().uuidString,
                                            dialogId: "1f2f3ds4d5d6d",
                                            text: "Test text Message",
                                            userId: "testid",
                                            date: Date(),
                                            isDelivered: true))
            .previewDisplayName("Time")
            
            MessageRowName(message: Message(id: UUID().uuidString,
                                            dialogId: "1f2f3ds4d5d6d",
                                            text: "Test text Message",
                                            userId: "testid",
                                            date: Date(),
                                            isDelivered: true))
            .previewDisplayName("Time Dark")
            .preferredColorScheme(.dark)
        }
    }
}
