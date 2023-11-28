//
//  GroupDialogView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 15.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog
import UniformTypeIdentifiers
import AVFoundation
import UIKit

public struct Attachment: Identifiable {
    public let id: String
    let url: URL
}

public struct GroupDialogView<ViewModel: DialogViewModelProtocol>: View {
    let settings = QuickBloxUIKit.settings.dialogScreen
    let connectStatus = QuickBloxUIKit.settings.dialogsScreen.connectStatus
    let features = QuickBloxUIKit.feature
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var isInfoPresented: Bool = false
    @State private var isForwardPresented: Bool = false
    @State private var isForwardSuccess: Bool = false
    @State private var isAIAlertPresented: Bool = false
    @State private var isAttachmentAlertPresented: Bool = false
    @State private var isSizeAlertPresented: Bool = false
    @State private var isFileExporterPresented: Bool = false
    @State private var isInvalidExtAlertPresented: Bool = false
    @State private var isAiAnswerFailedPresented: Bool = false
    
    @State private var attachment: Attachment? = nil
    @State private var fileUrl: URL? = nil
    @State private var aiFeature: AIFeatureType? = nil
    
    @State private var attachmentAsset: AttachmentAsset? = nil
    
    @State private var tappedMessage: ViewModel.DialogItem.MessageItem? = nil
    
    let onDismiss: () -> Void
    
    public init(viewModel: ViewModel,
                onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                switch viewModel.syncState {
                case .syncing(stage: let stage, error: _):
                    VStack {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text(" " + connectStatus.connectionText(stage.rawValue) )
                                .foregroundColor(settings.connectForeground)
                        }.padding(.top)
                        if viewModel.dialog.displayedMessages.isEmpty {
                            Spacer()
                        } else {
                            messagesView()
                        }
                    }
                case .synced:
                    VStack(spacing: 20) {
                        
                        if viewModel.isProcessing {
                            HStack(spacing: 12) {
                                ProgressView()
                                Text(" " + connectStatus.connectionText(connectStatus.update) )
                                    .foregroundColor(settings.connectForeground)
                            }.padding(.top)
                        }
                        
                        aiAnswerFiled(viewModel.aiAnswerFailed.feature)
                        if viewModel.dialog.displayedMessages.isEmpty {
                            Spacer()
                        } else {
                            messagesView()
                        }
                        if settings.typing.enable == true && viewModel.typing.isEmpty == false {
                            TypingView(typing: viewModel.typing)
                                .animation(.easeInOut, value: viewModel.typing.isEmpty)
                        }
                    }
                }
                
                if features.forward.enable == true, viewModel.messagesActionState == .forward {
                    Button {
                        isForwardPresented = true
                    } label: {
                        Text(settings.messageRow.forward.title)
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(settings.textField.backgroundColor)
                    .overlay(Divider(), alignment: .top)
                } else {
                    InputView(onAttachment: {
                        isAttachmentAlertPresented = true
                    }, onApplyTone: { tone, content, needToUpdate in
                        if content.isEmpty == false,
                           features.ai.rephrase.enable == true,
                           features.ai.rephrase.isValid == true {
                            viewModel.applyAIRephrase(tone,
                                                      text: content,
                                                      needToUpdate: needToUpdate)
                        } else {
                            aiFeature = .rephrase
                            isAIAlertPresented = true
                        }
                    })
                    .background(settings.backgroundColor)
                }
            }
            .background {
                ZStack {
                    settings.contentBackgroundColor
                    if settings.backgroundImage != nil {
                        settings.backgroundImage?
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(settings.backgroundImageColor)
                            .opacity(0.8)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
            }
            
            .mediaAlert(isAlertPresented: $isAttachmentAlertPresented,
                        isExistingImage: false,
                        isHiddenFiles: settings.isHiddenFiles,
                        mediaTypes: [.videos, .images],
                        viewModel: viewModel,
                        onRemoveImage: {
            }, onGetAttachment: { attachmentAsset in
                let sizeMB = attachmentAsset.size
                if sizeMB.truncate(to: 2) > settings.maximumMB {
                    if attachmentAsset.image != nil {
                        self.attachmentAsset = attachmentAsset
                    }
                    isSizeAlertPresented = true
                } else {
                    viewModel.handleOnSelect(attachment: attachmentAsset)
                }
            })
            
            .onChange(of: viewModel.error, perform: { error in
                if error == settings.invalidFile {
                    isInvalidExtAlertPresented = true
                }
            })
            
            .onChange(of: viewModel.aiAnswerFailed.failed, perform: { failed in
                withAnimation(.easeInOut(duration: failed ? 0.4 : 0.8)) {
                    isAiAnswerFailedPresented = failed
                }
            })
            
            .invalidExtensionAlert(isPresented: $isInvalidExtAlertPresented)
            
            .if(attachmentAsset == nil && isSizeAlertPresented == true, transform: { view in
                view.largeFileSizeAlert(isPresented: $isSizeAlertPresented)
            })
                
                .if(attachmentAsset != nil && isSizeAlertPresented == true, transform: { view in
                    view.largeImageSizeAlert(isPresented: $isSizeAlertPresented,
                                             onUseAttachment: {
                        if let attachmentAsset {
                            viewModel.handleOnSelect(attachment: attachmentAsset)
                            self.attachmentAsset = nil
                        }
                    }, onCancel: {
                        self.attachmentAsset = nil
                    })
                })
                
                    .if(isAIAlertPresented == true && aiFeature != nil, transform: { view in
                        view.aiFailAlert(isPresented: $isAIAlertPresented,
                                         feature: aiFeature ?? AIFeatureType.answerAssist,
                                         onDismiss: {
                            aiFeature = nil
                        })
                    })
                
                        .permissionAlert(isPresented: $viewModel.permissionNotGranted.notGranted,
                                         viewModel: viewModel)
                
                            .fullScreenCover(item: $attachment, content: { attachment in
                                FilePreviewController(url: attachment.url, onDismiss: {
                                    self.attachment = nil
                                })
                            })
                
                                .sheet(isPresented: $isFileExporterPresented, onDismiss: {
                                    attachment = nil
                                }, content: {
                                    if let fileUrl {
                                        ActivityViewController(activityItems: [fileUrl])
                                    }
                                })
                
                                    .modifier(DialogHeader(dialog: viewModel.dialog,
                                                           isForward: viewModel.messagesActionState == .forward,
                                                           selectedCount: viewModel.selectedMessages.count,
                                                           onDismiss: {
                                        dismiss()
                                        onDismiss()
                                    }, onTapInfo: {
                                        isInfoPresented = true
                                    }, onTapCancel: {
                                        viewModel.cancelMessageAction()
                                    }))
                
                                        .environmentObject(viewModel)
                
                                        .if(isInfoPresented == true, transform: { view in
                                            view.navigationDestination(isPresented: $isInfoPresented) {
                                                if let dialog = viewModel.dialog as? Dialog {
                                                    if dialog.isOwnedByCurrentUser == true {
                                                        GroupDialogInfoView(DialogInfoViewModel(dialog))
                                                    } else {
                                                        GroupDialogNonEditInfoView(DialogInfoViewModel(dialog))
                                                    }
                                                }
                                            }
                                        })
                                            .if(isForwardSuccess == true, transform: { view in
                                                view.forwardSuccessAlert(isPresented: $isForwardSuccess, name: viewModel.dialog.name)
                                            })
                
                                            .if(isForwardPresented == true, transform: { view in
                                                view.navigationDestination(isPresented: $isForwardPresented) {
                                                    ForwardView(viewModel: ForwardViewModel(messages: viewModel.selectedMessages as? [Message] ?? [],
                                                                                            originSenderName: viewModel.dialog.name),
                                                                onForwardSuccess: {
                                                        viewModel.cancelMessageAction()
                                                        isForwardSuccess = true
                                                    })
                                                }
                                            })
        }
    }
    
