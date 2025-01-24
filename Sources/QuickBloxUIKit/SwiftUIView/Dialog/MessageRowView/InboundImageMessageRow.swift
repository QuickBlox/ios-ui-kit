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
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ url: URL?) -> Void
    
    private var fileTuple: (type: String, image: UIImage?, url: URL?)? = nil
    private var messagesActionState: MessageAction
    private var isSelected = false
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
    @State private var contentSize: CGSize?
    
    public init(message: MessageItem,
                fileTuple: (type: String, image: UIImage?, url: URL?)? = nil,
                messagesActionState: MessageAction,
                isSelected: Bool,
                onTap: @escaping (_ action: MessageAttachmentAction, _ url: URL?) -> Void,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
        self.fileTuple = fileTuple
        self.messagesActionState = messagesActionState
        self.isSelected = isSelected
        self.onTap = onTap
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ZStack {
            HStack {
                
                if features.forward.enable == true,
                   messagesActionState == .forward {
                    Checkbox(isSelected: isSelected) {
                        onSelect(message, .forward)
                    }
                }
                
                MessageRowAvatar(message: message)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    MessageRowName(message: message)
                    
                    HStack(spacing: 8) {
                        if features.forward.enable == true,
                           messagesActionState == .forward {
                            messageContent()
                        } else {
                            messageContent()
                                .if(contentSize != nil && fileTuple?.image != nil, transform: { view in
                                    view.customContextMenu (
                                        preview: messageContent(forPreview: true),
                                        preferredContentSize: CGSize(width: contentSize?.width ?? 0.0,
                                                                     height: contentSize?.height ?? 0.0)
                                    ) {
                                        CustomContextMenuAction(title: settings.reply.title,
                                                                systemImage: settings.reply.systemImage ?? "", tintColor: settings.reply.color, flipped: UIImageAxis.none,
                                                                attributes: features.reply.enable == true
                                                                ? nil : .hidden) {
                                            onSelect(message, .reply)
                                        }
                                        CustomContextMenuAction(title: settings.forward.title,
                                                                systemImage: settings.forward.systemImage ?? "", tintColor: settings.forward.color, flipped: .horizontal,
                                                                attributes: features.forward.enable == true
                                                                ? nil : .hidden) {
                                            onSelect(message, .forward)
                                        }
                                    }
                                })
                                .onTapGesture {
                                    if fileTuple?.url != nil {
                                        open()
                                    }
                                }
                        }
                        
                        if message.actionType == .none ||
                            message.actionType == .forward ||
                            message.actionType == .reply && message.relatedId.isEmpty == true {
                            VStack(alignment: .leading) {
                                Spacer()
                                HStack {
                                    
                                    MessageRowTime(date: message.date)
                                    
                                }.padding(.bottom, 2)
                            }
                        }
                    }
                }.padding(.leading, message.actionType == .reply && message.relatedId.isEmpty == false ?
                          settings.relatedInboundSpacer : 0)
                
                Spacer(minLength: settings.inboundSpacer)
            }
            .padding(.bottom, actionSpacerBetweenRows())
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
        }
    }
    
    @ViewBuilder
    private func messageContent(forPreview: Bool = false) -> some View {
        ZStack {
            if let image = fileTuple?.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: settings.attachmentSize(isPortrait: image.size.height > image.size.width).width, height: settings.attachmentSize(isPortrait: image.size.height > image.size.width).height)
                    .fixedSize()
                    .clipped()
            } else {
                settings.progressBarBackground()
                    .frame(width: settings.attachmentSize(isPortrait: true).width, height: settings.attachmentSize(isPortrait: true).height)
                SegmentedCircularBar(settings: settings.progressBar)
            }
        }
        .cornerRadius(settings.attachmentRadius, corners: message.actionType == .reply && message.relatedId.isEmpty == false ?
                      settings.outboundForwardCorners : settings.inboundCorners)
        .contentSize(onChange: { contentSize in
            self.contentSize = contentSize
        })
    }
    
    private func open() {
        guard let url = fileTuple?.url else { return }
        onTap(.open, url)
    }
    
    private func actionSpacerBetweenRows() -> CGFloat {
        if message.actionType == .reply && message.relatedId.isEmpty == false {
            return settings.replySpacing
        } else if message.actionType == .forward && message.relatedId.isEmpty == false {
            return settings.forwardSpacing
        }
        return settings.spacerBetweenRows
    }
}

//import QuickBloxData
//
//struct InboundImageMessageRow_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            InboundImageMessageRow(message: Message(id: UUID().uuidString,
//                                                    dialogId: "1f2f3ds4d5d6d",
//                                                    text: "Test text Message",
//                                                    userId: "2d3d4d5d6d",
//                                                    date: Date()),
//                                   messagesActionState: .none,
//                                   isSelected: false,
//                                   onTap: { (_,_) in},
//                                   onSelect: { (_,_) in})
//            .previewDisplayName("Message")
//
//            InboundImageMessageRow(message: Message(id: UUID().uuidString,
//                                                    dialogId: "1f2f3ds4d5d6d",
//                                                    text: "Test text Message",
//                                                    userId: "2d3d4d5d6d",
//                                                    date: Date()),
//                                   messagesActionState: .none,
//                                   isSelected: false,
//                                   onTap: { (_,_) in},
//                                   onSelect: { (_,_) in})
//            .previewDisplayName("In Message")
//            .preferredColorScheme(.dark)
//        }
//    }
//}
