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
    let assistAnswer = QuickBloxUIKit.feature.ai.assistAnswer
    
    var message: MessageItem
    
    let onAssistAnswer: (_ message: MessageItem?) -> Void
    
    public init(message: MessageItem,
                onAssistAnswer: @escaping  (_ message: MessageItem?) -> Void) {
        self.message = message
        self.onAssistAnswer = onAssistAnswer
    }
    
    public var body: some View {
        
        HStack {
            
            MessageRowAvatar(message: message)
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    
                    MessageRowText(isOutbound: false, text: message.text)
                    
                    if assistAnswer.enable == true {
                        Menu {
                            Button {
                                if assistAnswer.isValidAI == true {
                                    onAssistAnswer(message)
                                } else {
                                    onAssistAnswer(nil)
                                }
                            } label: {
                                Label("AI Assist Answer", systemImage: "icon_name")
                            }
                        } label: {
                            settings.robot
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(settings.robotForeground)
                                .frame(width: settings.robotSize.width,
                                       height: settings.robotSize.height)
                            
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            
                            MessageRowTime(date: message.date)
                            
                        }.padding(.bottom, 2)
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
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text https://quickblox.com/blog/how-to-build-chat-app-with-ios-ui-kit/ Message", userId: "2d3d4d5d6d", date: Date()), onAssistAnswer: {_ in})
                .previewDisplayName("Message")
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message", userId: "2d3d4d5d6d", date: Date()), onAssistAnswer: {_ in})
                .previewDisplayName("In Message")
                .preferredColorScheme(.dark)
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "T", userId: "2d3d4d5d6d", date: Date()), onAssistAnswer: {_ in})
                .previewDisplayName("1")
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message ", userId: "2d3d4d5d6d", date: Date()), onAssistAnswer: {_ in})
                .previewDisplayName("In Dark Message")
                .preferredColorScheme(.dark)
        }
    }
}
