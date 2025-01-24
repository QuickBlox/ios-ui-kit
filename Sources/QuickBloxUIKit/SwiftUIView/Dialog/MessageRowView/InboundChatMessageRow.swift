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
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    @State var showOriginal: Bool = true
    
    let onAIFeature: (_ type: AIFeatureType, _ message: MessageItem) -> Void
    var aiAnswerWaiting: Bool = false
    
    private var messagesActionState: MessageAction
    private var isSelected = false
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
    private var size: CGSize {
        if let contentSize, contentSize.height / contentSize.width > settings.inboundPreviewRatio {
            return settings.inboundPreviewSize
        } else if let contentSize {
            return contentSize
        }
        return .zero
    }
    
    @State private var contentSize: CGSize?
    
    public init(message: MessageItem,
                messagesActionState: MessageAction,
                isSelected: Bool,
                onAIFeature: @escaping  (_ type: AIFeatureType,
                                         _ message: MessageItem) -> Void,
                aiAnswerWaiting: AIAnswerInfo,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
        self.messagesActionState = messagesActionState
        self.isSelected = isSelected
        self.onAIFeature = onAIFeature
        if message.id == aiAnswerWaiting.id,
           message.relatedId == aiAnswerWaiting.relatedId {
            self.aiAnswerWaiting = aiAnswerWaiting.waiting
        }
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ZStack {
            if features.ai.enable == false {
                messageView()
            } else {
                aiMessageView()
            }
        }
    }
    
    @ViewBuilder
    private func messageView() -> some View {
        HStack {
            
            if features.forward.enable == true,
               messagesActionState == .forward {
                Checkbox(isSelected: isSelected) {
                    onSelect(message, .forward)
                }
            }
            
            MessageRowAvatar(message: message)
            
            VStack(alignment: .leading, spacing: 0) {
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    VStack(alignment: .trailing) {
                        
                        MessageRowText(isOutbound: false, text: message.text)
                            .cornerRadius(settings.bubbleRadius, corners: message.actionType == .reply && message.relatedId.isEmpty == false ?
                                          settings.outboundForwardCorners : settings.inboundCorners)
                            .contentSize(onChange: { contentSize in
                                self.contentSize = contentSize
                            })
                            .if(contentSize != nil, transform: { view in
                                view.customContextMenu (
                                    preview: MessageRowText(isOutbound: false, text: message.text)
                                        .cornerRadius(settings.attachmentRadius, corners: settings.outboundForwardCorners),
                                    preferredContentSize: size
                                ) {
                                    CustomContextMenuAction(title: settings.reply.title,
                                                            systemImage: settings.reply.systemImage ?? "", tintColor: settings.reply.color, flipped: UIImageAxis.none,
                                                            attributes: features.reply.enable == true
                                                            ? nil : .hidden) {
                                        onSelect(message, .reply)
                                    }
                                    CustomContextMenuAction(title: settings.forward.title,
                                                            systemImage: settings.forward.systemImage ?? "", tintColor: settings.forward.color, flipped: .horizontal,
                                                            attributes: features.forward.enable == true
                                                            ? nil : .hidden) {
                                        onSelect(message, .forward)
                                    }
                                }
                            })
                    }
                    
                    if message.actionType == .none ||
                        message.actionType == .forward ||
                        message.actionType == .reply && message.relatedId.isEmpty == true {
                        VStack(alignment: .leading) {
                            Spacer()
                            HStack {
                                
                                MessageRowTime(date: message.date)
                                
                            }.padding(.bottom, 2)
                        }
                    }
                }
            }.padding(.leading, message.actionType == .reply && message.relatedId.isEmpty == false ? settings.relatedInboundSpacer : 0)
            
            Spacer(minLength: settings.inboundSpacer)
        }
        .padding(.bottom, actionSpacerBetweenRows())
        
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
    
    @ViewBuilder
    private func aiMessageView() -> some View {
        HStack {
            
            if features.forward.enable == true,
               messagesActionState == .forward {
                Checkbox(isSelected: isSelected) {
                    onSelect(message, .forward)
                }
            }
            
            MessageRowAvatar(message: message)
                .padding(.bottom, features.ai.translate.enable == true ? features.ai.ui.translate.buttonOffset : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 5) {
                        
                        MessageRowText(isOutbound: false, text: message.translatedText.isEmpty == false && showOriginal == false ? message.translatedText : message.text)
                            .cornerRadius(settings.bubbleRadius, corners: message.actionType == .reply && message.relatedId.isEmpty == false ?
                                          settings.outboundForwardCorners : settings.inboundCorners)
                            .contentSize(onChange: { contentSize in
                                self.contentSize = contentSize
                            })
                            .if(contentSize != nil, transform: { view in
                                view.customContextMenu (
                                    preview: MessageRowText(isOutbound: false, text: message.text)
                                        .cornerRadius(settings.attachmentRadius, corners: settings.outboundForwardCorners),
                                    preferredContentSize: size
                                ) {
                                    CustomContextMenuAction(title: features.ai.ui.answerAssist.title, tintColor: features.ai.ui.answerAssist.color, flipped: nil,
                                                            attributes: features.ai.ui.robot.hidden == true && features.ai.answerAssist.enable == true
                                                            ? nil : .hidden) {
                                        applyAIAnswerAssist()
                                    }
                                    CustomContextMenuAction(title: settings.reply.title,
                                                            systemImage: settings.reply.systemImage ?? "", tintColor: settings.reply.color, flipped: UIImageAxis.none,
                                                            attributes: features.reply.enable == true
                                                            ? nil : .hidden) {
                                        onSelect(message, .reply)
                                    }
                                    CustomContextMenuAction(title: settings.forward.title,
                                                            systemImage: settings.forward.systemImage ?? "", tintColor: settings.forward.color, flipped: .horizontal,
                                                            attributes: features.forward.enable == true
                                                            ? nil : .hidden) {
                                        onSelect(message, .forward)
                                    }
                                }
                            })
                        
                        if features.ai.translate.enable == true {
                            if features.forward.enable == true,
                               messagesActionState == .forward {
                                Text(message.translatedText.isEmpty == false && showOriginal == false ? features.ai.ui.translate.showOriginal : features.ai.ui.translate.showTranslation)
                                    .lineLimit(1)
                                    .foregroundColor(settings.infoForeground)
                                    .font(settings.translateFont)
                                    .padding(.trailing)
                            } else {
                                Button {
                                    if features.ai.translate.enable == true {
                                        if showOriginal == true && message.translatedText.isEmpty == false {
                                            showOriginal = false
                                        } else if showOriginal == false && message.translatedText.isEmpty == false {
                                            showOriginal = true
                                        } else {
                                            onAIFeature(.translate, message)
                                        }
                                    }
                                } label: {
                                    Text(message.translatedText.isEmpty == false && showOriginal == false ? features.ai.ui.translate.showOriginal : features.ai.ui.translate.showTranslation)
                                        .lineLimit(1)
                                        .foregroundColor(settings.infoForeground)
                                        .font(settings.translateFont)
                                        .padding(.trailing)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(minWidth: features.ai.translate.enable == true ? features.ai.ui.translate.width : 0)
                    
                    .onChange(of: message.translatedText) { newValue in
                        if newValue.isEmpty == false {
                            showOriginal = false
                        }
                    }
                    
                    if aiAnswerWaiting == true {
                        SegmentedCircularBar(settings: settings.aiProgressBar)
                            .padding(.bottom, features.ai.translate.enable == true ? features.ai.ui.translate.buttonOffset : 0)
                    } else if features.ai.answerAssist.enable == true, features.ai.ui.robot.hidden == false {
                        if features.forward.enable == true,
                           messagesActionState == .forward {
                            features.ai.ui.robot.icon
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(features.ai.ui.robot.foreground)
                                .frame(width: features.ai.ui.robot.size.width,
                                       height: features.ai.ui.robot.size.height)
                        } else {
                            Menu {
                                if features.ai.answerAssist.enable == true {
                                    Button {
                                        applyAIAnswerAssist()
                                    } label: {
                                        Label(features.ai.ui.answerAssist.title, systemImage: "")
                                    }.buttonStyle(.plain)
                                }
                                
                            } label: {
                                features.ai.ui.robot.icon
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(features.ai.ui.robot.foreground)
                                    .frame(width: features.ai.ui.robot.size.width,
                                           height: features.ai.ui.robot.size.height)
                                
                            }
                            .padding(.bottom, features.ai.translate.enable == true ? features.ai.ui.translate.buttonOffset : 0)
                        }
                    }
                    
                    if message.actionType == .none ||
                        message.actionType == .forward ||
                        message.actionType == .reply && message.relatedId.isEmpty == true {
                        VStack(alignment: .leading) {
                            Spacer()
                            HStack {
                                
                                MessageRowTime(date: message.date)
                                
                            }
                            .padding(.bottom, features.ai.translate.enable == true ? features.ai.ui.translate.buttonOffset + 2 : 2)
                        }
                    }
                }
            }.padding(.leading, message.actionType == .reply && message.relatedId.isEmpty == false ? settings.relatedInboundSpacer : 0)
            
            Spacer(minLength: settings.inboundSpacer)
        }
        .padding(.bottom, actionSpacerBetweenRows())
        
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
    
    private func actionSpacerBetweenRows() -> CGFloat {
        if message.actionType == .reply && message.relatedId.isEmpty == false {
            return settings.replySpacing
        } else if message.actionType == .forward && message.relatedId.isEmpty == false {
            return settings.forwardSpacing
        }
        return settings.spacerBetweenRows
    }
    
    fileprivate func applyAIAnswerAssist() {
        let text = message.translatedText.isEmpty == false &&
        showOriginal == false ? message.translatedText : message.text
        var question = Message(message)
        question.text = text
        if let question = question as? MessageItem {
            onAIFeature(.answerAssist, question)
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
                                                   date: Date(), originSenderName: "Bob"),
                                  messagesActionState: .forward,
                                  isSelected: false,
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo(),
                                  onSelect: { (_,_) in})
            .previewDisplayName("Message")
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "Test text Message",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date(), originSenderName: "Bob"),
                                  messagesActionState: .none,
                                  isSelected: false,
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo(),
                                  onSelect: { (_,_) in})
            .previewDisplayName("In Message")
            .preferredColorScheme(.dark)
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "T",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  messagesActionState: .none,
                                  isSelected: false,
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo(),
                                  onSelect: { (_,_) in})
            .previewDisplayName("1")
            
            InboundChatMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message ",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  messagesActionState: .none,
                                  isSelected: false,
                                  onAIFeature: {_,_ in},
                                  aiAnswerWaiting: AIAnswerInfo(),
                                  onSelect: { (_,_) in})
            .previewDisplayName("In Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
