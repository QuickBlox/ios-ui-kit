////
////  RemoteDataSourceTests.swift
////  QuickBloxUIKit
////
////  Created by Injoit on 24.02.2023.
////  Copyright © 2023 QuickBlox. All rights reserved.
////
//
//
//import XCTest
//import Quickblox
//import Combine
//
//@testable import QuickBloxData
//@testable import QuickBloxDomain
//
////FIXME: rename RemoteDataSourceTest to RemoteDataSourceTests
//final class RemoteDataSourceTest: XCTestCase {
//    
//    private struct TestEvent {
//        private struct TestKey {
//            static let type = "notification_type"
//        }
//        
//        private struct TestTypeValue {
//            static let newDialog = "1"
//            static let newUser = "2"
//        }
//        
//        static let newDialog: QBChatMessage = {
//            let mock = QBChatMessage()
//            mock.id = Test.stringId
//            mock.dialogID = Test.dialogId
//            mock.customParameters = [ TestKey.type: TestTypeValue.newDialog ]
//            return mock
//        }()
//        
//        static let newUser: QBChatMessage = {
//            let mock = QBChatMessage()
//            mock.id = Test.stringId
//            mock.dialogID = Test.dialogId
//            mock.customParameters = [ TestKey.type: TestTypeValue.newUser ]
//            return mock
//        }()
//        
//        static let newMessage: QBChatMessage = {
//            let mock = QBChatMessage()
//            mock.id = Test.stringId
//            mock.text = Test.text
//            mock.dialogID = Test.dialogId
//            mock.recipientID = Test.recipientUIntId
//            mock.senderID = Test.senderUIntId
//            mock.senderResource = Test.senderResource
//            mock.date = Test.dateSent
//            let parameters = NSMutableDictionary(dictionary: Test.customParameters)
//            mock.customParameters = parameters
//            mock.attachments = Test.qbAttachments
//            mock.delayed = Test.delayed
//            mock.markable = Test.markable
//            mock.createdAt = Test.createdAt
//            mock.updatedAt = Test.updatedAt
//            mock.deliveredIDs = Test.deliveredNumberIds
//            mock.readIDs = Test.readsNumberIds
//            return mock
//        }()
//    }
//    
//    private struct Test {
//        static let deliveredStrIds = ["123", "234", "345"]
//        static let deliveredNumberIds: [NSNumber] = [123, 234, 345]
//        static let readsStrIds = ["123", "234"]
//        static let readsNumberIds: [NSNumber] = [123, 234]
//        static let updatedAt = Date()
//        static let createdAt = Calendar.current.date(byAdding: .day,
//                                                     value: -1,
//                                                     to: Date())!
//        static let markable = true
//        static let delayed = true
//        static let dtoAttachments: [RemoteFileInfoDTO] = {
//            var attachment = RemoteFileInfoDTO()
//            attachment.id = Test.attachmentId
//            attachment.name = Test.attachmentName
//            attachment.type = Test.attachmentType
//            attachment.path = Test.attachmentUrl
//            return [attachment]
//        }()
//        static let qbAttachments: [QBChatAttachment] = {
//            let attachment = QBChatAttachment()
//            attachment.id = Test.attachmentId
//            attachment.name = Test.attachmentName
//            attachment.type = Test.attachmentType
//            attachment.url = Test.attachmentUrl
//            attachment[Test.customKey] = Test.customValue
//            return [attachment]
//        }()
//        static let customParameters = [Test.customKey: Test.customValue]
//        static let customValue = "customValue"
//        static let customKey = "customKey"
//        static let dateSent = Date()
//        static let senderResource = "Test Sender Resource"
//        static let senderStrId = "2345"
//        static let senderUIntId: UInt = 2345
//        static let recipientStrId = "1234"
//        static let recipientUIntId: UInt = 1234
//        static let stringId = "1a2b3c4d5e"
//        static let dialogId = "2b3c4d5e6f"
//        static let attachmentId = "3c4d5e6f7g"
//        static let attachmentName = "ChatAttachment"
//        static let attachmentType = "AttachmentType"
//        static let attachmentUrl = "AttachmentUrl"
//        static let text = "text"
//    }
//    
//    private var source: RemoteDataSource!
//    private var cancellables: Set<AnyCancellable>!
//    
//    override func setUp() async throws {
//        try await super.setUp()
//        
//        source = RemoteDataSource()
//        cancellables = Set<AnyCancellable>()
//    }
//    
//    override func tearDown() async throws {
//        source = nil
//        cancellables = nil
//        
//        try await super.tearDown()
//    }
//    
//    func testEventNewDialog() {
//        let expectation = expectation(description: "new dialog")
//        expectation.expectedFulfillmentCount = 5
//        
//        source.eventPublisher.sink { event in
//            switch event {
//            case .create(withId: let id):
//                XCTAssertEqual(id, Test.dialogId)
//            case .update(_):
//                XCTFail("Unexpected event")
//            case .leave(_,_):
//                XCTFail("Unexpected event")
//            case .newMessage(let message):
//                XCTAssertEqual(message.dialogId, Test.dialogId)
//            case .history(_):
//                XCTFail("Unexpected event")
//            }
//            expectation.fulfill()
//        }.store(in: &cancellables)
//        
//        // first expectation call
//        source.chatDidReceive(TestEvent.newDialog)
//        // second expectation call
//        source.chatRoomDidReceive(TestEvent.newDialog,
//                                  fromDialogID: Test.dialogId)
//        // third expectation call
//        source.chatDidReceiveSystemMessage(TestEvent.newDialog)
//        
//        wait(for: [expectation], timeout: 0.3)
//    }
//    
//    func testEventNewUserInDialog() {
//        let expectation = expectation(description: "new user")
//        expectation.expectedFulfillmentCount = 5
//        
//        source.eventPublisher.sink { event in
//            switch event {
//            case .create(_):
//                XCTFail("Unexpected event")
//            case .update(withDialogId: let id):
//                XCTAssertEqual(id, Test.dialogId)
//            case .leave(_,_):
//                XCTFail("Unexpected event")
//            case .newMessage(let message):
//                XCTAssertEqual(message.dialogId, Test.dialogId)
//            case .history(_):
//                XCTFail("Unexpected event")
//            }
//            expectation.fulfill()
//        }.store(in: &cancellables)
//        
//        // first expectation call
//        source.chatDidReceive(TestEvent.newUser)
//        // second expectation call
//        source.chatRoomDidReceive(TestEvent.newUser,
//                                  fromDialogID: Test.dialogId)
//        // third expectation call
//        source.chatDidReceiveSystemMessage(TestEvent.newUser)
//        
//        wait(for: [expectation], timeout: 0.3)
//    }
//    
//    func testEventNewMessageInDialog() {
//        let expectation = expectation(description: "new message")
//        expectation.expectedFulfillmentCount = 2
//        
//        source.eventPublisher.sink { event in
//            switch event {
//            case .create(_):
//                XCTFail("Unexpected event")
//            case .leave(_,_):
//                XCTFail("Unexpected event")
//            case .update(_):
//                XCTFail("Unexpected event")
//            case .newMessage(let message):
//                XCTAssertEqual(message.id, Test.stringId)
//                XCTAssertEqual(message.dialogId, Test.dialogId)
//                XCTAssertEqual(message.text, Test.text)
//                XCTAssertEqual(message.recipientId, Test.recipientStrId)
//                XCTAssertEqual(message.senderId, Test.senderStrId)
//                XCTAssertEqual(message.senderResource, Test.senderResource)
//                XCTAssertEqual(message.dateSent, Test.dateSent)
//                XCTAssertEqual(message.customParameters, Test.customParameters)
//                XCTAssertEqual(message.filesInfo, Test.dtoAttachments)
//                XCTAssertEqual(message.delayed, Test.delayed)
//                XCTAssertEqual(message.markable, Test.markable)
//                XCTAssertEqual(message.createdAt, Test.createdAt)
//                XCTAssertEqual(message.updatedAt, Test.updatedAt)
//                XCTAssertEqual(message.deliveredIds, Test.deliveredStrIds)
//                XCTAssertEqual(message.readIds, Test.readsStrIds)
//            case .history(_): 
//                XCTFail("Unexpected event")
//            }
//            expectation.fulfill()
//        }.store(in: &cancellables)
//        
//        // first expectation call
//        source.chatDidReceive(TestEvent.newMessage)
//        // second expectation call
//        source.chatRoomDidReceive(TestEvent.newMessage,
//                                  fromDialogID: Test.dialogId)
//        
//        wait(for: [expectation], timeout: 0.3)
//    }
//}
//
////MARK: Connection
//extension RemoteDataSourceTest {
//    func testConnectionState() async throws {
//        let expectation = expectation(description: "connection")
//        expectation.expectedFulfillmentCount = 8
//        
//        var lastState: ConnectionState = .unauthorized
//        source.connectionPublisher.sink { state in
//            lastState = state
//            switch state {
//            case .unauthorized: expectation.fulfill()
//            case .disconnected: expectation.fulfill()
//            case .connecting: expectation.fulfill()
//            case .connected: expectation.fulfill()
//            }
//        }.store(in: &cancellables)
//        
//        try await source.checkConnection()
//        
//        XCTAssertEqual(lastState, .unauthorized)
//        
//        source.chatDidNotConnectWithError(RemoteDataSourceException.unauthorised())
//        XCTAssertEqual(lastState, .connecting(RepositoryException.unauthorised()))
//        
//        source.chatDidConnect()
//        XCTAssertEqual(lastState, .connected)
//        
//        source.chatDidDisconnectWithError(nil)
//        XCTAssertEqual(lastState, .disconnected())
//        
//        source.chatDidReconnect()
//        XCTAssertEqual(lastState, .connected)
//        
//        NotificationCenter.default.post(Notification(name: .qbLogout))
//        XCTAssertEqual(lastState, .unauthorized)
//        
//        await XCTAssertThrowsException(
//            try await source.connect(),
//            equelTo: RemoteDataSourceException.unauthorised()
//        )
//        XCTAssertEqual(lastState, .unauthorized)
//        
//        try await source.disconnect()
//        XCTAssertEqual(lastState, .unauthorized)
//        
//        await fulfillment(of: [expectation], timeout: 0.3)
//    }
//    
//    func testConnectionUnathorized() async throws {
//        await XCTAssertThrowsException(
//            try await source.connect(),
//            equelTo: RemoteDataSourceException.unauthorised()
//        )
//    }
//    
//    func testDisconnectionWhenUnathorized() async throws {
//        try await source.disconnect()
//    }
//}
