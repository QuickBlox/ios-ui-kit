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

struct Attachment: Identifiable {
    let id: String
    let url: URL
}

public struct GroupDialogView<ViewModel: DialogViewModelProtocol>: View {
    let settings = QuickBloxUIKit.settings.dialogScreen
    let connectStatus = QuickBloxUIKit.settings.dialogsScreen.connectStatus
    let aiFeatures = QuickBloxUIKit.feature.ai
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var isInfoPresented: Bool = false
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
    @State private var isNewTyping: Bool = true
    
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
                        aiAnswerFiled(viewModel.aiAnswerFailed.feature)
                        if viewModel.dialog.displayedMessages.isEmpty {
                            Spacer()
                        } else {
                            messagesView()
                        }
                    }
                }
                
                InputView(onAttachment: {
                    isAttachmentAlertPresented = true
                }, onApplyTone: { tone, content, needToUpdate in
                    if content.isEmpty == false,
                       aiFeatures.rephrase.enable == true,
                       aiFeatures.rephrase.isValid == true {
                        viewModel.applyAIRephrase(tone, text: content, needToUpdate: needToUpdate)
                    } else {
                        aiFeature = .rephrase
                        isAIAlertPresented = true
                    }
                }).disabled(viewModel.isProcessing == true)
                    .background(settings.backgroundColor)
                
            }
            .background(
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
            )
            
            .mediaAlert(isAlertPresented: $isAttachmentAlertPresented,
                        isExistingImage: false,
                        isHiddenFiles: settings.isHiddenFiles,
                        mediaTypes: [UTType.movie.identifier, UTType.image.identifier],
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
            
            .onChange(of: viewModel.typing.count, perform: { newValue in
                if newValue == 0 && isNewTyping == true {
                    isNewTyping = false
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
                                                           onDismiss: {
                                        viewModel.unsubscribe()
                                        dismiss()
                                        onDismiss()
                                    }, onTapInfo: {
                                        isInfoPresented = true
                                    }))
                
                                        .environmentObject(viewModel)
                
                                        .if(isInfoPresented == true, transform: { view in
                                            view.fullScreenCover(isPresented: $isInfoPresented) {
                                                if let dialog = viewModel.dialog as? Dialog {
                                                    if dialog.isOwnedByCurrentUser == true {
                                                        GroupDialogInfoView(DialogInfoViewModel(dialog))
                                                    } else {
                                                        GroupDialogNonEditInfoView(DialogInfoViewModel(dialog))
                                                    }
                                                }
                                            }
                                        })
        }
    }
    
    @ViewBuilder
    private func aiAnswerFiled(_ feature: AIFeatureType) -> some View {
        if viewModel.aiAnswerFailed.failed {
            Text(feature.answerFailed)
                .font(aiFeatures.ui.answerFailed.font)
                .foregroundColor(aiFeatures.ui.answerFailed.foreground)
                .padding(aiFeatures.ui.answerFailed.padding)
                .frame(height: isAiAnswerFailedPresented ? 24 : nil)
                .background(Capsule().fill(aiFeatures.ui.answerFailed.background))
                .padding(.top, isAiAnswerFailedPresented ? 16 : 0)
                .offset(y: isAiAnswerFailedPresented ? 10 : -20)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func messagesView() -> some View {
        ScrollViewReader { scrollView in
            MessagesScrollView() {
                ForEach(viewModel.dialog.displayedMessages) { message in
                    MessageRowView(message: message,
                                   isPlaying: $viewModel.audioPlayer.isPlaying,
                                   currentTime: $viewModel.audioPlayer.currentTime,
                                   playingMessageId: tappedMessage?.id ?? "",
                                   onTap: { action, url  in
                        if let fileURL = url {
                            attachment = Attachment(id: message.id, url: fileURL)
                            tappedMessage = message
                        }
                    }, onPlay: { action, data, url  in
                        if message.isAudioMessage, let url = url {
                            if action == .play {
                                viewModel.playAudio(url, action: action)
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
                            if aiFeatures.answerAssist.enable == true,
                               aiFeatures.answerAssist.isValid == true {
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
                    }, aiAnswerWaiting: $viewModel.waitingAnswer)
                    .onAppear {
                        viewModel.handleOnAppear(message)
                    }
                    .offset(y:offset(typing: viewModel.typing.isEmpty == false,
                                     isOwnLast: viewModel.targetMessage?.isOwnedByCurrentUser == true))
                    .animation(.easeInOut, value: viewModel.typing.isEmpty)
                }
            }
                
                .onChange(of: viewModel.targetMessage) { message in
                if let message = message {
                    isNewTyping = true
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
        }
        
        .gesture(DragGesture().onChanged { gesture in
            if (gesture.location.y < gesture.predictedEndLocation.y) {
                UIApplication.shared.endEditing(true)
                isNewTyping = false
            }
        })
    }
    
    private func offset(typing: Bool, isOwnLast: Bool) -> CGFloat {
        return typing == true ? (isNewTyping == true ? -settings.typing.defaultOffset
                                 : -settings.typing.offset(isOwner: isOwnLast))
        : -settings.typing.defaultOffset
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
