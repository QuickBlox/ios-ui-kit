//
//  MessageRowView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public enum MessageAction {
    case edit, delete, forvard
}

public enum MessageAttachmentAction {
    case play, stop, zoom, save
}

public enum MessageStatus {
    case send, delivered, read
}

public enum MessageRowType {
    case inboundChat, inboundImage, inboundVideo, inboundAudio, inboundPDF, inboundGIF, outboundChat, outboundImage, outboundVideo, outboundAudio, outboundPDF, outboundGIF, event, dateDivider
}

public struct MessageRowView<MessageItem: MessageEntity>: View {
    
    var message: MessageItem
    @Binding var isPlaying: Bool
    var playingMessageId: String
    let onTap: (_ action: MessageAttachmentAction, _ image: Image?, _ url: URL?) -> Void
    let onPlay: (_ action: MessageAttachmentAction, _ data: Data?, _ url: URL?) -> Void
    let onAIFeature: (_ type: AIFeatureType, _ message: MessageItem?) -> Void
    @Binding var waitingTranslation: TranslationInfo
    

    @ViewBuilder
    public var body: some View {
        
        switch message.rowType {
        case .dateDivider: DateDividerMessageRowView(message: message)
        case .event: EventMessageRow(message: message)
        case .inboundAudio: InboundAudioMessageRow(message: message, onTap: onPlay, playingMessageId: playingMessageId, isPlaying: isPlaying)
        case .inboundChat: InboundChatMessageRow(message: message, onAIFeature: onAIFeature, waitingTranslation: waitingTranslation)
        case .inboundImage: InboundImageMessageRow(message: message, onTap: onTap)
        case .inboundVideo: InboundVideoMessageRow(message: message, onTap: onTap)
        case .inboundPDF: InboundFileMessageRow(message: message, onTap: onTap)
        case .inboundGIF: InboundGIFMessageRow(message: message, onTap: onTap)
        case .outboundAudio: OutboundAudioMessageRow(message: message, onTap: onPlay, playingMessageId: playingMessageId, isPlaying: isPlaying)
        case .outboundChat: OutboundChatMessageRow(message: message)
        case .outboundImage: OutboundImageMessageRow(message: message, onTap: onTap)
        case .outboundVideo: OutboundVideoMessageRow(message: message, onTap: onTap)
        case .outboundPDF: OutboundFileMessageRow(message: message, onTap: onTap)
        case .outboundGIF: OutboundGIFMessageRow(message: message, onTap: onTap)
        }
    }
}

extension MessageEntity {
    var status: MessageStatus {
        if isRead == true {
            return .read
        } else if isDelivered == true {
            return .delivered
        } else {
            return .send
        }
    }
    
    var statusImage: Image {
        let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
        switch status {
        case .read: return settings.readImage
        case .delivered: return settings.deliveredImage
        case .send: return settings.sendImage
        }
    }
    
    var statusForeground: Color {
        let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
        switch status {
        case .read: return settings.readForeground
        case .delivered: return settings.deliveredForeground
        case .send: return settings.sendForeground
        }
    }
}

extension MessageEntity {
    var rowType: MessageRowType {
        if type == .divider {
            return .dateDivider
        } else if type == .event {
            return .event
        }
        else if isImageMessage {
            if isOwnedByCurrentUser {
                return .outboundImage
            } else {
                return .inboundImage
            }
        } else if isVideoMessage {
            if isOwnedByCurrentUser {
                return .outboundVideo
            } else {
                return .inboundVideo
            }
        } else if isAudioMessage {
            if isOwnedByCurrentUser {
                return .outboundAudio
            } else {
                return .inboundAudio
            }
        } else if isPDFMessage {
            if isOwnedByCurrentUser {
                return .outboundPDF
            } else {
                return .inboundPDF
            }
        } else if isGIFMessage {
            if isOwnedByCurrentUser {
                return .outboundGIF
            } else {
                return .inboundGIF
            }
        } else  {
            if isOwnedByCurrentUser {
                return .outboundChat
            } else {
                return .inboundChat
            }
        }
    }
}

extension Date {
    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
}
