//
//  QBTranslateMessage+RemoteTranslateMessageDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox

extension QBAITranslateMessage {
    convenience init(_ value: RemoteTranslateMessageDTO) {
        self.init(message: value.message,
                  smartChatAssistantId: value.smartChatAssistantId,
                  languageCode: value.languageCode)
    }
}
