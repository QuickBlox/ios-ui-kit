//
//  ForwardInputView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import AVFoundation
import QBAIRephrase
import QuickBloxLog

struct ForwardInputView: View {
    let textFieldSettings = QuickBloxUIKit.settings.dialogScreen.textField
    let typingSettings = QuickBloxUIKit.settings.dialogScreen.typing
    
    @EnvironmentObject var viewModel: ForwardViewModel
    
    @State private var text: String = ""
    @State public var userName: String = ""
    @FocusState var isFocused: Bool
    
    var body: some View {
        
        VStack {
            
            if viewModel.messages.isEmpty == false,
               let message = viewModel.messages.first {
                MessageActionBanner(userName: $userName,
                                    message: message,
                                    messageAction: .forward,
                                    onCancelReply: {
                    print("on Cancel Reply Action")
                }, forMessage: false, count: viewModel.messages.count)
            }
            
            HStack(spacing: 0) {
                Spacer()
                
                TextFieldView(isDisabled: false,
                              text: $text,
                              typing: {})
                .focused($isFocused)
                .disabled(viewModel.selectedDialogs.isEmpty)
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        if viewModel.syncState == .synced {
                            viewModel.sendMessage(text, originName: userName)
                            text = ""
                        }
                    }) {
                        
                        textFieldSettings.rightButton.image.foregroundColor(textFieldSettings.rightButton.color)
                            .rotationEffect(Angle(degrees: textFieldSettings.rightButton.degrees))
                        
                    }
                    .disabled(viewModel.selectedDialogs.isEmpty)
                    .frame(width: textFieldSettings.rightButton.frame?.width,
                           height: textFieldSettings.rightButton.frame?.height)
                    .padding(.bottom, 8)
                }
            }
        }
        .disabled(viewModel.isProcessing == true)
        .fixedSize(horizontal: false, vertical: true)
        .background(textFieldSettings.backgroundColor)
    }
}

struct MessageActionInfo: View {
    let textFieldSettings = QuickBloxUIKit.settings.dialogScreen.textField
    let messageAction: MessageAction
    let originSenderName: String
    let forMessage: Bool
    
    var body: some View {
        switch messageAction {
        case .forward:
            
            if forMessage == true {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        textFieldSettings.messageActionBanner.forwardedImage
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(textFieldSettings.messageActionBanner.imageColor)
                            .frame(width: textFieldSettings.messageActionBanner.forwardedImageSize.width,
                                   height: textFieldSettings.messageActionBanner.forwardedImageSize.height)
                        Text(textFieldSettings.messageActionBanner.forwardedfrom)
                            .font(textFieldSettings.messageActionBanner.font)
                            .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                            .lineLimit(1)
                    }.frame(height: 16)
                    
                    HStack(spacing: 0) {
                        Text(originSenderName)
                            .font(textFieldSettings.messageActionBanner.font)
                            .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                            .lineLimit(1)
                            .padding(.leading, 3)
                    }.frame(height: 16)
                }
            } else {
                HStack(spacing: 0) {
                    textFieldSettings.messageActionBanner.forwardedImage
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(textFieldSettings.messageActionBanner.imageColor)
                        .frame(width: textFieldSettings.messageActionBanner.forwardedImageSize.width,
                               height: textFieldSettings.messageActionBanner.forwardedImageSize.height)
                    Text(textFieldSettings.messageActionBanner.forwardedfrom)
                        .font(textFieldSettings.messageActionBanner.font)
                        .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                        .lineLimit(1)
                    Text(originSenderName)
                        .font(textFieldSettings.messageActionBanner.font)
                        .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                        .lineLimit(1)
                        .padding(.leading, 3)
                }.frame(height: 16)
            }
            
        case .none:
            EmptyView()
        case .reply:
            
            if forMessage == true {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        textFieldSettings.messageActionBanner.replyImage
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(textFieldSettings.messageActionBanner.imageColor)
                            .frame(width: textFieldSettings.messageActionBanner.replyImageSize.width,
                                   height: textFieldSettings.messageActionBanner.replyImageSize.height)
                        Text(textFieldSettings.messageActionBanner.repliedTo)
                            .font(textFieldSettings.messageActionBanner.font)
                            .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                            .lineLimit(1)
                            .padding(.leading, 4)
                    }
                    
