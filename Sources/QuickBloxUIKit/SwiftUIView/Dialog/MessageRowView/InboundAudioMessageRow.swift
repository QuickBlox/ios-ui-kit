//
//  InboundAudioMessageRow.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 05.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain
import QuickBloxLog

public struct InboundAudioMessageRow<MessageItem: MessageEntity>: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var features = QuickBloxUIKit.feature
    
    var message: MessageItem
    
    var isPlaying: Bool = false
    
    var currentTime: TimeInterval = 0.0
    
    let onTap: (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void
    
    @State public var fileTuple: (type: String, data: Data?, url: URL?, time: TimeInterval)? = nil
    
    private var messagesActionState: MessageAction
    private var isSelected = false
    
    private let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    
    public init(message: MessageItem,
                messagesActionState: MessageAction,
                isSelected: Bool,
                onTap: @escaping  (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void,
                playingMessage: MessageIdsInfo, isPlaying: Bool, currentTime: TimeInterval,
                onSelect: @escaping (_ item: MessageItem, _ actionType: MessageAction) -> Void) {
        self.message = message
        self.messagesActionState = messagesActionState
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
                    Checkbox(isSelected: isSelected) {
                        onSelect(message, .forward)
                    }
                }
                
                MessageRowAvatar(message: message)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    MessageRowName(message: message)
                    
                    VStack(alignment: .leading) {
                        HStack(alignment: .center, spacing: 8) {
                            
                            if features.forward.enable == true,
                               messagesActionState == .forward {
                                messageContent()
                            } else {
                                messageContent()
                                    .if(fileTuple?.url != nil, transform: { view in
                                        view.customContextMenu (
                                            preview: messageContent(forPreview: true)
                                                .cornerRadius(settings.attachmentRadius, corners: settings.outboundForwardCorners),
                                            preferredContentSize: settings.inboundAudioPreviewSize
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
                                            CustomContextMenuAction(title: settings.save.title,
                                                                    systemImage: settings.save.systemImage ?? "", tintColor: settings.save.color, flipped: nil,
                                                                    attributes: nil) {
                                                save()
                                            }
                                        }
                                    })
                                    .onTapGesture {
                                        if fileTuple?.url != nil {
                                            play()
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
                    }
                }.padding(.leading, message.actionType == .reply && message.relatedId.isEmpty == false ? settings.relatedInboundSpacer : 0)
                
                Spacer(minLength: settings.inboundSpacer)
                
            }
            .padding(.bottom, actionSpacerBetweenRows())
            .fixedSize(horizontal: false, vertical: true)
            .id(message.id)
        }
    }
    
    @ViewBuilder
    private func messageContent(forPreview: Bool = false) -> some View {
        HStack(alignment: .center, spacing: 8) {
            
            if forPreview == true {
                MessageRowPlay(isOutbound: false, isPlaying: isPlaying)
            } else {
                
                if fileTuple?.url != nil {
                    
                    MessageRowPlay(isOutbound: false, isPlaying: isPlaying)
                    
                } else {
                    ProgressView().padding(.leading, -6)
                }
            }
            
            VStack(alignment: .leading, spacing: settings.infoSpacing) {
                settings.waveImage
                    .resizable()
                    .frame(width: settings.audioImageSize.width, height: settings.audioImageSize.height)
                
                Text(isPlaying == true ? currentTime.audioString() : (fileTuple?.time.audioString() ?? "00:00"))
                    .foregroundColor(settings.time.foregroundColor)
                    .font(settings.time.font)
            }
        }
        .padding(settings.audioPadding)
        .frame(height: settings.audioBubbleHeight)
        .background(settings.inboundBackground)
        .cornerRadius(settings.bubbleRadius, corners: message.actionType == .reply && message.relatedId.isEmpty == false ?
                      settings.outboundForwardCorners : settings.inboundCorners)
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
    
    private func isShowElement() -> Bool {
        return message.actionType == .none ||
        message.actionType == .forward ||
        message.actionType == .reply && message.relatedId.isEmpty
    }
    
    private func actionSpacerBetweenRows() -> CGFloat {
        if message.actionType == .reply && message.relatedId.isEmpty == false {
            return settings.replyAudioSpacing
        } else if message.actionType == .forward && message.relatedId.isEmpty == false {
            return settings.forwardAudioSpacing
        }
        return settings.spacerBetweenRows
    }
}

import QuickBloxData

struct InboundAudioMessageRow_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            InboundAudioMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "[Attachment]",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date(), originSenderName: "Bob"),
                                   messagesActionState: .none,
                                   isSelected: false,
                                   onTap: {(_,_,_) in},
                                   playingMessage: MessageIdsInfo(messageId: "", relatedId: ""),
                                   isPlaying: true,
                                   currentTime: 50,
                                   onSelect: { (_,_) in})
            .previewDisplayName("Out Message")
            
            
            InboundAudioMessageRow(message: Message(id: UUID().uuidString,
                                                    dialogId: "1f2f3ds4d5d6d",
                                                    text: "[Attachment]",
                                                    userId: "2d3d4d5d6d",
                                                    date: Date(), originSenderName: "Bob"),
                                   messagesActionState: .none,
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
