//
//  GetDialogs.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 08.03.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine

public class GetDialogs<Dialog: DialogEntity, Repo: DialogsRepositoryProtocol>
where Dialog == Repo.DialogEntityItem {
    private let repo: Repo
    
    public init(repo: Repo) {
        self.repo = repo
    }
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func execute() async throws -> [Dialog] {
        guard let dialogs = try? await repo.getAllDialogsFromRemote() else {
            return []
        }
        return dialogs
    }
}
