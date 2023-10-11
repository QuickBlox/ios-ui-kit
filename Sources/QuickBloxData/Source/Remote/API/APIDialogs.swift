//
//  APIDialogs.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox

struct DialogsPayload {
    let dialogs:[QBChatDialog]
    let usersIds: Set<NSNumber>
    let page: QBResponsePage
}

struct APIDialogs {
    func `get`(`for` page: QBResponsePage) async throws -> DialogsPayload {
        return try await withCheckedThrowingContinuation { continuation in
            let extended = ["sort_desc": "updated_at"]
            QBRequest.dialogs(for: page, extendedRequest: extended) {
                response, dialogs, dialogsUsersIDs, page in
                let payload = DialogsPayload(dialogs: dialogs,
                                             usersIds: dialogsUsersIDs,
                                             page: page)
                continuation.resume(returning: payload)
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
    
    func `get`(with id: String) async throws -> QBChatDialog {
        return try await withCheckedThrowingContinuation { continuation in
            let extended = ["_id": id]
            let page = QBResponsePage()
            QBRequest.dialogs(for: page, extendedRequest: extended) {
                _, dialogs, _, _ in
                if let dialog = dialogs.first {
                    continuation.resume(returning: dialog)
                } else {
                    let info = "Dialog with id: \(id)"
                    let error = DataSourceException.notFound(description: info)
                    continuation.resume(throwing: error)
                }
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }

        }
    }
    
    func create(new dialog: QBChatDialog) async throws -> QBChatDialog {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.createDialog(dialog) { _, dialog in
                continuation.resume(returning: dialog)
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
    
    func update(_ dialog: QBChatDialog) async throws -> QBChatDialog {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.update(dialog) { _, dialog in
                continuation.resume(returning: dialog)
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
    
    func leave(_ dialog: QBChatDialog) async throws {
        let userId = QBSession.current.currentUserID
        dialog.pullOccupantsIDs = [(NSNumber(value: userId)).stringValue]
        _ = try await update(dialog)
    }
    
    func delete(with id: String, force: Bool) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.deleteDialogs(withIDs: Set([id]), forAllUsers: force) {
                _,_,_,_ in
                continuation.resume()
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
}
