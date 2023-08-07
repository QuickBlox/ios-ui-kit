//
//  OutboundFileMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct OutboundFileMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
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
            
            Button {
                if let url = fileTuple?.url {
                    
                    onTap(.save, nil, url)
                }
            } label: {
                
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 8) {
                        if fileTuple?.url != nil {
                            OutboundFilePlaceholder()
                        } else {
                            ProgressView()
                        }
                        
                        if let ext = fileTuple?.url?.pathExtension {
                            Text(settings.fileTitle + "." + ext)
                                .foregroundColor(settings.message.outboundForeground)
                                .font(settings.message.font)
                        } else {
                            Text(settings.fileTitle)
                                .foregroundColor(settings.message.outboundForeground)
                                .font(settings.message.font)
                        }
                    }
                    .padding(settings.filePadding)
                    .frame(height: settings.fileBubbleHeight)
                    .background(settings.outboundBackground)
                    .cornerRadius(settings.bubbleRadius, corners: settings.outboundCorners)
                    
                }
                .padding(settings.outboundAudioPadding)
            }.disabled(fileTuple?.url == nil)
                .task {
                    do { fileTuple = try await message.file(size: nil) } catch { prettyLog(error)}
                }
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
}

private struct OutboundFilePlaceholder: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    public var body: some View {
        ZStack {
            settings.outboundFileBackground
                .frame(width: settings.fileSize.width,
                       height: settings.fileSize.height)
                .cornerRadius(settings.attachmentRadius)
            
            settings.file
                .resizable()
                .renderingMode(.template)
                .foregroundColor(settings.outboundFileForeground)
                .scaledToFit()
                .frame(width: settings.fileIconSize.width,
                       height: settings.fileIconSize.height)
        }
    }
}

import QuickBloxData

struct OutboundFileMessageRow_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            OutboundFileMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                   onTap: { (_,_,_) in})
                .previewDisplayName("Out Message")


            OutboundFileMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                   onTap: { (_,_,_) in})
                .previewDisplayName("Out Dark Message")
                .preferredColorScheme(.dark)
        }
    }
}
