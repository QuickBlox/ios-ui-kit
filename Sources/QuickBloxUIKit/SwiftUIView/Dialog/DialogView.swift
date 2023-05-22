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

public struct DialogView<ViewModel: DialogViewModelProtocol>: View  {
    var settings = QuickBloxUIKit.settings.dialogScreen
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    
    @State private var isInfoPresented: Bool = false
    
    @State private var isAlertPresented: Bool = false
    @State private var isImagePresented: Bool = false
    @State private var isSizeAlertPresented: Bool = false
    
    @State private var presentedImage: Image? = nil
    @State private var videoUrl: URL? = nil
    
    @State private var tappedMessage: ViewModel.DialogItem.MessageItem? = nil
    
    @State public var avatar: Image?
    
    @Binding private var isDialogPresented: Bool
    
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
                                    self.presentedImage = image
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
                            .transition(.move(edge: .bottom))
                        }
                    }
                    
                    .onChange(of: isDialogPresented) { newValue in
                        if newValue == false {
                            isInfoPresented = false
                            dismiss()
                        }
                    }
                    
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
                        VStack(alignment: .leading) {
                            HStack {
                                Text(viewModel.typing)
                                    .font(settings.typing.font)
                                    .foregroundColor(settings.typing.color)
                                    .lineLimit(1)
                                
                                Spacer()
                            }.padding([.leading, .trailing], 8)
                            
                            Spacer()
                        }.frame(height: settings.typing.height)
                    }
                    
                    MessageTextField(onSend: {
                        viewModel.sendMessage()
                    }, onAttachment: {
                        isAlertPresented.toggle()
                    }, onRecord: {
                        viewModel.startRecording()
                    }, onStopRecord: {
                        viewModel.stopRecording()
                    }, onDeleteRecord: {
                        viewModel.deleteRecording()
                    }, text: $viewModel.text)
                    .background(settings.backgroundColor)
                    
                    .if(isImagePresented, transform: { view in
                        
                        view.mediaViewerView(isImagePresented: $isImagePresented, image: presentedImage, url: videoUrl ) {
                            if let presentedImage {
                                viewModel.saveImage(presentedImage)
                            }
                        } onDismiss: {
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
            
            .modifier(DialogHeader(avatar: avatar ?? viewModel.dialog.placeholder,
                                   name: viewModel.dialog.name,
                                   onDismiss: {
                viewModel.stopPlayng()
                dismiss()
            }, onTapInfo: {
                viewModel.stopPlayng()
                isInfoPresented = true
            }))
            .task {
                do { avatar = try await viewModel.dialog.avatar } catch { prettyLog(error) }
            }
        }
    }
    
    public var body: some View {
        container()
            .onAppear {
                viewModel.sync()
            }
            .onDisappear {
                viewModel.unsync()
            }
            .fullScreenCover(isPresented: $isInfoPresented) {
                if let dialog = viewModel.dialog as? Dialog {
                    if viewModel.dialog.type == .group {
                        GroupDialogInfoView(DialogInfoViewModel(dialog))
                    } else {
                        PrivateDialogInfoView(DialogInfoViewModel(dialog))
                    }
                }
            }
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
