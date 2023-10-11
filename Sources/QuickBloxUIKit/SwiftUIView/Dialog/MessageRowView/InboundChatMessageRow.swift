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
    var aiFeatures = QuickBloxUIKit.feature.ai
    
    var message: MessageItem
    @State var showOriginal: Bool = true
    
    let onAIFeature: (_ type: AIFeatureType, _ message: MessageItem) -> Void
    var aiAnswerWaiting: Bool = false
    
    public init(message: MessageItem,
                onAIFeature: @escaping  (_ type: AIFeatureType,
                                         _ message: MessageItem) -> Void,
                aiAnswerWaiting: AIAnswerInfo) {
        self.message = message
        self.onAIFeature = onAIFeature
        if message.id == aiAnswerWaiting.id {
            self.aiAnswerWaiting = aiAnswerWaiting.waiting
        }
    }
    
    public var body: some View {
        
        HStack {
            
            MessageRowAvatar(message: message)
                .padding(.bottom, aiFeatures.translate.enable == true ? 18 : 0)
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 6) {
                        
                        MessageRowText(isOutbound: false, text: message.translatedText.isEmpty == false && showOriginal == false ? message.translatedText : message.text)
                        
                        if aiFeatures.translate.enable == true {
                            
                            Button {
                                if aiFeatures.translate.enable == true {
                                    if showOriginal == true && message.translatedText.isEmpty == false {
                                        showOriginal = false
                                    } else if showOriginal == false && message.translatedText.isEmpty == false {
                                        showOriginal = true
                                    } else {
                                        onAIFeature(.translate, message)
                                    }
                                }
                            } label: {
                                Text(message.translatedText.isEmpty == false && showOriginal == false ? aiFeatures.ui.translate.showOriginal : aiFeatures.ui.translate.showTranslation)
                                    .lineLimit(1)
                                    .foregroundColor(settings.infoForeground)
                                    .font(settings.translateFont)
                                    .padding(.trailing)
                            }
                        }
                    }
                    .frame(minWidth: aiFeatures.translate.enable == true ? aiFeatures.ui.translate.width : 0)
                    
                        .onChange(of: message.translatedText) { newValue in
                            if newValue.isEmpty == false {
                                showOriginal = false
                            }
                        }
                    
                    if aiAnswerWaiting == true {
                        SegmentedCircularBar(settings: settings.aiProgressBar)
                            .padding(.bottom, aiFeatures.translate.enable == true ? 18 : 0)
                    } else if aiFeatures.answerAssist.enable == true, aiFeatures.ui.robot.hidden == false {
                        Menu {
                            if aiFeatures.answerAssist.enable == true {
                                Button {
                                    onAIFeature(.answerAssist, message)
                                } label: {
                                    Label(aiFeatures.ui.answerAssist.title, systemImage: "")
                                }
                            }
                            
                        } label: {
                            aiFeatures.ui.robot.icon
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(aiFeatures.ui.robot.foreground)
                                .frame(width: aiFeatures.ui.robot.size.width,
                                       height: aiFeatures.ui.robot.size.height)
                            
                        }.padding(.bottom, aiFeatures.translate.enable == true ? 18 : 0)
                    }
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            
                            MessageRowTime(date: message.date)
                            
                        }.padding(.bottom, aiFeatures.translate.enable == true ? 20 : 2)
                    }
                }
            }
            Spacer(minLength: settings.inboundSpacer)
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
        .contextMenu {
            if aiFeatures.ui.robot.hidden == true,
               aiFeatures.answerAssist.enable == true {
                Button {
                    onAIFeature(.answerAssist, message)
                } label: {
                    Label(aiFeatures.ui.answerAssist.title, systemImage: "")
                }
            }
        }
    }
}

import QuickBloxData

struct InboundChatMessageRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            InboundChatMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "Test text https://quickblox.com/blog/how-to-build-chat-app-with-ios-ui-kit/ Message",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo())
            .previewDisplayName("Message")

            InboundChatMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "Test text Message",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo())
            .previewDisplayName("In Message")
            .preferredColorScheme(.dark)

            InboundChatMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "T",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo())
            .previewDisplayName("1")

            InboundChatMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message ",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo())
            .previewDisplayName("In Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
