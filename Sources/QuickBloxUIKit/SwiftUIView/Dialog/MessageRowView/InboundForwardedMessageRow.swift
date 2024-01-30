//
//  InboundForwardedMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 14.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct InboundForwardedMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var features = QuickBloxUIKit.feature
    
    @EnvironmentObject var viewModel: DialogViewModel
    
    private var message: MessageItem
    
    @Binding private var aiFeature: AIFeatureType?
    @Binding private var isAIAlertPresented: Bool
    @Binding private var fileUrl: URL?
    @Binding private var isFileExporterPresented: Bool
    @Binding private var tappedMessage: MessageItem?
    @Binding private var attachment: Attachment?

    private var size: CGSize {
        if let contentSize, contentSize.height / contentSize.width > settings.inboundPreviewRatio {
            return settings.inboundPreviewSize
        } else if let contentSize {
            return contentSize
        }
        return .zero
    }
    
    @State private var contentSize: CGSize?
    @State private var showOriginal: Bool = true
    
    public init(message: MessageItem,
                isAIAlertPresented: Binding<Bool>,
                fileUrl: Binding<URL?>,
                aiFeature: Binding<AIFeatureType?>,
                isFileExporterPresented: Binding<Bool>,
                tappedMessage: Binding<MessageItem?>,
                attachment: Binding<Attachment?>
    ) {
        self.message = message
        _isAIAlertPresented = isAIAlertPresented
        _fileUrl = fileUrl
        _aiFeature = aiFeature
        _isFileExporterPresented = isFileExporterPresented
        _tappedMessage = tappedMessage
        _attachment = attachment
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ForEach(message.originalMessages.reversed()) { forwardedMessage in
                InboundForwardedMessageRowView(message: forwardedMessage,
                                               isSelected: viewModel.selectedMessages.contains(where: { $0.id == forwardedMessage.id && $0.relatedId == forwardedMessage.relatedId }) == true,
                                               messagesActionState: viewModel.messagesActionState,
                                               fileTuple: viewModel.filesInfo[MessageIdsInfo(messageId: forwardedMessage.id, relatedId: forwardedMessage.relatedId)],
                                               isPlaying: $viewModel.audioPlayer.isPlaying,
                                               currentTime: $viewModel.audioPlayer.currentTime,
                                               playingMessage: MessageIdsInfo(messageId: tappedMessage?.id ?? "", relatedId: tappedMessage?.relatedId ?? ""),
                                               onTap: { action, url  in
                    if let fileURL = url {
                        attachment = Attachment(id: forwardedMessage.id, url: fileURL)
                        if let message = forwardedMessage as? MessageItem {
                            tappedMessage = message
                        }                    }
                }, onPlay: { action, data, url  in
                    if forwardedMessage.isAudioMessage, let url = url {
                        if action == .play {
                            viewModel.playAudio(url, action: action, for: MessageIdsInfo(messageId: forwardedMessage.id, relatedId: forwardedMessage.relatedId))
                            if let message = forwardedMessage as? MessageItem {
                                tappedMessage = message
                            }
                        } else if action == .stop {
                            viewModel.stopPlayng()
                            tappedMessage = nil
                        } else if action == .save {
                            fileUrl = url
                            isFileExporterPresented = true
                        }
                    }
                }, onAIFeature: { type, item in
                    if type == .answerAssist {
                        if features.ai.answerAssist.enable == true,
                           features.ai.answerAssist.isValid == true,
                           let messageItem = item as? Message {
                                viewModel.applyAIAnswerAssist(messageItem)
                        } else {
                            aiFeature = .answerAssist
                            isAIAlertPresented = true
                        }
                    } else if type == .translate {
                        if features.ai.translate.enable == true,
                           features.ai.translate.isValid == true,
                           let messageItem = item as? Message {
                            viewModel.applyAITranslate(messageItem)
                        } else {
                            aiFeature = .translate
                            isAIAlertPresented = true
                        }
                    }
                }, onSelect: { item, actionType in
                    if let messageItem = item as? Message {
                        viewModel.handleOnSelect(messageItem, actionType: actionType)
                    }
                }, aiAnswerWaiting: $viewModel.waitingAnswer)
                .onAppear {
                    if let messageItem = forwardedMessage as? Message {
                        viewModel.handleOnAppear(messageItem)
                    }
                }
            }
            
            if features.forward.enable == true,
               message.actionType == .forward,
               message.text.isEmpty == false,
               message.text != features.forward.forwardedMessageKey {
                if viewModel.messagesActionState == .forward  {
                    Button {
                        if let message = message as? Message  {
                            viewModel.handleOnSelect(message, actionType: .forward)
                        }
                    } label: {
                        if features.ai.enable == false {
                            forwardMessageView()
                        } else {
                            forwardAiMessageView()
                        }
                    }.buttonStyle(.plain)
                } else {
                    if features.ai.enable == false {
                        forwardMessageView()
                    } else {
                        forwardAiMessageView()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func forwardMessageView() -> some View {
        HStack {
            
            if features.forward.enable == false, viewModel.messagesActionState == .forward {
                Checkbox(isSelected: viewModel.selectedMessages.contains(where: { $0.id == message.id && $0.relatedId == message.relatedId }) == true)
            }
            
            MessageRowAvatar(message: message)
            
            VStack(alignment: .leading, spacing: 0) {
            
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    VStack(alignment: .trailing) {
                        
                        MessageRowText(isOutbound: false, text: message.text)
                            .cornerRadius(settings.bubbleRadius, corners: settings.inboundCorners)
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
                                        if let message = message as? Message {
                                            viewModel.handleOnSelect(message, actionType: .reply)
                                        }
                                    }
                                    CustomContextMenuAction(title: settings.forward.title,
                                                         systemImage: settings.forward.systemImage ?? "", tintColor: settings.forward.color, flipped: .horizontal,
                                                         attributes: features.forward.enable == true
                                                         ? nil : .hidden) {
                                        if let message = message as? Message {
                                            viewModel.handleOnSelect(message, actionType: .forward)
                                        }
                                    }
                                }
                            })
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
        .padding(.bottom, message.actionType == .reply && message.relatedId.isEmpty == false ? 2 : settings.spacerBetweenRows)
        
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
    
    @ViewBuilder
    private func forwardAiMessageView() -> some View {
        HStack {
            
            if features.forward.enable == false, viewModel.messagesActionState == .forward {
                Checkbox(isSelected: viewModel.selectedMessages.contains(where: { $0.id == message.id && $0.relatedId == message.relatedId }) == true)
            }
            
            MessageRowAvatar(message: message)
                .padding(.bottom, features.ai.translate.enable == true ? features.ai.ui.translate.buttonOffset : 0)
            
            VStack(alignment: .leading, spacing: 0) {
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    VStack(alignment: .trailing, spacing: 5) {
                        
                        MessageRowText(isOutbound: false, text: message.translatedText.isEmpty == false && showOriginal == false ? message.translatedText : message.text)
                            .cornerRadius(settings.bubbleRadius, corners: settings.inboundCorners)
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
                                        if let message = message as? DialogViewModel.DialogItem.MessageItem {
                                            viewModel.applyAIAnswerAssist(message)
                                        }
                                    }
                                    CustomContextMenuAction(title: settings.reply.title,
                                                         systemImage: settings.reply.systemImage ?? "", tintColor: settings.reply.color, flipped: UIImageAxis.none,
                                                         attributes: features.reply.enable == true
                                                         ? nil : .hidden) {
                                        if let message = message as? Message {
                                            viewModel.handleOnSelect(message, actionType: .reply)
                                        }
                                    }
                                    CustomContextMenuAction(title: settings.forward.title,
                                                         systemImage: settings.forward.systemImage ?? "", tintColor: settings.forward.color, flipped: .horizontal,
                                                         attributes: features.forward.enable == true
                                                         ? nil : .hidden) {
                                        if let message = message as? Message {
                                            viewModel.handleOnSelect(message, actionType: .forward)
                                        }
                                    }
                                }
                            })
                        
                                if features.ai.translate.enable == true {
                            if features.forward.enable == false, viewModel.messagesActionState == .forward {
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
                                            if let message = message as? DialogViewModel.DialogItem.MessageItem {
                                                viewModel.applyAITranslate(message)
                                            }
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
                    
                    if viewModel.waitingAnswer.relatedId == message.relatedId,
                       viewModel.waitingAnswer.id == message.id,
                       viewModel.waitingAnswer.waiting == true {
                        SegmentedCircularBar(settings: settings.aiProgressBar)
                            .padding(.bottom, features.ai.translate.enable == true ? features.ai.ui.translate.buttonOffset : 0)
                    } else if features.ai.answerAssist.enable == true, features.ai.ui.robot.hidden == false {
                        if features.forward.enable == false, viewModel.messagesActionState == .forward {
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
                                        if let message = message as? DialogViewModel.DialogItem.MessageItem {
                                            viewModel.applyAIAnswerAssist(message)
                                        }
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
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            
                            MessageRowTime(date: message.date)
                            
                        }
                        .padding(.bottom, features.ai.translate.enable == true ? features.ai.ui.translate.buttonOffset + 2 : 2)
                    }
                }
            }
            Spacer(minLength: settings.inboundSpacer)
        }
        .padding(.bottom, message.actionType == .reply && message.relatedId.isEmpty == false ? 2 : settings.spacerBetweenRows)
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
}
