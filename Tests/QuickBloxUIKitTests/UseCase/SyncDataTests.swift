////
////  SyncDataTests.swift
////  QuickBloxUIKit
////
////  Created by Injoit on 24.03.2023.
////  Copyright © 2023 QuickBlox. All rights reserved.
////
//
//import XCTest
//import Combine
//
//@testable import QuickBloxDomain
//@testable import QuickBloxData
//@testable import QuickBloxLog
//
//final class SyncDataTests: XCTestCase {
//    
//    typealias ConnectionMockMethod = ConnectionRepositoryMock.MockMethod
//    typealias DialogsMockMethod = DialogsRepositoryMock.MockMethod
//    typealias UsersMockMethod = UsersRepositoryMock.MockMethod
//    
//    private var cancellables: Set<AnyCancellable>!
//    
//    override func setUpWithError() throws {
//        try super.setUpWithError()
//        cancellables = Set<AnyCancellable>()
//    }
//    
//    override func tearDownWithError() throws {
//        cancellables = nil
//        try super.tearDownWithError()
//    }
//    
//    func testExecute() async throws {
//        let remoteSub = PassthroughSubject<RemoteDialogEvent<Message>, Never>()
//        let dialogsResults: [String: Result<[Any], Error>] = [
//            DialogsMockMethod.getAllFromRemote:
//                    .success([ AcyncMockReturn {
//                        let dialogs: [Dialog] = [Dialog.default]
//                        return dialogs
//                    }]),
//            DialogsMockMethod.saveDialogsToLocal:
//                    .success([ AcyncMockVoid { }])
//        ]
//        let dialogsRepo = DialogsRepositoryMock(
//            remotePublisher: remoteSub.eraseToAnyPublisher(),
//            results: dialogsResults
//        )
//        let connectSub = PassthroughSubject<ConnectionState, Never>()
//        let connectResults: [String: Result<[Any], Error>] = [
//            ConnectionMockMethod.checkConnection: .success([ AcyncMockVoid {
//                connectSub.send(.disconnected())
//            }]),
//            ConnectionMockMethod.connect: .success([ AcyncMockVoid {
//                connectSub.send(.connecting())
//                connectSub.send(.connected)
//            }]),
//            ConnectionMockMethod.disconnect: .success([ AcyncMockVoid {
//                connectSub.send(.disconnected())
//            }]),
//        ]
//        let connectRepo = ConnectionRepositoryMock(
//            connectSub.eraseToAnyPublisher(),
//            results: connectResults
//        )
//        
//        let usersResults: [String: Result<[Any], Error>] = [
//            UsersMockMethod.getUsersFromRemote: .success([ AcyncMockReturn {
//                [User.default]
//            }]),
//            UsersMockMethod.saveUsersToLocal: .success([ AcyncMockVoid { }])
//        ]
//        let usersRepo = UsersRepositoryMock(usersResults)
//        
//        let useCase = SyncData(dialogsRepo: dialogsRepo,
//                               usersRepo: usersRepo,
//                               connectRepo: connectRepo)
//        
//        let expectation = expectation(description: "sync dialogs")
//        expectation.expectedFulfillmentCount = 10
//        useCase.execute()
//            .sink { state in
//                switch state {
//                case .syncing(stage: let stage, error: let error):
//                    prettyLog(label: "Sync state stage", stage)
//                    if let error { prettyLog(error) }
//                    switch stage {
//                    case .disconnected: expectation.fulfill()
//                    case .connecting: expectation.fulfill()
//                    case .update: expectation.fulfill()
//                    case .details: XCTFail()
//                    case .unauthorized: XCTFail()
//                    }
//                case .synced:
//                    prettyLog(label: "Sync state", state)
//                    expectation.fulfill()
//                }
//            }
//            .store(in: &cancellables)
//        try await Task.sleep(.twoSeconds)
//        XCTAssertEqual(useCase.stateSubject.value, .synced)
//        
//        await NotificationCenter.default.post(
//            Notification(name: UIScene.didEnterBackgroundNotification)
//        )
//        try await Task.sleep(.double)
//        XCTAssertEqual(useCase.stateSubject.value, .syncing(stage: .disconnected))
//        
//        XCTAssertTrue(dialogsRepo.results.isEmpty)
//        XCTAssertTrue(usersRepo.results.isEmpty)
//        
//        dialogsRepo.results = dialogsResults
//        usersRepo.results = usersResults
//        connectRepo.results = connectResults
//        
//        await NotificationCenter.default.post(
//            Notification(name: UIScene.willEnterForegroundNotification)
//        )
//        try await Task.sleep(.twoSeconds)
//        XCTAssertEqual(useCase.stateSubject.value, .synced)
//        
//        XCTAssertTrue(dialogsRepo.results.isEmpty)
//        XCTAssertTrue(usersRepo.results.isEmpty)
//        
//        await fulfillment(of: [expectation], timeout: 1.0)
//    }
//    
//    func testSyncDialog() async throws {
//        let dialogsRepo = DialogsRepositoryMock()
//        dialogsRepo.results = [
//            DialogsMockMethod.getFromRemote:
//                    .success([ AcyncMockReturn { Dialog.default }]),
//            DialogsMockMethod.saveDialogToLocal:
//                    .success([ AcyncMockVoid { }])
//        ]
//        
//        let usersResults: [String: Result<[Any], Error>] = [
//            UsersMockMethod.getUsersFromRemote: .success([ AcyncMockReturn {
//                [User.default]
//            }]),
//            UsersMockMethod.saveUsersToLocal: .success([ AcyncMockVoid { }])
//        ]
//        let usersRepo = UsersRepositoryMock(usersResults)
//        
//        let useCase = SyncData(dialogsRepo: dialogsRepo,
//                               usersRepo: usersRepo,
//                               connectRepo: ConnectionRepositoryMock())
//        
//        try await XCTAssertNoThrowsException(
//            try await useCase.sync(dialog: Dialog.default.id)
//        )
//        
//        XCTAssertTrue(dialogsRepo.results.isEmpty)
//        
//        dialogsRepo.results = [
//            DialogsMockMethod.getFromRemote:
//                    .success([ AcyncMockReturn { Dialog.default }]),
//            DialogsMockMethod.saveDialogToLocal:
//                    .success([ AcyncMockError {
//                        RepositoryException.alreadyExist()
//                    }]),
//            DialogsMockMethod.updateDialogInLocal:
//                    .success([ AcyncMockVoid { }])
//        ]
//        
//        usersRepo.results = usersResults
//        try await XCTAssertNoThrowsException(
//            try await useCase.sync(dialog: Dialog.default.id)
//        )
//        
//        XCTAssertTrue(dialogsRepo.results.isEmpty)
//    }
//    
//    func testUpdateDialogWithNewMessage() async throws {
//        let dialogsRepo = DialogsRepositoryMock()
//        dialogsRepo.results = [
//            DialogsMockMethod.getFromLocal:
//                    .success([ AcyncMockReturn { Dialog.default }]),
//            DialogsMockMethod.updateDialogInLocal:
//                    .success([ AcyncMockVoid { }])
//        ]
//        
//        let useCase = SyncData(dialogsRepo: dialogsRepo,
//                               usersRepo: UsersRepositoryMock(),
//                               connectRepo: ConnectionRepositoryMock())
//        
//        try await XCTAssertNoThrowsException(
//            try await useCase.update(dialog: Message.newMessage)
//        )
//        
//        XCTAssertTrue(dialogsRepo.results.isEmpty)
//    }
//}