                    HStack(spacing: 0) {
                        Text(originSenderName)
                            .font(textFieldSettings.messageActionBanner.font)
                            .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                            .lineLimit(1)
                            .padding(.leading, 3)
                    }.frame(height: 16)
                }
            } else {
                HStack(spacing: 0) {
                    textFieldSettings.messageActionBanner.replyImage
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(textFieldSettings.messageActionBanner.imageColor)
                        .frame(width: textFieldSettings.messageActionBanner.replyImageSize.width,
                               height: textFieldSettings.messageActionBanner.replyImageSize.height)
                    Text(textFieldSettings.messageActionBanner.repliedTo)
                        .font(textFieldSettings.messageActionBanner.font)
                        .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                        .lineLimit(1)
                        .padding(.leading, 4)
                    Text(originSenderName)
                        .font(textFieldSettings.messageActionBanner.font)
                        .foregroundColor(textFieldSettings.messageActionBanner.foregroundColor)
                        .lineLimit(1)
                        .padding(.leading, 3)
                }.frame(height: 16)
            }
        }
    }
}


struct MessageActionBanner<MessageItem: MessageEntity>: View {
    let textFieldSettings = QuickBloxUIKit.settings.dialogScreen.textField
    
    @State public var fileTuple: (type: String, image: UIImage?, url: URL?)? = nil
    @Binding var userName: String
    
    let message: MessageItem
    let messageAction: MessageAction
    let onCancelReply: () -> Void
    let forMessage: Bool
    
    let count: Int
    
    var body: some View {
        HStack(spacing: 8) {
            
            if let attachmentPlaceholder = message.attachmentPlaceholder {
                if message.isAudioMessage == false, let image = fileTuple?.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: textFieldSettings.messageActionBanner.attachmentSize.width,
                               height: textFieldSettings.messageActionBanner.attachmentSize.height)
                        .cornerRadius(textFieldSettings.messageActionBanner.imageCornerRadius)
                } else {
                    ZStack {
                        textFieldSettings.messageActionBanner.placeholderBackground
                            .frame(width: textFieldSettings.messageActionBanner.attachmentSize.width,
                                   height: textFieldSettings.messageActionBanner.attachmentSize.height)
                            .cornerRadius(textFieldSettings.messageActionBanner.imageCornerRadius)
                        
                        attachmentPlaceholder
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(textFieldSettings.messageActionBanner.placeholderForeground)
                            .scaledToFit()
                            .frame(width: textFieldSettings.messageActionBanner.placeholderSize.width,
                                   height: textFieldSettings.messageActionBanner.placeholderSize.height)
                    }
                }
            }
            
            VStack(spacing: 4) {
                HStack {
                    MessageActionInfo(messageAction: messageAction, originSenderName: userName.isEmpty == false ? userName : "Name", forMessage: forMessage)
                        .if(userName.isEmpty, transform: { view in
                            view
                                .task {
                                    do { userName = try await message.userName } catch { prettyLog(error) }
                                }
                        })
                            Spacer()
                }
                
                if count > 1 {
                    HStack {
                        Text("\(count) messages")
                        Spacer()
                    }
                } else {
                    HStack {
                        if message.isText {
                            Text(message.text)
                                .lineLimit(1)
                                .font(textFieldSettings.messageActionBanner.bodyFont)
                                .foregroundColor(textFieldSettings.messageActionBanner.bodyForeground)
                            
                        } else {
                            Text(fileTuple?.type ?? "file")
                                .foregroundColor(textFieldSettings.messageActionBanner.attachmentForeground)
                                .font(textFieldSettings.messageActionBanner.attachmentFont)
                        }
                        Spacer()
                    }
                }
            }
            
            if messageAction == .reply {
                Button {
                    onCancelReply()
                } label: {
                    textFieldSettings.messageActionBanner.replyCancelButton.image
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(textFieldSettings.messageActionBanner.replyCancelButton.color)
                        .scaledToFit()
                        .frame(width: textFieldSettings.messageActionBanner.replyCancelButton.imageSize?.width,
                               height: textFieldSettings.messageActionBanner.replyCancelButton.imageSize?.height)
                }
                .frame(width: textFieldSettings.messageActionBanner.replyCancelButton.width,
                       height: textFieldSettings.messageActionBanner.replyCancelButton.height)
            }
        }
        .padding(.horizontal)
        .frame(height: textFieldSettings.messageActionBanner.height)
        .frame(maxWidth: .infinity)
        .background(textFieldSettings.backgroundColor)
        .if(fileTuple == nil, transform: { view in
            view.task {
                do { fileTuple = try await message.file(size: textFieldSettings.messageActionBanner.attachmentSize) } catch { prettyLog(error)}
            }
        })
    }
}
