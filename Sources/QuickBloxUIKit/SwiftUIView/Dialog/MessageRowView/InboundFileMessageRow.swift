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
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    
    let onTap: (_ action: MessageAttachmentAction, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, image: Image?, url: URL?)? = nil
    
    private var messagesActionState: MessageAction
    private var isSelected = false
    
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
                isSelected: Bool,
                onTap: @escaping (_ action: MessageAttachmentAction, _ url: URL?) -> Void,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
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
                    
                    HStack(alignment: .center, spacing: 8) {
                        
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
            
            .id(message.id)
            .if(contentSize != nil && fileTuple?.url != nil, transform: { view in
                view.customContextMenu (
                    preview: messageContent(forPreview: true),
                    preferredContentSize: CGSize(width: contentSize?.width ?? 0.0,
                                                 height: contentSize?.height ?? 0.0)
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
        HStack(alignment: .center, spacing: 8) {
            
            if forPreview == true {
                InboundFilePlaceholder()
            } else {
                
                if fileTuple?.url != nil {
                    InboundFilePlaceholder()
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
        .background(settings.inboundBackground)
        .cornerRadius(settings.bubbleRadius, corners: message.actionType == .reply && message.relatedId.isEmpty == false ?
                      settings.outboundForwardCorners : settings.inboundCorners)
        .padding(.horizontal, forPreview == true ? 2 : 0)
        .contentSize(onChange: { contentSize in
            self.contentSize = contentSize
        })
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
    
    private func actionSpacerBetweenRows() -> CGFloat {
        if message.actionType == .reply && message.relatedId.isEmpty == false {
            return settings.replySpacing
        } else if message.actionType == .forward && message.relatedId.isEmpty == false {
            return settings.forwardSpacing
        }
        return settings.spacerBetweenRows
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
                                  messagesActionState: .none,
                                  isSelected: false,
                                  onTap: { (_,_) in},
                                  onSelect: { (_,_) in})
            .previewDisplayName("Out Message")
            
            
            InboundFileMessageRow(message: Message(id: UUID().uuidString,
                                                   dialogId: "1f2f3ds4d5d6d",
                                                   text: "[Attachment]",
                                                   userId: "2d3d4d5d6d",
                                                   date: Date()),
                                  messagesActionState: .none,
                                  isSelected: false,
                                  onTap: { (_,_) in},
                                  onSelect: { (_,_) in})
            .previewDisplayName("Out Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
