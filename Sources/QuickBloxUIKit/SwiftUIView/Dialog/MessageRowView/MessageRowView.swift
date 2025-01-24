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

public enum MessageAttachmentAction {
    case play, stop, open, save
}

public enum MessageStatus {
    case send, delivered, read
}

public enum MessageRowType {
    case inboundChat, inboundImage, inboundVideo, inboundAudio, inboundPDF, inboundGIF, outboundChat, outboundImage, outboundVideo, outboundAudio, outboundPDF, outboundGIF, event, dateDivider
}

public struct MessageRowView<MessageItem: MessageEntity>: View {
    
    var message: MessageItem
    var isSelected: Bool
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
        case .dateDivider: DateDividerMessageRowView(message: message)
        case .event: EventMessageRow(message: message)
        case .inboundAudio: InboundAudioMessageRow(message: message, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onPlay, playingMessage: playingMessage, isPlaying: isPlaying, currentTime: currentTime, onSelect: onSelect)
        case .inboundChat: InboundChatMessageRow(message: message, messagesActionState: messagesActionState, isSelected: isSelected,onAIFeature: onAIFeature, aiAnswerWaiting: aiAnswerWaiting, onSelect: onSelect)
        case .inboundImage: InboundImageMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundVideo: InboundVideoMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundPDF: InboundFileMessageRow(message: message, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .inboundGIF: InboundGIFMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .outboundAudio: OutboundAudioMessageRow(message: message, messagesActionState: messagesActionState, relatedTime: nil, relatedStatus: nil, isSelected: isSelected, onTap: onPlay, playingMessage: playingMessage, isPlaying: isPlaying, currentTime: currentTime, onSelect: onSelect)
        case .outboundChat: OutboundChatMessageRow(message: message, messagesActionState: messagesActionState, relatedTime: nil, relatedStatus: nil, isSelected: isSelected, onSelect: onSelect)
        case .outboundImage: OutboundImageMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, relatedTime: nil, relatedStatus: nil, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .outboundVideo: OutboundVideoMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, relatedTime: nil, relatedStatus: nil, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .outboundPDF: OutboundFileMessageRow(message: message, messagesActionState: messagesActionState, relatedTime: nil, relatedStatus: nil, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        case .outboundGIF: OutboundGIFMessageRow(message: message, fileTuple: fileTuple, messagesActionState: messagesActionState, relatedTime: nil, relatedStatus: nil, isSelected: isSelected, onTap: onTap, onSelect: onSelect)
        }
    }
}

extension MessageStatus {
    var image: Image {
        let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
        switch self {
        case .read: return settings.readImage
        case .delivered: return settings.deliveredImage
        case .send: return settings.sendImage
        }
    }
    
    var color: Color {
        let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
        switch self {
        case .read: return settings.readForeground
        case .delivered: return settings.deliveredForeground
        case .send: return settings.sendForeground
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
            if fileInfo?.ext == .gif {
                if isOwnedByCurrentUser {
                    return .outboundGIF
                } else {
                    return .inboundGIF
                }
            } else {
                if isOwnedByCurrentUser {
                    return .outboundVideo
                } else {
                    return .inboundVideo
                }
            }
        } else if isAudioMessage {
            if isOwnedByCurrentUser {
                return .outboundAudio
            } else {
                return .inboundAudio
            }
        } else if isFileMessage {
            if isOwnedByCurrentUser {
                return .outboundPDF
            } else {
                return .inboundPDF
            }
        } else  {
            if isOwnedByCurrentUser {
                return .outboundChat
            } else {
                return .inboundChat
            }
        }
    }
    
    var attachmentPlaceholder: Image? {
        let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.lastMessage
         if isImageMessage {
            return settings.imagePlaceholder
        } else if isVideoMessage {
            return settings.videoPlaceholder
        } else if isAudioMessage {
            return settings.audioPlaceholder
        } else if isFileMessage {
            return settings.filePlaceholder
        }
        return nil
    }
}

extension Date {
    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
