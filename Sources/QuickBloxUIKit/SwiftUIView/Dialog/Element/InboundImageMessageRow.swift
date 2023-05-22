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
    
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogScreen.messageRow.avatar.placeholder
    
    @State public var userName: String?
    
    public init(message: MessageItem,
                onTap: @escaping (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void) {
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
                        do { avatar = try await message.avatar } catch { prettyLog(error) }
                    }
                }.padding(.leading)
            }
            
            VStack(alignment: .leading, spacing: 2) {
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
                
                HStack(spacing: 8) {
                    
                    Button {
                        if let image = fileTuple?.image {
                            onTap(.zoom, image, nil)
                        }
                    } label: {
                        
                        if let image = fileTuple?.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: settings.attachmentSize.width, height: settings.attachmentSize.height)
                                .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                                .padding(settings.inboundPadding(showName: settings.isShowName))
                        } else {
                            
                            ZStack {
                                settings.imageIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: settings.imageIconSize.width,
                                           height: settings.imageIconSize.height)
                                    .foregroundColor(settings.inboundImageIconForeground)
                                
                            }
                            .frame(width: settings.attachmentSize.width, height: settings.attachmentSize.height)
                            .background(settings.inboundBackground)
                            .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                            .padding(settings.inboundPadding(showName: settings.isShowName))
                        }
                    }.disabled(fileTuple?.image == nil)
                        .task {
                            do { fileTuple = try await message.file } catch { prettyLog(error)}
                        }
                    
                    if settings.isShowTime == true {
                        VStack {
                            Spacer()
                            Text("\(message.date, formatter: settings.time.formatter)")
                                .foregroundColor(settings.time.foregroundColor)
                                .font(settings.time.font)
                                .padding(.bottom, settings.time.bottom)
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

//import QuickBloxData
//
//struct InboundImageMessageRow_Previews: PreviewProvider {
//
//    static var previews: some View {
//        Group {
//            InboundImageMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message", userId: NSNumber(value: QBSession.current.currentUserID).stringValue, date: Date()), onTap: { _ in})
//                .previewDisplayName("Message")
//
//            InboundImageMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message", userId: "2d3d4d5d6d", date: Date()), onTap: { _ in})
//                .previewDisplayName("In Message")
//                .preferredColorScheme(.dark)
//        }
//    }
//}
