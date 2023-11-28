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
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ url: URL?) -> Void
    
    private var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    private var messagesActionState: MessageAction
    private var relatedTime: Date? = nil
    private var relatedStatus: MessageStatus? = nil
    private var isSelected = false
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
    public init(message: MessageItem,
                fileTuple: (type: String, image: Image?, url: URL?)? = nil,
                messagesActionState: MessageAction,
                relatedTime: Date?,
                relatedStatus: MessageStatus?,
                isSelected: Bool,
                onTap: @escaping (_ action: MessageAttachmentAction, _ url: URL?) -> Void,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
        self.fileTuple = fileTuple
        self.messagesActionState = messagesActionState
        self.relatedTime = relatedTime
        self.relatedStatus = relatedStatus
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
                
                Spacer(minLength: settings.outboundSpacer)
                
                if message.actionType == .none ||
                    message.actionType == .forward ||
                    message.actionType == .reply && message.relatedId.isEmpty == true {
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack(spacing: 3) {
                            
                            if let relatedStatus {
                                MessageRowStatus(status: relatedStatus)
                            } else {
                                MessageRowStatus(status: message.status)
                            }
                            
                            if let relatedTime {
                                MessageRowTime(date: relatedTime)
                            } else {
                                MessageRowTime(date: message.date)
                            }
                            
                        }.padding(.bottom, 2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    if message.actionType != .none, message.originSenderName != nil {
                        MessageRowName(message: message)
                    }
                    
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
                }
            }
            .padding(.bottom, message.actionType == .reply && message.relatedId.isEmpty == false ? 2 : settings.spacerBetweenRows)
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
            .if(fileTuple?.image != nil, transform: { view in
                view.customContextMenu (
                    preview: messageContent(forPreview: true),
                    preferredContentSize: CGSize(width: settings.attachmentSize.width,
                                                 height: settings.attachmentSize.height)
                ) {
                    CustomContextMenuAction(title: settings.reply.title,
                                         systemImage: settings.reply.systemImage ?? "",
                                         attributes: features.reply.enable == true
                                         ? nil : .hidden) {
                        onSelect(message, .reply)
                    }
                    CustomContextMenuAction(title: settings.forward.title,
                                         image: settings.forward.image ?? "",
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
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: settings.attachmentSize.width,
                           height: settings.attachmentSize.height)
                    .cornerRadius(settings.attachmentRadius, corners: features.forward.enable == true && message.actionType == .forward ||
                                  message.actionType == .reply && message.relatedId.isEmpty == false ?
                                  settings.outboundForwardCorners : settings.outboundCorners)
                    .padding(settings.outboundPadding)
                    .padding(.leading, forPreview == true ? 8 : 0)
                
                settings.videoPlayBackground
                    .frame(width: settings.imageIconSize.width,
                           height: settings.imageIconSize.height)
                    .cornerRadius(6)
                    .padding(.top)
                
                settings.play
                    .resizable()
                    .scaledToFit()
                    .frame(width: settings.videoIconSize(isImage: true).width,
                           height: settings.videoIconSize(isImage: true).height)
                    .foregroundColor(settings.videoPlayForeground)
                    .padding(.top)
                
            } else {
                
                settings.progressBarBackground()
                    .frame(width: settings.attachmentSize.width,
                           height: settings.attachmentSize.height)
                    .cornerRadius(settings.attachmentRadius, corners: features.forward.enable == true && message.actionType == .forward ||
                                  message.actionType == .reply && message.relatedId.isEmpty == false ?
                                  settings.outboundForwardCorners : settings.outboundCorners)
                    .padding(settings.outboundPadding)
                    .padding(.leading, forPreview == true ? 8 : 0)
                
                SegmentedCircularBar(settings: settings.progressBar)
            }
        }
    }
    
    private func open() {
        guard let url = fileTuple?.url else { return }
        onTap(.open, url)
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
                                                     actionType: .forward,
                                                     originSenderName: "Bob"),
                                    messagesActionState: .none,
                                    relatedTime: nil,
                                    relatedStatus: nil,
                                    isSelected: false,
                                    onTap: { (_,_) in},
                                    onSelect: { (_,_) in})
            .previewDisplayName("Video with Thumbnail")
            
            OutboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     actionType: .forward,
                                                     originSenderName: "Bob"),
                                    messagesActionState: .none,
                                    relatedTime: nil,
                                    relatedStatus: nil,
                                    isSelected: false,
                                    onTap: { (_,_) in},
                                    onSelect: { (_,_) in})
            .previewDisplayName("Video without Thumbnail")
            
            OutboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    messagesActionState: .none,
                                    relatedTime: nil,
                                    relatedStatus: nil,
                                    isSelected: false,
                                    onTap: { (_,_) in},
                                    onSelect: { (_,_) in})
            .previewDisplayName("Video without Thumbnail")
            .preferredColorScheme(.dark)
            
            OutboundVideoMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    messagesActionState: .none,
                                    relatedTime: nil,
                                    relatedStatus: nil,
                                    isSelected: false,
                                    onTap: { (_,_) in},
                                    onSelect: { (_,_) in})
            .previewDisplayName("Video with Thumbnail")
            .preferredColorScheme(.dark)
        }
    }
}
