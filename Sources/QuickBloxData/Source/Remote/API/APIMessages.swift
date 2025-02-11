//
//  APIMessages.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox

public struct APIMessages {
    public func `get`(for id: String, with ids: [String], page pagination: Pagination)
    async throws -> (messages: [QBChatMessage], pagination: Pagination) {
        return try await withCheckedThrowingContinuation { continuation in
            let extended = ids.isEmpty
            ? ["sort_desc": "date_sent", "mark_as_read": "0"]
            : ["_id[in]": ids.joined(separator: ",")]
            
            let page = QBResponsePage(pagination)
            QBRequest.messages(withDialogID: id,
                               extendedRequest: extended,
                               for: page) { _, messages, page in
                continuation.resume(returning: (messages, Pagination(page)))
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
}
