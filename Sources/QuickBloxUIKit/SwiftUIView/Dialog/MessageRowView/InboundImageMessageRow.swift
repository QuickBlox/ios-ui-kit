//
//  InboundImageMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog


public struct InboundImageMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    public init(message: MessageItem,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ url: URL?) -> Void) {
        self.message = message
        self.onTap = onTap
    }
    
    public var body: some View {
        
        HStack {
            
            MessageRowAvatar(message: message)
            
            VStack(alignment: .leading, spacing: 0) {
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    
                    Button {
                        if fileTuple?.url != nil {
                            open()
                        }
                    } label: {
                        ZStack {
                            if let image = fileTuple?.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: settings.attachmentSize.width, height: settings.attachmentSize.height)
                                    .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                            } else {
                                settings.progressBarBackground()
                                    .frame(width: settings.attachmentSize.width,
                                           height: settings.attachmentSize.height)
                                    .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                
                                SegmentedCircularBar(settings: settings.progressBar)
                            }
                        }
                    }.task {
                        do {
                            fileTuple = try await message.file(size: settings.imageSize)
                        } catch {
                            prettyLog(error)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            
                            MessageRowTime(date: message.date)
                            
                        }.padding(.bottom, 2)
                    }
                }
            }
            Spacer(minLength: settings.inboundSpacer)
        }
        .padding(.bottom, settings.spacerBetweenRows)
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
    
    private func open() {
        guard let url = fileTuple?.url else { return }
        onTap(.open, url)
    }
}

import QuickBloxData

struct InboundImageMessageRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InboundImageMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "Test text Message",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date()),
                                   onTap: { (_,_) in})
            .previewDisplayName("Message")
            
            InboundImageMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "Test text Message",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date()),
                                   onTap: { (_,_) in})
            .previewDisplayName("In Message")
            .preferredColorScheme(.dark)
        }
    }
}