    @ViewBuilder
    private func messagesView() -> some View {
        ScrollViewReader { scrollView in
            MessagesScrollView() {
                ForEach(viewModel.dialog.displayedMessages.reversed()) { message in
                    
                    if features.forward.enable == true && message.actionType == .forward,
                       message.originalMessages.isEmpty == false {
                        if message.isOwnedByCurrentUser == true {
                            OutboundForwardedMessageRow(message: message,
                                                        fileUrl: $fileUrl,
                                                        isFileExporterPresented: $isFileExporterPresented,
                                                        tappedMessage: $tappedMessage,
                                                        attachment: $attachment)
                            .onAppear {
                                viewModel.handleOnAppear(message)
                            }
                        } else {
                            InboundForwardedMessageRow(message: message,
                                                       isAIAlertPresented: $isAIAlertPresented,
                                                       fileUrl: $fileUrl,
                                                       aiFeature: $aiFeature,
                                                       isFileExporterPresented: $isFileExporterPresented,
                                                       tappedMessage: $tappedMessage,
                                                       attachment: $attachment)
                            .onAppear {
                                viewModel.handleOnAppear(message)
                            }
                        }
                    } else if features.reply.enable == true && message.actionType == .reply,
                       message.originalMessages.isEmpty == false {
                        RepliedMessageRow(message: message,
                                                   isAIAlertPresented: $isAIAlertPresented,
                                                   fileUrl: $fileUrl,
                                                   aiFeature: $aiFeature,
                                                   isFileExporterPresented: $isFileExporterPresented,
                                                   tappedMessage: $tappedMessage,
                                                   attachment: $attachment)
                        .onAppear {
                            viewModel.handleOnAppear(message)
                        }
                    } else {
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
                                   features.ai.answerAssist.isValid == true {
                                    viewModel.applyAIAnswerAssist(message)
                                } else {
                                    aiFeature = .answerAssist
                                    isAIAlertPresented = true
                                }
                            } else if type == .translate {
                                if features.ai.translate.enable == true,
                                   features.ai.translate.isValid == true {
                                    viewModel.applyAITranslate(message)
                                } else {
                                    aiFeature = .translate
                                    isAIAlertPresented = true
                                }
                            }
                        }, onSelect: { item, actionType in
                            viewModel.handleOnSelect(item, actionType: actionType)
                        }, aiAnswerWaiting: $viewModel.waitingAnswer)
                        .onAppear {
                            viewModel.handleOnAppear(message)
                        }
                    }
                }
            }
        }
        
        .scrollDismissesKeyboard(.interactively)
    }
    
    @ViewBuilder
    private func aiAnswerFiled(_ feature: AIFeatureType) -> some View {
        if viewModel.aiAnswerFailed.failed {
            Text(feature.answerFailed)
                .font(features.ai.ui.answerFailed.font)
                .foregroundColor(features.ai.ui.answerFailed.foreground)
                .padding(features.ai.ui.answerFailed.padding)
                .frame(height: isAiAnswerFailedPresented ? 24 : nil)
                .background(Capsule().fill(features.ai.ui.answerFailed.background))
                .padding(.top, isAiAnswerFailedPresented ? 16 : 0)
                .offset(y: isAiAnswerFailedPresented ? 10 : -20)
        } else {
            EmptyView()
        }
    }
    
    public var body: some View {
        container()
            .onAppear {
                viewModel.sync()
            }
            .onDisappear {
                viewModel.sendStopTyping()
                viewModel.stopPlayng()
                viewModel.unsync()
                isInfoPresented = false
            }
    }
}
