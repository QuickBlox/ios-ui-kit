//
//  InboundForwardedMessageRowView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 14.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct InboundForwardedMessageRowView<MessageItem: MessageEntity>: View {
    
    var message: MessageItem
    var isSelected: Bool
    var messagesActionState: MessageAction
    var fileTuple: (type: String, image: Image?, url: URL?)?
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
        case .inboundAudio, .outboundAudio: InboundAudioMessageRow(message: message, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onPlay, playingMessage: playingMessage, isPlaying: isPlaying, currentTime: currentTime, onSelect: onSelect)
        case .inboundChat, .outboundChat: InboundChatMessageRow(message: message, messagesActionState: messagesActionState, isSelected: isSelected,onAIFeature: onAIFeature, aiAnswerWaiting: aiAnswerWaiting, onSelect: onSelect)
        case .inboundImage, .outboundImage: InboundImageMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundVideo, .outboundVideo: InboundVideoMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundPDF, .outboundPDF: InboundFileMessageRow(message: message, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundGIF, .outboundGIF: InboundGIFMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        default: EmptyView()
        }
    }
}
