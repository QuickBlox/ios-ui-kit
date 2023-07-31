//
//  MessageRowPlay.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct MessageRowPlay: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    let isOutbound: Bool
    var isPlaying: Bool
    
    var body: some View {
        if isPlaying {
            settings.pause
                .resizable()
                .scaledToFit()
                .foregroundColor(isOutbound == true ? settings.outboundPlayForeground : settings.playForeground)
                .frame(width: settings.audioPlaySize.width,
                       height: settings.audioPlaySize.height)
                .padding(.leading, -6)
            
        } else {
            settings.play
                .resizable()
                .scaledToFit()
                .foregroundColor(isOutbound == true ? settings.outboundPlayForeground : settings.playForeground)
                .frame(width: settings.audioPlaySize.width,
                       height: settings.audioPlaySize.height)
                .padding(.leading, -6)
        }
    }
}

struct MessageRowPlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageRowPlay(isOutbound: false, isPlaying: false)
                .previewDisplayName("Stop")
            MessageRowPlay(isOutbound: false, isPlaying: false)
                .previewDisplayName("Stop Dark")
                .preferredColorScheme(.dark)
            MessageRowPlay(isOutbound: false, isPlaying: true)
                .previewDisplayName("Play")
            MessageRowPlay(isOutbound: false, isPlaying: true)
                .previewDisplayName("Play Dark")
                .preferredColorScheme(.dark)
            MessageRowPlay(isOutbound: true, isPlaying: false)
                .previewDisplayName("Stop")
            MessageRowPlay(isOutbound: true, isPlaying: false)
                .previewDisplayName("Stop Dark")
                .preferredColorScheme(.dark)
            MessageRowPlay(isOutbound: true, isPlaying: true)
                .previewDisplayName("Play")
            MessageRowPlay(isOutbound: true, isPlaying: true)
                .previewDisplayName("Play Dark")
                .preferredColorScheme(.dark)
        }
    }
}
