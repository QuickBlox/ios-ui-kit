//
//  GetDialog.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 05.10.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Foundation

public class GetDialog<Dialog: DialogEntity,
                       DialogsRepo: DialogsRepositoryProtocol>
where Dialog == DialogsRepo.DialogEntityItem {
    private let dialogId: String
    private let dialogsRepo: DialogsRepo
    
    public init(dialogId: String,
                dialogsRepo: DialogsRepo) {
        self.dialogId = dialogId
        self.dialogsRepo = dialogsRepo
    }
    
    public func execute() async throws -> Dialog {
        guard let dialog = try? await dialogsRepo.get(dialogFromLocal: dialogId) else {
            let dialog = try await dialogsRepo.get(dialogFromRemote: dialogId)
            return dialog
        }
        return dialog
    }
}
