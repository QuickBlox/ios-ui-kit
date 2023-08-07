//
//  OutboundVideoMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 07.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog


public struct OutboundVideoMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    @State private var isPlaying: Bool = false
    
    @State private var progress: CGFloat = 0.5
    
    public init(message: MessageItem,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void) {
        self.message = message
        self.onTap = onTap
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
                
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    
                    Button {
                        play()
                    } label: {
                    
                    ZStack {
                        
                        if let image = fileTuple?.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: settings.attachmentSize.width,
                                       height: settings.attachmentSize.height)
                                .cornerRadius(settings.attachmentRadius,
                                              corners: settings.outboundCorners)
                                .padding(settings.outboundPadding)

                            settings.videoPlayBackground
                                .frame(width: settings.imageIconSize.width,
                                       height: settings.imageIconSize.height)
                                .cornerRadius(6)

                            settings.play
                                .resizable()
                                .scaledToFit()
                                .frame(width: settings.videoIconSize(isImage: true).width,
                                       height: settings.videoIconSize(isImage: true).height)
                                .foregroundColor(settings.videoPlayForeground)
                            
                        } else {
                            
                            if progress > 0 {
                                
                                settings.progressBarBackground()
                                    .frame(width: settings.attachmentSize.width,
                                           height: settings.attachmentSize.height)
                                    .cornerRadius(settings.attachmentRadius,
                                                  corners: settings.outboundCorners)
                                    .padding(settings.outboundPadding)
                                
                                SegmentedCircularProgressBar(progress: $progress)
                                    .padding([.top, .trailing])
                                
                            } else {
                                
                                settings.outboundBackground
                                    .frame(width: settings.attachmentSize.width,
                                           height: settings.attachmentSize.height)
                                    .cornerRadius(settings.attachmentRadius,
                                                  corners: settings.outboundCorners)
                                    .padding(settings.outboundPadding)
                                
                                settings.play
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: settings.videoIconSize(isImage: false).width,
                                           height: settings.videoIconSize(isImage: false).height)
                                    .foregroundColor(settings.outboundImageIconForeground)
                                .padding(.top)
                            }
                        }
                    }
                    .task {
                        do { fileTuple = try await message.file(size: settings.imageSize) } catch { prettyLog(error)}
                    }
                    }.disabled(fileTuple?.url == nil)
                        
            }
            }
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
        
    }
    
    private func play() {
        guard let url = fileTuple?.url else { return }
        if isPlaying == true {
            onTap(.stop, nil, url)
        } else {
            onTap(.play, nil, url)
        }
    }
}

import QuickBloxData

struct OutboundVideoMessageRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            OutboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    onTap: { (_,_,_) in})
            .previewDisplayName("Video with Thumbnail")

            OutboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    onTap: { (_,_,_) in})
            .previewDisplayName("Video without Thumbnail")

            OutboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    onTap: { (_,_,_) in})
            .previewDisplayName("Video without Thumbnail")
            .preferredColorScheme(.dark)

            OutboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    onTap: { (_,_,_) in})
            .previewDisplayName("Video with Thumbnail")
            .preferredColorScheme(.dark)
        }
    }
}
