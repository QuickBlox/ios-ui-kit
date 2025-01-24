//
//  SyncDialogTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
import Combine
@testable import QuickBloxDomain
@testable import QuickBloxData

final class SyncDialogTests: XCTestCase {
    
    var dialogsRepoMock: DialogsRepositoryMock!
    var usersRepoMock: UsersRepositoryMock!
    var messagesRepoMock: MessagesRepositoryMock!
    
    
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = Set<AnyCancellable>()
        dialogsRepoMock = DialogsRepositoryMock()
        usersRepoMock = UsersRepositoryMock()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        dialogsRepoMock = nil
        usersRepoMock = nil
        
        try super.tearDownWithError()
    }
    
    typealias DialogsMethod = DialogsRepositoryMock.MockMethod
    typealias UserssMethod = UsersRepositoryMock.MockMethod

    func testExecute() async throws {
        let dialog = Dialog(id: "testId",
                            type: .private,
                            participantsIds: ["1", "2"])
        
        let users = [
            User(id: "1", name: "Bob"),
            User(id: "2", name: "Alice")
        ]
        
        dialogsRepoMock.results[DialogsMethod.getFromRemote] =
            .success([AcyncMockReturn { dialog }])
        
        usersRepoMock.results[UserssMethod.getUsersFromRemote] =
            .success([ AcyncMockReturn { users } ])
        
        dialogsRepoMock.results[DialogsMethod.saveDialogToLocal] =
            .success([AcyncMockVoid { }])
        
        
        let useCase  = SyncDialog(dialogId: dialog.id,
                                  dialogsRepo: dialogsRepoMock,
                                  usersRepo: usersRepoMock,
                                  messageRepo: MessagesRepositoryMock())
        
        let syncDialogExp = expectation(description: "sync dialog")
        useCase.execute().sink(receiveValue: { result in
            XCTAssertEqual(result.id, dialog.id)
            syncDialogExp.fulfill()
        }).store(in: &cancellables)
        
        let dialogs = [
            dialog,
            Dialog(id: "otherId", type: .public)
        ]
        let localSub = CurrentValueSubject<[Dialog], Never>(dialogs)
        dialogsRepoMock.localPublisher = localSub.eraseToAnyPublisher()
        
        await fulfillment(of: [syncDialogExp], timeout: 10.0)
        
        XCTAssertTrue(usersRepoMock.mockMetods.isEmpty)
        XCTAssertTrue(dialogsRepoMock.mockMetods.isEmpty)
    }
}
