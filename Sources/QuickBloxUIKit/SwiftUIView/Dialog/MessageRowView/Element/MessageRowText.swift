//
//  MessageRowText.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain

public struct MessageRowText: View {
    @Environment(\.openURL) var openURL
    
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var features = QuickBloxUIKit.feature
    
    let isOutbound: Bool
    var text: String = ""
    
    public var body: some View {
        if text.containtsLink == true {
            
            Button {
                if let url = text.link {
                    openURL(url)
                }
            } label: {
                Text(text.makeAttributedString(isOutbound == true ? settings.outboundForeground : settings.inboundForeground,
                                               linkColor: isOutbound == true ? settings.outboundLinkForeground : settings.inboundLinkForeground,
                                               linkFont: settings.linkFont,
                                               underline: settings.linkUnderline))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .font(isOutbound == true ? settings.outboundFont : settings.inboundFont)
                .padding(settings.messagePadding)
                .frame(minWidth: features.ai.translate.enable == true ? features.ai.ui.translate.width : 0, alignment: .leading)
                .background(isOutbound == true ? settings.outboundBackground : settings.inboundBackground)
                .animation(.easeInOut, value: text)
            }
        } else {
            Text(text == features.forward.forwardedMessageKey ? "" : text)
                .lineLimit(nil)
                .font(isOutbound == true ? settings.outboundFont : settings.inboundFont)
                .foregroundColor(isOutbound == true ? settings.outboundForeground : settings.inboundForeground)
                .padding(settings.messagePadding)
                .frame(minWidth: features.ai.translate.enable == true ? features.ai.ui.translate.width : 0, alignment: .leading)
                .background(isOutbound == true ? settings.outboundBackground : settings.inboundBackground)
                .animation(.easeInOut, value: text)        }
    }
}

struct MessageRowText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageRowText(isOutbound: false, text: "Test text https://quickblox.com/blog/how-to-build-chat-app-with-ios-ui-kit/ Message")
                .previewDisplayName("Message")
            
            MessageRowText(isOutbound: false, text: "T")
                .previewDisplayName("1")
            
            MessageRowText(isOutbound: false, text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message")
                .previewDisplayName("Message")
            
            MessageRowText(isOutbound: false, text: "Test text https://quickblox.com/blog/how-to-build-chat-app-with-ios-ui-kit/ Message")
                .previewDisplayName("Message")
                .preferredColorScheme(.dark)
            
            MessageRowText(isOutbound: false, text: "Test text Message Test text Message Test text Message Test text Message Test text Message Test text Message")
                .previewDisplayName("Message")
                .preferredColorScheme(.dark)
        }
    }
}
