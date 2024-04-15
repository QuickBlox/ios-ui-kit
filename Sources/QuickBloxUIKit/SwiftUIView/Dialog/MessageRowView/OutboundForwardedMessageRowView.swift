//
//  OutboundForwardedMessageRowView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 14.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct OutboundForwardedMessageRowView<MessageItem: MessageEntity>: View {
    var message: MessageItem
    var isSelected: Bool
    var relatedTime: Date?
    var relatedStatus: MessageStatus?
    var messagesActionState: MessageAction
    var fileTuple: (type: String, image: UIImage?, url: URL?)?
    @Binding var isPlaying: Bool
    @Binding var currentTime: TimeInterval
    var playingMessage: MessageIdsInfo
    let onTap: (_ action: MessageAttachmentAction, _ url: URL?) -> Void
    let onPlay: (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void
    let onAIFeature: (_ type: AIFeatureType, _ message: MessageItem) -> Void
    let onSelect: (_ item: MessageItem, _ actionType: MessageAction) -> Void
    @Binding var aiAnswerWaiting: AIAnswerInfo

    @ViewBuilder
    public var body: some View {
        
        switch message.rowType {
        case .inboundAudio, .outboundAudio: OutboundAudioMessageRow(message: message, messagesActionState: messagesActionState, relatedTime: relatedTime, relatedStatus: relatedStatus, isSelected: isSelected, onTap: onPlay, playingMessage: playingMessage, isPlaying: isPlaying, currentTime: currentTime, onSelect: onSelect)
        case .inboundChat, .outboundChat: OutboundChatMessageRow(message: message, messagesActionState: messagesActionState, relatedTime: relatedTime, relatedStatus: relatedStatus, isSelected: isSelected, onSelect: onSelect)
        case .inboundImage, .outboundImage: OutboundImageMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, relatedTime: relatedTime, relatedStatus: relatedStatus, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundVideo, .outboundVideo: OutboundVideoMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, relatedTime: relatedTime, relatedStatus: relatedStatus, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundPDF, .outboundPDF: OutboundFileMessageRow(message: message, messagesActionState: messagesActionState, relatedTime: relatedTime, relatedStatus: relatedStatus, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundGIF, .outboundGIF: OutboundGIFMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, relatedTime: relatedTime, relatedStatus: relatedStatus, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        default: EmptyView()
        }
    }
}
