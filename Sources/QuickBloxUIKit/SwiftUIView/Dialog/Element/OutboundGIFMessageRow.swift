//
//  OutboundGIFMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog


public struct OutboundGIFMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    @State private var isPlaying: Bool = false
    
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
                play()
            } label: {
                
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    
                    ZStack(alignment: .center) {
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
                            
                            Text(settings.gifTitle)
                                .font(settings.gifFontPlay)
                                .foregroundColor(settings.videoPlayForeground)
                            
                        } else {
                            
                            settings.outboundBackground
                                .frame(width: settings.attachmentSize.width,
                                       height: settings.attachmentSize.height)
                                .cornerRadius(settings.attachmentRadius,
                                              corners: settings.outboundCorners)
                                .padding(settings.outboundPadding)
                            
                            Text(settings.gifTitle)
                                .font(settings.gifFont)
                                .foregroundColor(settings.outboundImageIconForeground)
                                .padding(.top)
                        }
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
    
    private func play() {
        guard let url = fileTuple?.url else { return }
        if isPlaying == true {
            onTap(.stop, nil, url)
        } else {
            onTap(.play, nil, url)
        }
    }
}

//import QuickBloxData
//
//struct OutboundGIFMessageRow_Previews: PreviewProvider {
//
//    static var previews: some View {
//        Group {
//            OutboundGIFMessageRow(message: Message(id: UUID().uuidString,
//                                                     dialogId: "1f2f3ds4d5d6d",
//                                                     text: "[Attachment]",
//                                                   userId: "2d3d4d5d6d",
//                                                     date: Date(),
//                                                     attachmentImage: Image("attachmentPlaceholder", bundle: .module)),
//                                  onTap: { _,_,_  in})
//            .previewDisplayName("Video with Thumbnail")
//
//            OutboundGIFMessageRow(message: Message(id: UUID().uuidString,
//                                                     dialogId: "1f2f3ds4d5d6d",
//                                                     text: "[Attachment]",
//                                                   userId: "2d3d4d5d6d",
//                                                     date: Date()),
//                                  onTap: { _,_,_  in})
//            .previewDisplayName("Video without Thumbnail")
//
//            OutboundGIFMessageRow(message: Message(id: UUID().uuidString,
//                                                     dialogId: "1f2f3ds4d5d6d",
//                                                     text: "[Attachment]",
//                                                     userId: "2d3d4d5d6d",
//                                                     date: Date()),
//                                  onTap: { _,_,_  in})
//            .previewDisplayName("Video without Thumbnail")
//            .preferredColorScheme(.dark)
//
//            OutboundGIFMessageRow(message: Message(id: UUID().uuidString,
//                                                     dialogId: "1f2f3ds4d5d6d",
//                                                     text: "[Attachment]",
//                                                     userId: "2d3d4d5d6d",
//                                                     date: Date(),
//                                                     attachmentImage: Image("attachmentPlaceholder", bundle: .module)),
//                                  onTap: { _,_,_  in})
//            .previewDisplayName("Video with Thumbnail")
//            .preferredColorScheme(.dark)
//        }
//    }
//}
