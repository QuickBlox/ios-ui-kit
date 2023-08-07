//
//  OutboundAudioMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 05.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct OutboundAudioMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    var isPlaying: Bool = false
    
    let onTap: (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, data: Data?, url: URL?, time: TimeInterval)? = nil
    
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
            
            Spacer(minLength: settings.outboundSpacer)
            
            VStack(alignment: .trailing) {
                Spacer()
                HStack(spacing: 3) {
                    
                    MessageRowStatus(message: message)
                    
                    MessageRowTime(date: message.date)
                    
                }.padding(.bottom, 2)
            }
            
            Button {
                play()
            } label: {
                
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    HStack(alignment: .center, spacing: 8) {
                        if fileTuple?.url != nil {
                            
                            MessageRowPlay(isOutbound: true, isPlaying: isPlaying)
                            
                        } else {
                            ProgressView()
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            settings.waveImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: settings.audioImageSize.width, height: settings.audioImageSize.height)
                            
                            Text(fileTuple?.time.audioString() ?? "00:00")
                                .foregroundColor(settings.time.foregroundColor)
                                .font(settings.time.font)
                        }
                    }
                    .padding(settings.audioPadding)
                    .frame(height: settings.audioBubbleHeight)
                    .background(settings.outboundBackground)
                    .cornerRadius(settings.bubbleRadius, corners: settings.outboundCorners)
                    
                }
                .padding(settings.outboundAudioPadding)
            }
            .disabled(fileTuple?.url == nil)
            .task {
                do { fileTuple = try await message.audioFile } catch { prettyLog(error)}
            }
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

import QuickBloxData

struct OutboundAudioMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OutboundAudioMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    onTap: {(_,_,_) in}, playingMessageId: "message.id", isPlaying: true)
            .previewDisplayName("Out Message")
            
            OutboundAudioMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    onTap: { (_,_,_) in}, playingMessageId: "message.id", isPlaying: false)
            .previewDisplayName("Out Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
