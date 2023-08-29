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
    let aiFeatures = QuickBloxUIKit.feature.aiFeature
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var isInfoPresented: Bool = false
    @State private var isAIAlertPresented: Bool = false
    @State private var isAttachmentAlertPresented: Bool = false
    @State private var isImagePresented: Bool = false
    @State private var isSizeAlertPresented: Bool = false
    @State private var isFileExporterPresented = false
    
    @State private var presentedImage: UIImage? = nil
    @State private var videoUrl: URL? = nil
    @State private var fileUrl: URL? = nil
    
    @State private var tappedMessage: ViewModel.DialogItem.MessageItem? = nil
    
    @Binding private var isDialogPresented: Bool
    
    @State private var isNewTyping: Bool = true
    
    public init(viewModel: ViewModel, isDialogPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isDialogPresented = isDialogPresented
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
                                           onTap: { action, image, url  in
                                if message.isImageMessage, let image = image {
                                    DispatchQueue.main.async {
                                        presentedImage = image.toUIImage()
                                        isImagePresented = true
                                        tappedMessage = message
                                    }
                                    
                                } else if message.isGIFMessage, let fileURL = url {
                                    self.fileUrl = fileURL
                                    isFileExporterPresented = true
                                    
                                } else if message.isVideoMessage, let videoUrl = url {
                                    self.videoUrl = videoUrl
                                    isImagePresented = true
                                    tappedMessage = message
                                } else if message.isAttachmentMessage, let fileURL = url {
                                    self.fileUrl = fileURL
                                    isFileExporterPresented = true
                                }
                            }, onPlay: { action, data, url  in
                                if message.isAudioMessage, let data = data {
                                    if action == .play {
                                        viewModel.playAudio(data, action: action)
                                        tappedMessage = message
                                    } else {
                                        viewModel.stopPlayng()
                                        tappedMessage = nil
                                    }
                                }
                            }, onAIFeature: { type, message in
                                if let message, aiFeatures.enable == true {
                                    if type == .answerAssist {
                                        viewModel.applyAIAnswerAssist(message)
                                    } else if type == .translate {
                                        viewModel.applyAITranslate(message)
                                    }
                                } else {
                                    isAIAlertPresented = true
                                }
                            }, waitingTranslation: $viewModel.waitingTranslation)
                            .onAppear {
                                viewModel.handleOnAppear(message)
                            }
                            .offset(y: viewModel.typing.isEmpty == false ? (isNewTyping == true ? 0 : -settings.typing.offset) : -8)
                            
                            .transition(.move(edge: .bottom))
                        }
                    }
                    
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
                        isAttachmentAlertPresented.toggle()
                    }, onApplyTone: { tone, content, needToUpdate in
                        if content.isEmpty == false, aiFeatures.enable == true {
                            viewModel.applyAIRephrase(tone, content: content, needToUpdate: needToUpdate)
                        } else {
                            isAIAlertPresented = true
                        }
                    })
                    .background(settings.backgroundColor)
                    
                    .if(isImagePresented, transform: { view in
                        view.mediaViewerView(isImagePresented: $isImagePresented, image: presentedImage, url: videoUrl ) {
                            videoUrl = nil
                            presentedImage = nil
                            if let tappedMessage {
                                scrollView.scrollTo(tappedMessage.id)
                                self.tappedMessage = nil
                            }
                        }
                    })
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
                .aiFailAlert(isPresented: $isAIAlertPresented)
                .permissionAlert(isPresented: $viewModel.permissionNotGranted.notGranted,
                                 viewModel: viewModel)
                    
                    .modifier(DialogHeader(dialog: viewModel.dialog,
                                           onDismiss: {
                        viewModel.sendStopTyping()
                        viewModel.unsubscribe()
                        viewModel.stopPlayng()
                        dismiss()
                    }, onTapInfo: {
                        viewModel.sendStopTyping()
                        viewModel.stopPlayng()
                        isInfoPresented = true
                    }))
                    
                        .sheet(isPresented: $isFileExporterPresented) {
                    if let fileUrl = fileUrl {
                        ActivityViewController(activityItems: [fileUrl.lastPathComponent , fileUrl])
                    }
                }
            
                .environmentObject(viewModel)
            
            if isInfoPresented == true {
                NavigationLink(isActive: $isInfoPresented) {
                    if let dialog = viewModel.dialog as? Dialog {
                        if viewModel.dialog.type == .group {
                            if viewModel.dialog.isOwnedByCurrentUser == true {
                                GroupDialogInfoView(DialogInfoViewModel(dialog))
                            } else {
                                GroupDialogNonEditInfoView(DialogInfoViewModel(dialog))
                            }
                        } else {
                            PrivateDialogInfoView(DialogInfoViewModel(dialog))
                        }
                    }
                } label: {
                    EmptyView()
                }
            }
        }
    }
    
    public var body: some View {
        container()
            .onAppear {
                viewModel.sync()
            }
            .onDisappear {
                viewModel.sendStopTyping()
                viewModel.unsync()
            }
    }
}
