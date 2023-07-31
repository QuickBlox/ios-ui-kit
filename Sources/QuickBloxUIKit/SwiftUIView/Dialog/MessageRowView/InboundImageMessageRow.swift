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
    
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    @State private var progress: CGFloat = 0.5
    
    public init(message: MessageItem,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void) {
        self.message = message
        self.onTap = onTap
    }
    
    public var body: some View {
        
        HStack {
            
            MessageRowAvatar(message: message)
            
            VStack(alignment: .leading, spacing: 2) {
                Spacer()
                
                MessageRowName(message: message)
                
                HStack(spacing: 8) {
                    
                    Button {
                        if let image = fileTuple?.image {
                            openImage(image)
                        }
                    } label: {
                        ZStack {
                            if let image = fileTuple?.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: settings.attachmentSize.width, height: settings.attachmentSize.height)
                                    .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                    .padding(settings.inboundPadding(showName: settings.isHiddenName))
                            } else {
                                
                                if progress > 0 {
                                    
                                    settings.progressBarBackground()
                                        .frame(width: settings.attachmentSize.width,
                                               height: settings.attachmentSize.height)
                                        .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                        .padding(settings.inboundPadding(showName: settings.isHiddenName))
                                    
                                    SegmentedCircularProgressBar(progress: $progress)
                                    
                                } else {
                                    
                                    settings.inboundBackground
                                        .frame(width: settings.attachmentSize.width,
                                               height: settings.attachmentSize.height)
                                        .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                        .padding(settings.inboundPadding(showName: settings.isHiddenName))
                                    
                                    settings.imageIcon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: settings.imageIconSize.width,
                                               height: settings.imageIconSize.height)
                                        .foregroundColor(settings.inboundImageIconForeground)
                                }
                            }
                        }
                    }.disabled(fileTuple?.image == nil)
                        .task {
                            do { fileTuple = try await message.file(size: settings.imageSize) } catch { prettyLog(error)}
                        }
                    
                    MessageRowTime(date: message.date)
                }
            }
            Spacer(minLength: settings.inboundSpacer)
        }
        .fixedSize(horizontal: false, vertical: true)
        .id(message.id)
    }
    
    private func openImage(_ placeholder: Image) {
        Task {
            do {
                let file = try await message.file(size: nil)
                guard let image = file?.image else {
                    onTap(.zoom, placeholder, nil)
                    return
                }
                onTap(.zoom, image, nil)
            }
            catch {
                prettyLog(error)
            }
        }
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
                                   onTap: { (_,_,_) in})
            .previewDisplayName("Message")
            
            InboundImageMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "Test text Message",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date()),
                                   onTap: { (_,_,_) in})
            .previewDisplayName("In Message")
            .preferredColorScheme(.dark)
        }
    }
}
