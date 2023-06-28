//
//  DialogView.swift
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

public struct DialogView<ViewModel: DialogViewModelProtocol>: View  {
    let settings = QuickBloxUIKit.settings.dialogScreen
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var isInfoPresented: Bool = false
    
    @State private var isAlertPresented: Bool = false
    @State private var isImagePresented: Bool = false
    @State private var isSizeAlertPresented: Bool = false
    
    @State private var presentedImage: Image? = nil
    @State private var videoUrl: URL? = nil
    
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
                                    presentedImage = image
                                    isImagePresented = true
                                    tappedMessage = message
                                } else if message.isGIFMessage, let fileURL = url {
                                    
                                } else if message.isAudioMessage, let url = url {
                                    
                                } else if message.isVideoMessage, let url = url {
                                    self.videoUrl = url
                                    isImagePresented = true
                                    tappedMessage = message
                                } else if message.isAttachmentMessage, let fileURL = url {
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
                            })
                            .offset(y: viewModel.typing.isEmpty == false ? (isNewTyping == true ? 0 : -settings.typing.offset) : 0)
                            .onAppear {
                                viewModel.handleOnAppear(message)
                            }
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
                    
                    if viewModel.typing.isEmpty == false {
                        TypingView(typing: viewModel.typing)
                    }
                    
                    MessageTextField(onSend: { text in
                        viewModel.sendMessage(text)
                    }, onAttachment: {
                        isAlertPresented.toggle()
                    }, onRecord: {
                        viewModel.startRecording()
                    }, onStopRecord: {
                        viewModel.stopRecording()
                    }, onDeleteRecord: {
                        viewModel.deleteRecording()
                    }, onTyping: {
                        viewModel.sendTyping()
                    }, onStopTyping: {
                        viewModel.sendStopTyping()
                    })
                    .background(settings.backgroundColor)
                    
                    .if(isImagePresented, transform: { view in
                        view.mediaViewerView(isImagePresented: $isImagePresented, image: presentedImage, url: videoUrl ) {
                            if let presentedImage {
                                viewModel.saveImage(presentedImage)
                            }
                        } onDismiss: {
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
            
                .mediaAlert(isAlertPresented: $isAlertPresented,
                            isExistingImage: false,
                            isShowFiles: true,
                            mediaTypes: [UTType.movie.identifier, UTType.image.identifier],
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
            
                .modifier(DialogHeader(avatar: $viewModel.avatar,
                                       dialog: viewModel.dialog,
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

public struct TypingView: View {
    let settings = QuickBloxUIKit.settings.dialogScreen
    var typing: String
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(typing)
                    .font(settings.typing.font)
                    .foregroundColor(settings.typing.color)
                    .lineLimit(1)
                
                Spacer()
            }.padding([.leading, .trailing], 8)
            
            Spacer()
        }
        .frame(height: settings.typing.height)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 8)
    }
}

public struct MessagesScrollView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder builder: @escaping ()-> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                    content
                }
                .frame(minWidth: proxy.size.width)
                .frame(minHeight: proxy.size.height)
            }
        }
    }
}

