//
//  DialogsUpdates.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Combine

public class DialogsUpdates<Repo: DialogsRepositoryProtocol> {
    private let repo: Repo
    
    public init(repo: Repo) {
        self.repo = repo
    }
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func execute() async -> AnyPublisher<[Repo.DialogEntityItem], Never> {
        return await repo.localDialogsPublisher
    }
}
