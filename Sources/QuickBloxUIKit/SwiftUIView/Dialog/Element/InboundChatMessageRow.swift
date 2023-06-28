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
    
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    
    @State public var userName: String?
    
    public init(message: MessageItem) {
        self.message = message
    }
    
    public var body: some View {
        
        HStack {
            if settings.isShowAvatar == true {
                VStack(spacing: settings.spacing) {
                    Spacer()
                    AvatarView(image: avatar,
                               height: settings.avatar.height,
                               isShow: settings.isShowAvatar)
                    .task {
                        let size = CGSizeMake(settings.avatar.height,
                                              settings.avatar.height)
                        do { avatar = try await message.avatar(size: size) } catch { prettyLog(error) }
                    }
                }.padding(.leading)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                if settings.isShowName == true {
                    Text(userName ?? String(message.userId))
                        .foregroundColor(settings.name.foregroundColor)
                        .font(settings.name.font)
                        .padding(settings.inboundNamePadding)
                        .task {
                            do { userName = try await message.userName } catch { prettyLog(error) }
                        }
                }
                
                HStack(spacing: 8) {

                    if message.text.containtsLink == true {
                        Text(message.text.makeAttributedString(settings.inboundForeground,
                                                               linkColor: settings.inboundLinkForeground))
                        .lineLimit(nil)
                        .foregroundColor(settings.inboundForeground)
                        .font(settings.inboundFont)
                        .padding(settings.messagePadding)
                        .background(settings.inboundBackground)
                        .cornerRadius(settings.bubbleRadius, corners: settings.inboundCorners)
                        .padding(settings.inboundPadding(showName: settings.isShowName))
                    } else {
                        Text(message.text)
                            .lineLimit(nil)
                            .foregroundColor(settings.inboundForeground)
                            .font(settings.inboundFont)
                            .padding(settings.messagePadding)
                            .background(settings.inboundBackground)
                            .cornerRadius(settings.bubbleRadius, corners: settings.inboundCorners)
                            .padding(settings.inboundPadding(showName: settings.isShowName))
                    }
                        
                    if settings.isShowTime == true {
                        VStack {
                            Spacer()
                            Text("\(message.date, formatter: Date.formatter)")
                                .foregroundColor(settings.time.foregroundColor)
                                .font(settings.time.font)
                                .padding(.bottom, 2)
                        }
                    }
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
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message", userId: "2d3d4d5d6d", date: Date()))
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
