//
//  OutboundImageMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct OutboundImageMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    public init(message: MessageItem,
                onTap: @escaping (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void) {
        self.message = message
        self.onTap = onTap
    }
    
    public var body: some View {
        
        
            
            HStack {
                
                Spacer(minLength: settings.outboundSpacer)
                
                VStack(alignment: .trailing) {
                    Spacer()
                    HStack(spacing: 3) {
                        message.statusImage
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(message.statusForeground)
                            .scaledToFit()
                            .frame(width: 10, height: 5)
                        Text("\(message.date, formatter: Date.formatter)")
                            .foregroundColor(settings.time.foregroundColor)
                            .font(settings.time.font)
                    }.padding(.bottom, 2)
                }
                
                
                Button {
                    if let image = fileTuple?.image {
                        onTap(.zoom, image, nil)
                    }
                } label: {
                
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    
                    if let image = fileTuple?.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: settings.attachmentSize.width, height: settings.attachmentSize.height)
                            .cornerRadius(settings.attachmentRadius, corners: settings.outboundCorners)
                            .padding(settings.outboundPadding)
                    } else {
                        
                        ZStack {
                            settings.imageIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: settings.imageIconSize.width,
                                       height: settings.imageIconSize.height)
                                .foregroundColor(settings.outboundImageIconForeground)
                                
                        }
                        
                        .frame(width: settings.attachmentSize.width, height: settings.attachmentSize.height)
                        .background(settings.outboundBackground)
                        .cornerRadius(settings.attachmentRadius, corners: settings.outboundCorners)
                        .padding(settings.outboundPadding)
                        
                    }
                }
            }.disabled(fileTuple?.image == nil)
                .task {
                    do { fileTuple = try await message.file } catch { prettyLog(error)}
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
       
    }
}

//import QuickBloxData
//
//struct OutboundImageMessageRow_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        Group {
//            OutboundImageMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "[Attachment]", userId: "2d3d4d5d6d", date: Date()), onTap: { _ in})
//                .previewDisplayName("Out Message")
//            
//            
//            OutboundImageMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "[Attachment]", userId: "2d3d4d5d6d", date: Date()), onTap: { _ in})
//                .previewDisplayName("Out Dark Message")
//                .preferredColorScheme(.dark)
//        }
//    }
//}
