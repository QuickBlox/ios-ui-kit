//
//  RemoteFileInfoDTO+QBChatAttachment.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain

extension RemoteFileInfoDTO {
    init (_ value: QBChatAttachment) throws {
        if let id = value.id {
            self.id = id
        } else {
            if let urlPath = value.url, let url = URL(string: urlPath) {
                self.id = url.lastPathComponent
            }
            if let uid = value.customParameters?["uid"] {
                self.id = uid
            }
            if let contentType = value["content-type"] {
                type = contentType
            }
        }
        
        name = value.name ?? ""
        type = value.type ?? ""
        if type == "audio/mp4" { // fix voice message from Safari
            type = "audio/mp3"
            name = name.replacingOccurrences(of: "mp4", with: "mp3")
        }
        path = value.url ?? ""
        
        if let uid = value.customParameters?["uid"] {
            self.uid = uid
        }
    }
}
