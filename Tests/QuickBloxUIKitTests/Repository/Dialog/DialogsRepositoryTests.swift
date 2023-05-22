////
////  DialogRepositoryTests.swift
////  QuickBloxUIKitTests
////
////  Created by Injoit on 23.01.2023.
////  Copyright © 2023 QuickBlox. All rights reserved.
////
//
//import XCTest
//import Combine
//
//@testable import QuickBloxDomain
//@testable import QuickBloxData
//
//extension Dialog {
//    static var `default` =
//    Dialog(id: DialogsRepositoryTests.Test.stringId,
//           type: .private,
//           participantsIds: ["1", "2"],
//           photo: "",
//           ownerId: "",
//           createdAt: Date(),
//           updatedAt: Date(),
//           lastMessage: LastMessage.default,
//           unreadMessagesCount: 0)
//    
//    static var withEmptyId = Dialog(id: "",
//                                    type: .private,
//                                    participantsIds: [],
//                                    photo: "",
//                                    ownerId: "",
//                                    createdAt: Date(),
//                                    updatedAt: Date(),
//                                    lastMessage: LastMessage.default,
//                                    unreadMessagesCount: 0)
//}
//
//extension LastMessage {
//    static var `default` = LastMessage(id: DialogsRepositoryTests.Test.stringId,
//                                       text: DialogsRepositoryTests.Test.lastMessageText,
//                                       date: DialogsRepositoryTests.Test.lastMessageDateSend,
//                                       userId: DialogsRepositoryTests.Test.messageId)
//}
//
//extension RemoteDialogDTO {
//    static var `default` =
//    RemoteDialogDTO(id: DialogsRepositoryTests.Test.stringId)
//    
//    static var withEmptyId = RemoteDialogDTO()
//}
//
//final class DialogsRepositoryTests: XCTestCase {
//    typealias MockMethod = RemoteDataSourceMock.MockMethod
//    
//    struct Test {
//        // id
//        static let stringId = "1a2b3c4d5e"
//        static let dialogId = "2b3c4d5e6f"
//        static let messageId = "3a4b5c6d7e"
//        // ids
//        static let singleStringIds  = ["a1b2c3d4e5"]
//        static let emptyStringIds   = [String]()
//        static let stringIds        = ["2a3b4c5d6e", "3a4b5c6d7e", "4a5b6c7d8e"]
//        static let stringableIntIds = ["1234567", "2345678", "3456789"]
//        static let mixStringIds     = [""] + stringableIntIds + stringIds
//        
//        /// equel to stringableIntIds
//        static let intIds = [1234567,
//                             2345678,
//                             3456789]
//        
//        static let updatedIntIds = [456789, 567891, 678912]
//        static let updatedStringIds = ["456789", "567891", "678912"]
//        
//        
//        static let name = "TestName"
//        static let updatedName = "NameToUpdate"
//        static let lastMessageText = "Last Message Text"
//        static let lastMessageDateSend = Date()
//        static let intId = 1234567
//    }
//    
//    private var cancellables: Set<AnyCancellable>!
//    
//    override func setUp() async throws {
//        try await super.setUp()
//        cancellables = Set<AnyCancellable>()
//    }
//    
//    override func tearDown() async throws {
//        cancellables = nil
//        try await super.tearDown()
//    }
//}
//
//// Events
//extension DialogsRepositoryTests {
//    func testEventNewDilog() {
//        let subject = PassthroughSubject<RemoteEvent, Never>()
//        let reposytory = repository(mock: [:],
//                                    event: subject.eraseToAnyPublisher())
//        
//        let expectation = expectation(description: "new dialog")
//        reposytory.remoteEventPublisher.sink { event in
//            switch event {
//            case .create(withId: let id):
//                XCTAssertEqual(id, Test.dialogId)
//            case .update(_):
//                XCTFail("Unexpected event")
//            case .leave(_,_):
//                XCTFail("Unexpected event")
//            case .newMessage(_):
//                XCTFail("Unexpected event")
//            case .history( _, _):
//                XCTFail("Unexpected event")
//            }
//            expectation.fulfill()
//        }.store(in: &cancellables)
//        
//        subject.send(RemoteEvent.create(Test.dialogId))
//        wait(for: [expectation], timeout: 0.3)
//    }
//    
//    func testEventNewUserInDilog() {
//        let subject = PassthroughSubject<RemoteEvent, Never>()
//        let reposytory = repository(mock: [:],
//                                    event: subject.eraseToAnyPublisher())
//        
//        let expectation = expectation(description: "new dialog")
//        reposytory.remoteEventPublisher.sink { event in
//            switch event {
//            case .create(_):
//                XCTFail("Unexpected event")
//            case .update(inDialogWith: let id):
//                XCTAssertEqual(id, Test.dialogId)
//            case .leave(_,_):
//                XCTFail("Unexpected event")
//            case .newMessage(_):
//                XCTFail("Unexpected event")
//            case .history( _, _):
//                XCTFail("Unexpected event")
//            }
//            expectation.fulfill()
//        }.store(in: &cancellables)
//        
//        subject.send(RemoteEvent.update(Test.dialogId))
//        wait(for: [expectation], timeout: 0.3)
//    }
//    
//    func testEventNewMessageInDilog() {
//        let subject = PassthroughSubject<RemoteEvent, Never>()
//        let reposytory = repository(mock: [:],
//                                    event: subject.eraseToAnyPublisher())
//        
//        let expectation = expectation(description: "new dialog")
//        reposytory.remoteEventPublisher.sink { event in
//            switch event {
//            case .create(_):
//                XCTFail("Unexpected event")
//            case .update(_):
//                XCTFail("Unexpected event")
//            case .leave(_,_):
//                XCTFail("Unexpected event")
//            case .newMessage(let message):
//                XCTAssertEqual(message, Message.newMessage)
//            case .history( _, _):
//                XCTFail("Unexpected event")
//            }
//            expectation.fulfill()
//        }.store(in: &cancellables)
//        
//        subject.send(RemoteEvent.newMessage(RemoteMessageDTO.newMessage))
//        wait(for: [expectation], timeout: 0.3)
//    }
//}
//
////MARK: Utils
//extension DialogsRepositoryTests {
//    private func repository(
//        mock results: [String: Result<[Any], Error>],
//        event: AnyPublisher<RemoteEvent, Never> =
//        PassthroughSubject<RemoteEvent, Never>().eraseToAnyPublisher()
//    ) -> DialogsRepository {
//        DialogsRepository(remote: RemoteDataSourceMock(results,
//                                                       eventPublisher: event),
//                          local: LocalDataSource())
//    }
//}
