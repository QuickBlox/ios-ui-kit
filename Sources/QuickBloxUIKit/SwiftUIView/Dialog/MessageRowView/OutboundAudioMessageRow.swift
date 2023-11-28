//
//  OutboundAudioMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 05.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct OutboundAudioMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    
    var isPlaying: Bool = false
    
    var currentTime: TimeInterval = 0.0
    
    let onTap: (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, data: Data?, url: URL?, time: TimeInterval)? = nil
    
    private var messagesActionState: MessageAction
    private var isSelected = false
    private var relatedTime: Date? = nil
    private var relatedStatus: MessageStatus? = nil
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
//    @State private var contentSize: CGSize?
    
    public init(message: MessageItem,
                messagesActionState: MessageAction,
                relatedTime: Date?,
                relatedStatus: MessageStatus?,
                isSelected: Bool,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void,
                playingMessage: MessageIdsInfo, isPlaying: Bool, currentTime: TimeInterval,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
        self.messagesActionState = messagesActionState
        self.relatedTime = relatedTime
        self.relatedStatus = relatedStatus
        self.isSelected = isSelected
        self.onTap = onTap
        if playingMessage.messageId == message.id, playingMessage.relatedId == message.relatedId {
            self.isPlaying = isPlaying
        }
        self.currentTime = currentTime
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
                    if message.actionType == .forward ||
                        message.actionType == .reply && message.relatedId.isEmpty == false,
                       message.originSenderName != nil {
                        MessageRowName(message: message)
                    }
                    
                    if features.forward.enable == true,
                       messagesActionState == .forward {
                        messageContent()
                    } else {
                        Button {
                            if fileTuple?.url != nil {
                                play()
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
            .if(fileTuple?.url != nil, transform: { view in
                view.customContextMenu (
                    preview: messageContent(forPreview: true),
                    preferredContentSize: settings.outboundAudioPreviewSize
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
                    CustomContextMenuAction(title: settings.save.title,
                                         systemImage: settings.save.systemImage ?? "",
                                         attributes: nil) {
                        save()
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
                    MessageRowPlay(isOutbound: true, isPlaying: isPlaying)
                } else {
                    
                    if fileTuple?.url != nil {
                        
                        MessageRowPlay(isOutbound: true, isPlaying: isPlaying)
                        
                    } else {
                        ProgressView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    settings.waveImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: settings.audioImageSize.width, height: settings.audioImageSize.height)
                    
                    Text(isPlaying == true ? currentTime.audioString() : (fileTuple?.time.audioString() ?? "00:00"))
                        .foregroundColor(settings.time.foregroundColor)
                        .font(settings.time.font)
                }
            }
            .padding(settings.audioPadding)
            .frame(height: settings.audioBubbleHeight)
            .background(settings.outboundBackground)
            .cornerRadius(settings.bubbleRadius,
                          corners: features.forward.enable == true && message.actionType == .forward ||
                          message.actionType == .reply && message.relatedId.isEmpty == false ?
                          settings.outboundForwardCorners : settings.outboundCorners)
            .padding(settings.outboundPadding)
            .padding(.leading, forPreview == true ? 24 : 0)
            
        }
        .if(forPreview == false, transform: { view in
            view.task {
                do { fileTuple = try await message.audioFile } catch { prettyLog(error)}
            }
        })
    }
    
    private func play() {
        guard let url = fileTuple?.url, let data = fileTuple?.data else { return }
        if isPlaying == true {
            onTap(.stop, data, url)
        } else {
            onTap(.play, data, url)
        }
    }
    
    private func save() {
        guard let url = fileTuple?.url, let data = fileTuple?.data else { return }
        onTap(.save, data, url)
    }
}

import QuickBloxData

struct OutboundAudioMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            OutboundAudioMessageRow(message: Message(id: UUID().uuidString,
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
                                    onTap: {(_,_,_) in},
                                    playingMessage: MessageIdsInfo(messageId: "", relatedId: ""),
                                    isPlaying: true,
                                    currentTime: 50,
                                    onSelect: { (_,_) in})
            .previewDisplayName("Out Message")
            
            OutboundAudioMessageRow(message: Message(id: UUID().uuidString,
                                                     dialogId: "1f2f3ds4d5d6d",
                                                     text: "[Attachment]",
                                                     userId: "2d3d4d5d6d",
                                                     date: Date()),
                                    messagesActionState: .none,
                                    relatedTime: nil,
                                    relatedStatus: nil,
                                    isSelected: false,
                                    onTap: {(_,_,_) in},
                                    playingMessage: MessageIdsInfo(messageId: "", relatedId: ""),
                                    isPlaying: true,
                                    currentTime: 50,
                                    onSelect: { (_,_) in})
            .previewDisplayName("Out Dark Message")
            .preferredColorScheme(.dark)
        }
    }
}
