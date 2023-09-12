//
//  PrivateDialogView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog
import UniformTypeIdentifiers
import AVFoundation

public struct PrivateDialogView<ViewModel: DialogViewModelProtocol>: View  {
    let settings = QuickBloxUIKit.settings.dialogScreen
    let aiFeatures = QuickBloxUIKit.feature.ai
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var isInfoPresented: Bool = false
    @State private var isAIAlertPresented: Bool = false
    @State private var isAttachmentAlertPresented: Bool = false
    @State private var isSizeAlertPresented: Bool = false
    @State private var isFileExporterPresented: Bool = false
    
    @State private var attachment: Attachment? = nil
    @State private var fileUrl: URL? = nil
    @State private var aiFeature: AIFeatureType? = nil
    
    @State private var tappedMessage: ViewModel.DialogItem.MessageItem? = nil

    
    @State private var isNewTyping: Bool = true
    
    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            settings.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollViewReader { scrollView in
                    MessagesScrollView() {
                        ForEach(viewModel.dialog.displayedMessages) { message in
                            
                            MessageRowView(message: message,
                                           isPlaying: $viewModel.audioPlayer.isPlaying,
                                           playingMessageId: tappedMessage?.id ?? "",
                                           onTap: { action, url  in
                                if let fileURL = url {
                                    attachment = Attachment(id: message.id, url: fileURL)
                                    tappedMessage = message
                                }
                            }, onPlay: { action, data, url  in
                                if message.isAudioMessage, let data = data {
                                    if action == .play {
                                        viewModel.playAudio(data, action: action)
                                        tappedMessage = message
                                    } else if action == .stop {
                                        viewModel.stopPlayng()
                                        tappedMessage = nil
                                    } else if action == .save {
                                        if let url {
                                            fileUrl = url
                                            isFileExporterPresented = true
                                        }
                                    }
                                }
                            }, onAIFeature: { type, message in
                                if type == .answerAssist {
                                    if aiFeatures.assistAnswer.enable == true,
                                       aiFeatures.assistAnswer.isValid == true {
                                        viewModel.applyAIAnswerAssist(message)
                                    } else {
                                        aiFeature = .answerAssist
                                        isAIAlertPresented = true
                                    }
                                } else if type == .translate {
                                    if aiFeatures.translate.enable == true,
                                       aiFeatures.translate.isValid == true {
                                        viewModel.applyAITranslate(message)
                                    } else {
                                        aiFeature = .translate
                                        isAIAlertPresented = true
                                    }
                                }
                            }, waitingTranslation: $viewModel.waitingTranslation)
                            .onAppear {
                                viewModel.handleOnAppear(message)
                            }
                            .offset(y: viewModel.typing.isEmpty == false ? (isNewTyping == true ? 0 : -settings.typing.offset) : -8)
                            
                            .transition(.move(edge: .bottom))
                        }
                    }
                    .if(settings.backgroundImage != nil, transform: { scrollView in
                        scrollView.background(settings.backgroundImage?
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(settings.backgroundImageColor)
                            .opacity(0.8)
                            .edgesIgnoringSafeArea(.all))
                    })
                    
                    
                    .onChange(of: viewModel.dialog.displayedMessages.count, perform: { newValue in
                        isNewTyping = true
                    })
                    
                    .onChange(of: viewModel.typing.count, perform: { newValue in
                        if newValue == 0 && isNewTyping == true {
                            isNewTyping = false
                        }
                    })
                    
                    .onChange(of: viewModel.targetMessage) { message in
                        if let message = message {
                            viewModel.targetMessage = nil
                            if viewModel.withAnimation == true {
                                withAnimation(.default) {
                                    scrollView.scrollTo(message.id)
                                }
                            } else {
                                scrollView.scrollTo(message.id)
                            }
                        }
                    }
                    
                    if settings.typing.enable == true && viewModel.typing.isEmpty == false {
                        TypingView(typing: viewModel.typing)
                    }
                    
                    InputView(onAttachment: {
                        isAttachmentAlertPresented = true
                    }, onApplyTone: { tone, content, needToUpdate in
                        if content.isEmpty == false,
                           aiFeatures.rephrase.enable == true,
                           aiFeatures.rephrase.isValid == true {
                            viewModel.applyAIRephrase(tone, content: content, needToUpdate: needToUpdate)
                        } else {
                            aiFeature = .rephrase
                            isAIAlertPresented = true
                        }
                    }).disabled(viewModel.isProcessing == true)
                    .background(settings.backgroundColor)
                }
                
                .resignKeyboardOnGesture()
                
            }.background(settings.contentBackgroundColor)
            
                .mediaAlert(isAlertPresented: $isAttachmentAlertPresented,
                            isExistingImage: false,
                            isHiddenFiles: settings.isHiddenFiles,
                            mediaTypes: [UTType.movie.identifier, UTType.image.identifier],
                            viewModel: viewModel,
                            onRemoveImage: {
                    
                }, onGetAttachment: { attachment in
                    let sizeMB = attachment.size
                    if sizeMB.truncate(to: 2) > settings.maximumMB {
                        isSizeAlertPresented = true
                    } else {
                        viewModel.handleOnSelect(attachment: attachment)
                    }
                })
            
                .largeFileSizeAlert(isPresented: $isSizeAlertPresented)
            
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
                                           onDismiss: {
                        viewModel.unsubscribe()
                        dismiss()
                    }, onTapInfo: {
                        isInfoPresented = true
                    }))
            
                    .environmentObject(viewModel)
            
                .if(isInfoPresented == true, transform: { view in
                    view.fullScreenCover(isPresented: $isInfoPresented) {
                        if let dialog = viewModel.dialog as? Dialog {
                            PrivateDialogInfoView(DialogInfoViewModel(dialog))
                        }
                    }
                })
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
