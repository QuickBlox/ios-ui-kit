//
//  OutboundForwardedMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 14.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct OutboundForwardedMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var features = QuickBloxUIKit.feature
    
    @EnvironmentObject var viewModel: DialogViewModel
    
    private var message: MessageItem
    @Binding private var fileUrl: URL?
    @Binding private var isFileExporterPresented: Bool
    @Binding private var tappedMessage: MessageItem?
    @Binding private var attachment: Attachment?
    
    private var size: CGSize {
        if let contentSize, contentSize.height / contentSize.width > settings.outboundPreviewRatio {
            return settings.outboundPreviewSize
        } else if let contentSize {
            return contentSize
        }
        return .zero
    }
    
    @State private var contentSize: CGSize?
    
    public init(message: MessageItem,
                fileUrl: Binding<URL?>,
                isFileExporterPresented: Binding<Bool>,
                tappedMessage: Binding<MessageItem?>,
                attachment: Binding<Attachment?>
    ) {
        self.message = message
        _fileUrl = fileUrl
        _isFileExporterPresented = isFileExporterPresented
        _tappedMessage = tappedMessage
        _attachment = attachment
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            ForEach(self.message.originalMessages.reversed()) { forwardedMessage in
                OutboundForwardedMessageRowView(message: forwardedMessage,
                                                isSelected: viewModel.selectedMessages.contains(where: { $0.id == forwardedMessage.id && $0.relatedId == forwardedMessage.relatedId }) == true,
                                                relatedTime: self.message.originalMessages.reversed().last?.id == forwardedMessage.id ? self.message.date: nil,
                                                relatedStatus: self.message.originalMessages.reversed().last?.id == forwardedMessage.id ? self.message.status : nil,
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
                }, onSelect: { item, actionType in
                    if let message = item as? Message {
                        viewModel.handleOnSelect(message, actionType: actionType)
                    }
                }, aiAnswerWaiting: $viewModel.waitingAnswer)
                .onAppear {
                    if let message = forwardedMessage as? Message {
                        viewModel.handleOnAppear(message)
                    }
                }
            }
            
            if features.forward.enable == true,
               message.actionType == .forward,
               message.text.isEmpty == false,
               message.text != features.forward.forwardedMessageKey {
                if viewModel.messagesActionState == .forward {
                    Button {
                        if let message = message as? Message {
                            viewModel.handleOnSelect(message, actionType: .forward)
                        }
                    } label: {
                        messageView()
                    }.buttonStyle(.plain)
                } else {
                    messageView()
                }
            }
        }
    }
    
    @ViewBuilder
    private func messageView() -> some View {
        HStack {
            
            if features.forward.enable == true,
               viewModel.messagesActionState == .forward {
                Checkbox(isSelected: viewModel.selectedMessages.contains(where: { $0.id == message.id && $0.relatedId == message.relatedId }) == true)
            }
            
            Spacer(minLength: settings.outboundSpacer)
            
            if settings.isHiddenTime == false {
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer()
                    HStack(spacing: 3) {
                        
                        MessageRowStatus(status: message.status)
                        
                        MessageRowTime(date: message.date)
                        
                    }.padding(.bottom, 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                MessageRowText(isOutbound: true, text: message.text)
                    .cornerRadius(settings.bubbleRadius, corners: settings.outboundCorners)
                    .contentSize(onChange: { contentSize in
                        self.contentSize = contentSize
                    })
                    .if(contentSize != nil, transform: { view in
                        view.customContextMenu (
                            preview: MessageRowText(isOutbound: true, text: message.text)
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
            }.padding(settings.outboundPadding)
        }
        .padding(.bottom, message.actionType == .reply && message.relatedId.isEmpty == false ? 2 : settings.spacerBetweenRows)
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
}
