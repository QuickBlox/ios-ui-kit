//
//  InboundAudioMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 05.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct InboundAudioMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    var isPlaying: Bool = false
    
    let onTap: (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, data: Data?, url: URL?)? = nil
    
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    
    @State public var userName: String?
    
    public init(message: MessageItem,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void,
                playingMessageId: String, isPlaying: Bool) {
        self.message = message
        self.onTap = onTap
        if playingMessageId == message.id {
            self.isPlaying = isPlaying
        }
    }
    
    public var body: some View {
        HStack {
            
            if settings.isShowAvatar == true {
                VStack(spacing: settings.spacing) {
                    Spacer()
                    AvatarView(image: avatar,
                               height: settings.avatar.height,
                               isShow: settings.isShowAvatar)
                    .task {
                        do { avatar = try await message.avatar } catch { prettyLog(error) }
                    }
                }.padding(.leading)
            }
            
            VStack(alignment: .leading, spacing: settings.infoSpacing) {
                Spacer()
                
                if settings.isShowName == true {
                    Text(userName ?? String(message.userId))
                        .foregroundColor(settings.name.foregroundColor)
                        .font(settings.name.font)
                        .padding(settings.inboundNamePadding)
                        .task {
                            do { userName = try await message.userName } catch { prettyLog(error) }
                        }
                }
                
                    VStack(alignment: .leading, spacing: settings.infoSpacing) {
                                 
                        Button {
                            play()
                            
                        } label: {
                            
                            HStack(alignment: .center, spacing: 8) {
                                HStack(alignment: .center, spacing: 8) {
                                    
                                    if isPlaying {
                                        settings.pause
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(settings.playForeground)
                                            .frame(width: settings.audioPlaySize.width, height: settings.audioPlaySize.height)
                                        
                                    } else {
                                        settings.play
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(settings.playForeground)
                                            .frame(width: settings.audioPlaySize.width, height: settings.audioPlaySize.height)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: settings.infoSpacing) {
                                        settings.waveImage
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: settings.audioImageSize.width, height: settings.audioImageSize.height)
                                        
                                        Text("\(message.date, formatter: Date.formatter)")
                                            .foregroundColor(settings.time.foregroundColor)
                                            .font(settings.time.font)
                                    }
                                }
                                .padding(settings.audioPadding)
                                .frame(height: settings.audioBubbleHeight)
                                .background(settings.inboundBackground)
                                .cornerRadius(settings.bubbleRadius, corners: settings.inboundCorners)
                                .padding(settings.inboundPadding(showName: settings.isShowName))
                            }
                        }
                        .disabled(fileTuple?.url == nil)
                        .task {
                            do { fileTuple = try await message.audioFile } catch { prettyLog(error)}
                        }
                        
                        if settings.isShowTime == true {
                            VStack {
                                Spacer()
                                Text("\(message.date, formatter: Date.formatter)")
                                    .foregroundColor(settings.time.foregroundColor)
                                    .font(settings.time.font)
                                    .padding(.bottom, settings.infoSpacing)
                            }
                        }
                }
            }
            Spacer(minLength: settings.inboundSpacer)
            
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
    
    private func play() {
        guard let url = fileTuple?.url, let data = fileTuple?.data else { return }
        if isPlaying == true {
            onTap(.stop, data, url)
        } else {
            onTap(.play, data, url)
        }
    }
}

//import QuickBloxData
//
//struct InboundAudioMessageRow_Previews: PreviewProvider {
//
//    static var previews: some View {
//        Group {
//            InboundAudioMessageRow(message: Message(id: UUID().uuidString,
//                                                    dialogId: "1f2f3ds4d5d6d",
//                                                    text: "[Attachment]",
//                                                    userId: NSNumber(value: QBSession.current.currentUserID).stringValue,
//                                                    date: Date()),
//                                   onTap: { _ in}, playingMessageId: "message.id", isPlaying: true)
//            .previewDisplayName("Out Message")
//
//
//            InboundAudioMessageRow(message: Message(id: UUID().uuidString,
//                                                    dialogId: "1f2f3ds4d5d6d",
//                                                    text: "[Attachment]",
//                                                    userId: "2d3d4d5d6d",
//                                                    date: Date()),
//                                   onTap: { _ in}, playingMessageId: "message.id", isPlaying: false)
//            .previewDisplayName("Out Dark Message")
//            .preferredColorScheme(.dark)
//        }
//    }
//}
