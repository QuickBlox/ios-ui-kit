//
//  MessageRowStatus.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.07.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain

public struct MessageRowStatus: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    var status: MessageStatus
    
    public init(status: MessageStatus) {
        self.status = status
    }
    
    public  var body: some View {
        if settings.isHiddenStatus == false {
            status.image
                .resizable()
                .renderingMode(.template)
                .foregroundColor(status.color)
                .scaledToFit()
                .frame(width: 10, height: 5)
        } else {
            EmptyView()
        }
    }
}

import QuickBloxData

struct MessageRowStatus_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MessageRowStatus(status: .delivered)
            .previewDisplayName("Delivered")

            MessageRowStatus(status: .delivered)
            .previewDisplayName("Delivered Dark")
            .preferredColorScheme(.dark)

            MessageRowStatus(status: .send)
            .previewDisplayName("Send")

            MessageRowStatus(status: .send)
            .previewDisplayName("Send Dark")
            .preferredColorScheme(.dark)

            MessageRowStatus(status: .read)
            .previewDisplayName("Read Dark")

            MessageRowStatus(status: .read)
            .previewDisplayName("Read Dark")
            .preferredColorScheme(.dark)
        }
    }
}
