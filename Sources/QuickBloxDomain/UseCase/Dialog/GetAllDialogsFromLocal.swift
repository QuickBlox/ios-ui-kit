//
//  GetAllDialogsFromLocal.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 09.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine
import QuickBloxLog
import Foundation

public class GetAllDialogsFromLocal<Dialog: DialogEntity,
                       DialogsRepo: DialogsRepositoryProtocol>
where Dialog == DialogsRepo.DialogEntityItem {
    private let dialogsRepo: DialogsRepo
    
    public init(dialogsRepo: DialogsRepo) {
        self.dialogsRepo = dialogsRepo
    }
    
    public func execute() async throws -> [Dialog] {
        return try await dialogsRepo.getAllDialogsFromLocal()
    }
}
