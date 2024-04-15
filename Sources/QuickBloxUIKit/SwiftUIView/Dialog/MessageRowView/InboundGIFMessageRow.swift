//
//  InboundGIFMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct InboundGIFMessageRow<MessageItem: MessageEntity>: View {
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
                    Checkbox(isSelected: isSelected)
                }
                
                MessageRowAvatar(message: message)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    MessageRowName(message: message)
                    
                    HStack(spacing: 8) {
                        
                        if features.forward.enable == true,
                           messagesActionState == .forward {
                            messageContent()
                        } else {
                            Button {
                                if fileTuple?.url != nil {
                                    open()
                                }
                            } label: {
                                messageContent()
                            }.buttonStyle(.plain)
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
                }.padding(.leading, message.actionType == .reply && message.relatedId.isEmpty == false ? settings.relatedInboundSpacer : 0)
                
                Spacer(minLength: settings.inboundSpacer)
            }
            .padding(.bottom, actionSpacerBetweenRows())
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
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
                
                if features.forward.enable == true,
               messagesActionState == .forward {
                Button {
                    onSelect(message, .forward)
                } label: {
                    EmptyView()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
            }
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
                    .cornerRadius(settings.attachmentRadius, corners: message.actionType == .reply && message.relatedId.isEmpty == false ?
                                  settings.outboundForwardCorners : settings.inboundCorners)
                
                settings.videoPlayBackground
                    .frame(width: settings.imageIconSize.width,
                           height: settings.imageIconSize.height)
                    .cornerRadius(6)
                
                Text(settings.gifTitle)
                    .font(settings.gifFontPlay)
                    .foregroundColor(settings.videoPlayForeground)
                
            } else {
                
                settings.progressBarBackground()
                    .frame(width: settings.attachmentSize.width,
                           height: settings.attachmentSize.height)
                    .cornerRadius(settings.attachmentRadius, corners: message.actionType == .reply && message.relatedId.isEmpty == false ?
                                  settings.outboundForwardCorners : settings.inboundCorners)
                
                SegmentedCircularBar(settings: settings.progressBar)
            }
        }
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

import QuickBloxData

struct InboundGIFMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            InboundGIFMessageRow(message: Message(id: UUID().uuidString,
                                                  dialogId: "1f2f3ds4d5d6d",
                                                  text: "[Attachment]",
                                                  userId: "2d3d4d5d6d",
                                                  date: Date()),
                                 messagesActionState: .none,
                                 isSelected: false,
                                 onTap: { (_,_) in},
                                 onSelect: { (_,_) in})
            .previewDisplayName("Video with Thumbnail")
            
            InboundGIFMessageRow(message: Message(id: UUID().uuidString,
                                                  dialogId: "1f2f3ds4d5d6d",
                                                  text: "[Attachment]",
                                                  userId: "2d3d4d5d6d",
                                                  date: Date()),
                                 messagesActionState: .none,
                                 isSelected: false,
                                 onTap: { (_,_) in},
                                 onSelect: { (_,_) in})
            .previewDisplayName("Video without Thumbnail")
            
            InboundGIFMessageRow(message: Message(id: UUID().uuidString,
                                                  dialogId: "1f2f3ds4d5d6d",
                                                  text: "[Attachment]",
                                                  userId: "2d3d4d5d6d",
                                                  date: Date()),
                                 messagesActionState: .none,
                                 isSelected: false,
                                 onTap: { (_,_) in},
                                 onSelect: { (_,_) in})
            .previewDisplayName("Video without Thumbnail")
            .preferredColorScheme(.dark)
            
            InboundGIFMessageRow(message: Message(id: UUID().uuidString,
                                                  dialogId: "1f2f3ds4d5d6d",
                                                  text: "[Attachment]",
                                                  userId: "2d3d4d5d6d",
                                                  date: Date()),
                                 messagesActionState: .none,
                                 isSelected: false,
                                 onTap: { (_,_) in},
                                 onSelect: { (_,_) in})
            .previewDisplayName("Video with Thumbnail")
            .preferredColorScheme(.dark)
        }
    }
}
