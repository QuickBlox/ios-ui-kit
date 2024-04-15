//
//  OutboundFileMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 12.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct OutboundFileMessageRow<MessageItem: MessageEntity>: View {
    private var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    private var features = QuickBloxUIKit.feature
    
    private var message: MessageItem
    
    private let onTap: (_ action: MessageAttachmentAction, _ url: URL?) -> Void
    
    @State private var fileTuple: (type: String, image: UIImage?, url: URL?)? = nil
    
    private var messagesActionState: MessageAction
    private var isSelected = false
    private var relatedTime: Date? = nil
    private var relatedStatus: MessageStatus? = nil
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
    private var fileTitle: String {
        if let ext = fileTuple?.url?.pathExtension {
            return settings.fileTitle + "." + ext
        }
        return "file.json"
    }
    
    @State private var contentSize: CGSize?
    
    public init(message: MessageItem,
                messagesActionState: MessageAction,
                relatedTime: Date?,
                relatedStatus: MessageStatus?,
                isSelected: Bool,
                onTap: @escaping (_ action: MessageAttachmentAction, _ url: URL?) -> Void,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
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
                            if features.forward.enable == true,
                               messagesActionState == .forward { return }
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
            .if(contentSize != nil && fileTuple?.url != nil, transform: { view in
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
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 8) {
                
                if forPreview == true {
                    OutboundFilePlaceholder()
                } else {
                    if fileTuple?.url != nil {
                        OutboundFilePlaceholder()
                    } else {
                        ProgressView()
                    }
                }
                
                Text(fileTitle)
                    .foregroundColor(settings.message.inboundForeground)
                    .font(settings.message.font)
            }
            .padding(settings.filePadding)
            .frame(height: settings.fileBubbleHeight)
            .fixedSize(horizontal: true, vertical: false)
            .background(settings.outboundBackground)
            .cornerRadius(settings.bubbleRadius, corners: features.forward.enable == true && message.actionType == .forward ||
                          message.actionType == .reply && message.relatedId.isEmpty == false ?
                          settings.outboundForwardCorners : settings.outboundCorners)
            .padding(.leading, forPreview == true ? 8 : 0)
            .contentSize(onChange: { contentSize in
                self.contentSize = contentSize
            })
            .padding(settings.outboundPadding)
        }
        .if(forPreview == false, transform: { view in
            view.task {
                do { fileTuple = try await message.file(size: nil) } catch { prettyLog(error)}
            }
        })
    }
    
    private func open() {
        guard let url = fileTuple?.url else { return }
        onTap(.open, url)
    }
}

private struct OutboundFilePlaceholder: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    public var body: some View {
        ZStack {
            settings.outboundFileBackground
                .frame(width: settings.fileSize.width,
                       height: settings.fileSize.height)
                .cornerRadius(settings.attachmentRadius)
            
            settings.file
                .resizable()
                .renderingMode(.template)
                .foregroundColor(settings.outboundFileForeground)
                .scaledToFit()
                .frame(width: settings.fileIconSize.width,
                       height: settings.fileIconSize.height)
        }
    }
}

import QuickBloxData

struct OutboundFileMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OutboundFileMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "[Attachment]",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date(),
                                                    actionType: .forward,
                                                    originSenderName: "Bob"),
                                   messagesActionState: .none,
                                   relatedTime: nil,
                                   relatedStatus: nil,
                                   isSelected: false,
                                   onTap: { (_,_) in},
                                   onSelect: { (_,_) in})
            .previewDisplayName("Out Message")
            
            
            OutboundFileMessageRow(message: Message(id: UUID().uuidString,
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
            .previewDisplayName("Out Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
