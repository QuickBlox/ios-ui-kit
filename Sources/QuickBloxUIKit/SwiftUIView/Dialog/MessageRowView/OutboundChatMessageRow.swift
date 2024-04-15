//
//  OutboundChatMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct OutboundChatMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    
    private var messagesActionState: MessageAction
    private var isSelected = false
    private var relatedTime: Date? = nil
    private var relatedStatus: MessageStatus? = nil
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
    private var size: CGSize {
        if let contentSize, contentSize.height / contentSize.width > settings.outboundPreviewRatio {
            return settings.outboundPreviewSize
        } else if let contentSize {
            return contentSize
        }
        return .zero
    }
    
    @State private var contentSize: CGSize?
    
    public init(message: MessageItem,
                messagesActionState: MessageAction,
                relatedTime: Date?,
                relatedStatus: MessageStatus?,
                isSelected: Bool,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
        self.messagesActionState = messagesActionState
        self.relatedTime = relatedTime
        self.relatedStatus = relatedStatus
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ZStack {
            HStack {
                
                if features.forward.enable == true,
                   messagesActionState == .forward {
                    Checkbox(isSelected: isSelected)
                }
                
                Spacer(minLength: message.actionType == .reply && message.relatedId.isEmpty == false ? 100 : settings.outboundSpacer)
                
                if settings.isHiddenTime == false,
                   message.actionType == .none ||
                    message.actionType == .forward ||
                    message.actionType == .reply && message.relatedId.isEmpty == true {
                    VStack(alignment: .trailing, spacing: 0) {
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
                    
                    MessageRowText(isOutbound: true, text: message.text)
                        .cornerRadius(settings.bubbleRadius, corners: features.forward.enable == true && message.actionType == .forward ||
                                      message.actionType == .reply && message.relatedId.isEmpty == false ?
                                      settings.outboundForwardCorners : settings.outboundCorners)
                        .contentSize(onChange: { contentSize in
                            self.contentSize = contentSize
                        })
                    
                }.padding(settings.outboundPadding)
            }
            .padding(.bottom, message.actionType == .reply && message.relatedId.isEmpty == false ? 2 : settings.spacerBetweenRows)
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
            
            .if(contentSize != nil, transform: { view in
                view.customContextMenu (
                    preview: MessageRowText(isOutbound: true, text: message.text)
                        .cornerRadius(settings.attachmentRadius, corners: settings.outboundForwardCorners),
                    preferredContentSize: size
                ) {
                    CustomContextMenuAction(title: settings.reply.title,
                                            systemImage: settings.reply.systemImage ?? "",
                                            tintColor: settings.reply.color,
                                            flipped: UIImageAxis.none,
                                            attributes: features.reply.enable == true
                                            ? nil : .hidden) {
                        onSelect(message, .reply)
                    }
                    CustomContextMenuAction(title: settings.forward.title,
                                            systemImage: settings.forward.systemImage ?? "",
                                            tintColor: settings.forward.color,
                                            flipped: .horizontal,
                                            attributes: features.forward.enable == true
                                            ? nil : .hidden) {
                        DispatchQueue.main.async {
                            onSelect(message, .forward)
                        }
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
}

import QuickBloxData

struct OutboundChatMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text https://quickblox.com/blog/how-to-build-chat-app-with-ios-ui-kit/ Message", userId: "testid", date: Date(), actionType: .forward, originSenderName: "Bob"),
                                   messagesActionState: .none,
                                   relatedTime: nil,
                                   relatedStatus: nil,
                                   isSelected: false,
                                   onSelect: { (_,_) in})
            .previewDisplayName("Out Message")
            
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message", userId: "2d3d4d5d6d", date: Date(), actionType: .forward, originSenderName: "Bob"),
                                   messagesActionState: .none,
                                   relatedTime: nil,
                                   relatedStatus: nil,
                                   isSelected: false,
                                   onSelect: { (_,_) in})
            .previewDisplayName("In Message")
            .preferredColorScheme(.dark)
            
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "T", userId: "2d3d4d5d6d", date: Date(), actionType: .forward, originSenderName: "Bob"),
                                   messagesActionState: .none,
                                   relatedTime: nil,
                                   relatedStatus: nil,
                                   isSelected: false,
                                   onSelect: { (_,_) in})
            .previewDisplayName("1")
            
            OutboundChatMessageRow(message: Message(id: UUID().uuidString, dialogId: "1f2f3ds4d5d6d", text: "Test text https://quickblox.com/blog/how-to-build-chat-app-with-ios-ui-kit/ Message", userId: "2d3d4d5d6d", date: Date()),
                                   messagesActionState: .none,
                                   relatedTime: nil,
                                   relatedStatus: nil,
                                   isSelected: false,
                                   onSelect: { (_,_) in})
            .previewDisplayName("In Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
