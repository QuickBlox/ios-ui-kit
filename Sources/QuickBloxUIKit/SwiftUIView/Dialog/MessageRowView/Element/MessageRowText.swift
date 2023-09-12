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
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var aiFeatures = QuickBloxUIKit.feature.ai
    
    let isOutbound: Bool
    var text: String = ""
    
    public var body: some View {
        if text.containtsLink == true {
            Text(text.makeAttributedString(isOutbound == true ? settings.outboundForeground : settings.inboundForeground,
                                           linkColor: isOutbound == true ? settings.outboundLinkForeground : settings.inboundLinkForeground,
                                           linkFont: settings.linkFont,
                                           underline: settings.linkUnderline))
            .lineLimit(nil)
            .multilineTextAlignment(.leading)
            .font(isOutbound == true ? settings.outboundFont : settings.inboundFont)
            .padding(settings.messagePadding)
            .frame(minWidth: aiFeatures.translate.enable == true ? aiFeatures.ui.translate.width : 0, alignment: .leading)
            .background(isOutbound == true ? settings.outboundBackground : settings.inboundBackground)
            .cornerRadius(settings.bubbleRadius, corners: isOutbound == true ? settings.outboundCorners : settings.inboundCorners)
            .padding(isOutbound == true ? settings.outboundPadding : settings.inboundPadding(showName: settings.isHiddenName))
            .animation(.easeInOut, value: text)
        } else {
            Text(text)
                .lineLimit(nil)
                .font(isOutbound == true ? settings.outboundFont : settings.inboundFont)
                .foregroundColor(isOutbound == true ? settings.outboundForeground : settings.inboundForeground)
                .padding(settings.messagePadding)
                .frame(minWidth: aiFeatures.translate.enable == true ? aiFeatures.ui.translate.width : 0, alignment: .leading)
                .background(isOutbound == true ? settings.outboundBackground : settings.inboundBackground)
                .cornerRadius(settings.bubbleRadius, corners: isOutbound == true ? settings.outboundCorners : settings.inboundCorners)
                .padding(isOutbound == true ? settings.outboundPadding : settings.inboundPadding(showName: settings.isHiddenName))
                .animation(.easeInOut, value: text)
        }
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
