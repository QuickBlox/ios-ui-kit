//
//  DialogsUpdatesTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
import Combine

@testable import QuickBloxDomain
@testable import QuickBloxData


final class DialogsUpdatesTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        try super.tearDownWithError()
    }

    func testExecute() async throws {
        let localSub = PassthroughSubject<[Dialog], Never>()
        let repo = DialogsRepositoryMock(localPublisher: localSub.eraseToAnyPublisher())
        
        let useCase  = DialogsUpdates(repo: repo)
        
        await useCase.execute()
            .sink { dialogs in
                XCTAssertTrue(dialogs.isEmpty)
            }
            .store(in: &cancellables)
        
        localSub.send([])
    }
}
