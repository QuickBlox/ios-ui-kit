//
//  RepliedMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct RepliedMessageRow<MessageItem: MessageEntity>: View {
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
    
    @State private var contentSize: CGSize?
    
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
            
            if let repliedMessage = message.originalMessages.first {
                if message.isOwnedByCurrentUser == true {
                    
                    OutboundForwardedMessageRowView(message: repliedMessage,
                                                    isSelected: viewModel.selectedMessages.contains(where: { $0.id == repliedMessage.id && $0.relatedId == repliedMessage.relatedId }) == true,
                                                    messagesActionState: viewModel.messagesActionState,
                                                    fileTuple: viewModel.filesInfo[MessageIdsInfo(messageId: repliedMessage.id, relatedId: repliedMessage.relatedId)],
                                                    isPlaying: $viewModel.audioPlayer.isPlaying,
                                                    currentTime: $viewModel.audioPlayer.currentTime,
                                                    playingMessage: MessageIdsInfo(messageId: tappedMessage?.id ?? "", relatedId: tappedMessage?.relatedId ?? ""),
                                                    onTap: { action, url  in
                        if let fileURL = url {
                            attachment = Attachment(id: repliedMessage.id, url: fileURL)
                            if let message = repliedMessage as? MessageItem {
                                tappedMessage = message
                            }                    }
                    }, onPlay: { action, data, url  in
                        if repliedMessage.isAudioMessage, let url = url {
                            if action == .play {
                                viewModel.playAudio(url, action: action, for: MessageIdsInfo(messageId: repliedMessage.id, relatedId: repliedMessage.relatedId))
                                if let message = repliedMessage as? MessageItem {
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
                    }, onAIFeature: { type, message in
                    }, onSelect: { item, actionType in
                        if let message = item as? Message {
                            viewModel.handleOnSelect(message, actionType: actionType)
                        }
                    }, aiAnswerWaiting: $viewModel.waitingAnswer)
                    .onAppear {
                        if let message = repliedMessage as? Message {
                            viewModel.handleOnAppear(message)
                        }
                    }
                } else {
                    InboundForwardedMessageRowView(message: repliedMessage,
                                                   isSelected: viewModel.selectedMessages.contains(where: { $0.id == repliedMessage.id && $0.relatedId == repliedMessage.relatedId }) == true,
                                                   messagesActionState: viewModel.messagesActionState,
                                                   fileTuple: viewModel.filesInfo[MessageIdsInfo(messageId: repliedMessage.id, relatedId: repliedMessage.relatedId)],
                                                   isPlaying: $viewModel.audioPlayer.isPlaying,
                                                   currentTime: $viewModel.audioPlayer.currentTime,
                                                   playingMessage: MessageIdsInfo(messageId: tappedMessage?.id ?? "", relatedId: tappedMessage?.relatedId ?? ""),
                                                   onTap: { action, url  in
                        if let fileURL = url {
                            attachment = Attachment(id: repliedMessage.id, url: fileURL)
                            if let message = repliedMessage as? MessageItem {
                                tappedMessage = message
                            }                    }
                    }, onPlay: { action, data, url  in
                        if repliedMessage.isAudioMessage, let url = url {
                            if action == .play {
                                viewModel.playAudio(url, action: action, for: MessageIdsInfo(messageId: repliedMessage.id, relatedId: repliedMessage.relatedId))
                                if let message = repliedMessage as? MessageItem {
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
                               let messageItem = repliedMessage as? Message {
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
                        if let messageItem = repliedMessage as? Message {
                            viewModel.handleOnAppear(messageItem)
                        }
                    }
                }
            }
            
            if features.reply.enable == true,
               message.actionType == .reply {
                if features.forward.enable == true,
                   viewModel.messagesActionState == .forward {
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
        
        MessageRowView(message: message,
                       isSelected: viewModel.selectedMessages.contains(where: { $0.id == message.id && $0.relatedId == message.relatedId }) == true,
                       messagesActionState: viewModel.messagesActionState,
                       fileTuple: viewModel.filesInfo[MessageIdsInfo(messageId: message.id, relatedId: message.relatedId)],
                       isPlaying: $viewModel.audioPlayer.isPlaying,
                       currentTime: $viewModel.audioPlayer.currentTime,
                       playingMessage: MessageIdsInfo(messageId: tappedMessage?.id ?? "", relatedId: tappedMessage?.relatedId ?? ""),
                       onTap: { action, url  in
            if let fileURL = url {
                attachment = Attachment(id: message.id, url: fileURL)
                tappedMessage = message
            }
        }, onPlay: { action, data, url  in
            if message.isAudioMessage, let url = url {
                if action == .play {
                    viewModel.playAudio(url, action: action, for: MessageIdsInfo(messageId: message.id, relatedId: message.relatedId))
                    tappedMessage = message
                } else if action == .stop {
                    viewModel.stopPlayng()
                    tappedMessage = nil
                } else if action == .save {
                    fileUrl = url
                    isFileExporterPresented = true
                }
            }
        }, onAIFeature: { type, message in
            if type == .answerAssist {
                if features.ai.answerAssist.enable == true,
                   features.ai.answerAssist.isValid == true,
                   let message = message as? Message {
                        viewModel.applyAIAnswerAssist(message)
                } else {
                    aiFeature = .answerAssist
                    isAIAlertPresented = true
                }
            } else if type == .translate {
                if features.ai.translate.enable == true,
                   features.ai.translate.isValid == true,
                   let message = message as? Message {
                    viewModel.applyAITranslate(message)
                } else {
                    aiFeature = .translate
                    isAIAlertPresented = true
                }
            }
        }, onSelect: { item, actionType in
            if let message = item as? Message {
                viewModel.handleOnSelect(message, actionType: actionType)
            }
        }, aiAnswerWaiting: $viewModel.waitingAnswer)
    }
}
