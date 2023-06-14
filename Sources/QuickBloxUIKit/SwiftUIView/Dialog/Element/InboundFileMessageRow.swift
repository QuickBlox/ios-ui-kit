//
//  InboundFileMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct InboundFileMessageRow<MessageItem: MessageEntity>: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    
    @State public var userName: String?
    
    public init(message: MessageItem,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void) {
        self.message = message
        self.onTap = onTap
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
                        do { avatar = try await message.avatar(size: CGSizeMake(settings.avatar.height,
                                                                                settings.avatar.height)) } catch { prettyLog(error) }
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
                
                HStack(alignment: .center, spacing: 8) {
                    Button {
                        if let url = fileTuple?.url {
                            onTap(.save, nil, url)
                        }
                    } label: {
                    
                        HStack(alignment: .center, spacing: 8) {
                            if fileTuple?.url != nil {
                                InboundFilePlaceholder()
                            } else {
                                ProgressView()
                            }
                            if let ext = fileTuple?.url?.pathExtension {
                                Text(settings.fileTitle + "." + ext)
                                    .foregroundColor(settings.message.foregroundColor)
                                    .font(settings.message.font)
                            } else {
                                Text(settings.fileTitle)
                                    .foregroundColor(settings.message.foregroundColor)
                                    .font(settings.message.font)
                            }
                        }
                        .padding(settings.filePadding)
                        .frame(height: settings.fileBubbleHeight)
                        .background(settings.inboundBackground)
                        .cornerRadius(settings.bubbleRadius, corners: settings.inboundCorners)
                        .padding(settings.inboundPadding(showName: settings.isShowName))
                    }
                    .disabled(fileTuple?.url == nil)
                    .task {
                        do { fileTuple = try await message.file(size: nil) } catch { prettyLog(error)}
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
}

private struct InboundFilePlaceholder: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    public var body: some View {
        ZStack {
            settings.inboundFileBackground
                .frame(width: settings.fileSize.width,
                       height: settings.fileSize.height)
                .cornerRadius(settings.attachmentRadius)
            
            settings.file
                .resizable()
                .renderingMode(.template)
                .foregroundColor(settings.inboundFileForeground)
                .scaledToFit()
                .frame(width: settings.fileIconSize.width,
                       height: settings.fileIconSize.height)
        }
    }
}

import QuickBloxData

struct InboundFileMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            InboundFileMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "[Attachment]",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  onTap: { (_,_,_) in})
            .previewDisplayName("Out Message")
            
            
            InboundFileMessageRow(message: Message(id: UUID().uuidString,
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
