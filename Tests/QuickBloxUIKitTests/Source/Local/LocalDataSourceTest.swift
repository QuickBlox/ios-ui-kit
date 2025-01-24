//
//  LocalDataSourceTest.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 21.12.2022.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import XCTest
import Combine

@testable import QuickBloxData
@testable import QuickBloxDomain

extension LocalDialogDTO {
    static var `default` =
    LocalDialogDTO(id: LocalDataSourceTest.Test.stringId, participantsIds: ["1", "2"])
    
    static var withEmptyId = LocalDialogDTO(id: "")
}

extension LocalMessageDTO {
    static var `default` =
    LocalMessageDTO(id: LocalDataSourceTest.Test.stringId,
                    dialogId: LocalDataSourceTest.Test.dialogId)
    
    static var withEmptyId =
    LocalMessageDTO(id: "", dialogId: LocalDataSourceTest.Test.dialogId)
    static var withEmptyDialogId =
    LocalMessageDTO(id: LocalDataSourceTest.Test.stringId)
}

extension LocalMessagesDTO {
    static var `default` =
    LocalMessagesDTO(dialogId: LocalDataSourceTest.Test.dialogId,
                     messages: [LocalMessageDTO.default])
    static var withEmptyMessages =
    LocalMessagesDTO(dialogId: LocalDataSourceTest.Test.dialogId)
}

extension LocalDialogsDTO {
    static var `default` = LocalDialogsDTO(dialogs: [
        LocalDialogDTO.default,
        LocalDialogDTO.withEmptyId
    ])
    static var withEmptyDialogs = LocalDialogsDTO()
}

extension LocalUserDTO {
    static var `default` = LocalUserDTO(id: UsersRepositoryTests.Test.stringId,
                                        name: "")
    static var bob = LocalUserDTO(id: UsersRepositoryTests.Test.stringIds[1],
                                  name: "Bob")
    static var alice = LocalUserDTO(id: UsersRepositoryTests.Test.stringIds[2],
                                    name: "Alice")
    static var john = LocalUserDTO(id: UsersRepositoryTests.Test.stringIds[3],
                                   name: "John")
    
    static var participants = [
        LocalUserDTO.bob.id: LocalUserDTO.bob,
        LocalUserDTO.alice.id: LocalUserDTO.alice,
        LocalUserDTO.john.id: LocalUserDTO.john,
    ]
}

struct TestException {
    static let expected = "did not throw an error"
    static let undefined = "an error is undefined"
}

//FIXME: rename LocalDataSourceTest to LocalDataSourceTests
class LocalDataSourceTest: XCTestCase {
    
    struct Test {
        // id
        static let stringId = "1a2b3c4d5e"
        static let updatedStringId = "2b3c4d5e6f"
        // ids
        static let singleStringids  = ["a1b2c3d4e5"]
        static let emptyStringids   = [String]()
        static let stringids        = ["2a3b4c5d6e", "3a4b5c6d7e", "4a5b6c7d8e"]
        static let stringableIntids = ["1234567", "2345678", "3456789"]
        static let updatedStringableIntIds = [
            "456789",
            "5678912",
            "6789122"
        ]
        
        static let mixStringids     = [""] + stringableIntids + stringids
        
        static let name = "TestName"
        static let updatedName = "NameToUpdate"
        
        static let photo = "TestPhoto"
        static let updatedPhoto = "PhotoToUpdate"
        
        static let date = Calendar.current.date(byAdding: .day,
                                                value: -1,
                                                to: Date())!
        static let updatedDate = Date()
        
        static let unreadCount = 4
        static let updatedCount = 12
        
        static let messageId = "TestMessageId"
        static let messageText = "TestMessageText"
        static let messageDateSent = Test.date
        static let messageUserId = "MessageUserId"
        
        static let updatedMId = "TestMessageIdToUpdate"
        static let updatedMText = "TestMessageTextToUpdate"
        static let updatedMDateSent = Test.updatedDate
        static let updatedMUserId = "MessageUserIdToUpdate"
        
        static let updatedText = "TextToUpdate"
        
        /// not equel to stringId
        static let dialogId = "a1b2c3d4e5"
        static let dialogType: DialogType = .private
        static let updatedDialogType: DialogType = .public
    }
    
    var storage: LocalDataSource!
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        storage = LocalDataSource()
    }
    
    override func tearDownWithError() throws {
        storage = nil
        try super.tearDownWithError()
    }
}

//MARK: Utils Dialog
extension LocalDataSourceTest {
    func saveAndGet(dialogWithId id: String) async throws -> LocalDialogDTO {
        let dialog = LocalDialogDTO(id: id,
                                    type: Test.dialogType,
                                    name: Test.name,
                                    participantsIds: Test.stringableIntids,
                                    photo: Test.photo,
                                    updatedAt: Test.date,
                                    lastMessageId: Test.messageId,
                                    lastMessageText: Test.messageText,
                                    lastMessageDateSent: Test.messageDateSent,
                                    lastMessageUserId: Test.messageUserId,
                                    unreadMessagesCount: Test.unreadCount)
        try await storage.save(dialog: dialog)
        let savedDialog = try await storage.get(dialog: LocalDialogDTO(id: id))
        XCTAssertEqual(savedDialog, dialog)
        
        return savedDialog
    }
}

//MARK: Message Utils
extension LocalDataSourceTest {
    func createAndSaveMessage() async throws -> LocalMessageDTO {
        return try await createAndSave(messageWithId: Test.stringId)
    }
    
    func createAndSave(messageWithId id: String) async throws -> LocalMessageDTO {
        try await storage.save(dialog: LocalDialogDTO(id:Test.dialogId))
        let message = LocalMessageDTO(id: id, dialogId: Test.dialogId, text: "")
        try await storage.save(message: message)
        guard let savedMessage = try await storage.get(messages: LocalMessagesDTO(dialogId: Test.dialogId)).messages.filter({ $0.id == id }).first else {
            throw DataSourceException.notFound()
        }
        XCTAssertEqual(savedMessage, message)
        
        return savedMessage
    }
}

//MARK: Utils User
extension LocalDataSourceTest {
    func createAndSaveUser() async throws -> LocalUserDTO {
        return try await createAndSave(userWithId: Test.stringId)
    }
    
    func createAndSave(userWithId id: String) async throws -> LocalUserDTO {
        let user = LocalUserDTO(id: id)
        
        await XCTAssertThrowsException(try await storage.get(user: user),
                                       equelTo: DataSourceException.notFound())
        
        try await XCTAssertNoThrowsException(try await storage.save(user: user))
        
        
        
        let savedUser = try await storage.get(user: user)
        XCTAssertEqual(savedUser, user)
        
        return savedUser
    }
}

//MARK: Clear
extension LocalDataSourceTest {
    func testClearAll() async throws {
        let dialog = try await saveAndGet(dialogWithId: Test.stringId)
        let message = try await createAndSaveMessage()
        let user = try await createAndSaveUser()
        
        try await storage.cleareAll()
        
        await XCTAssertThrowsException(
            try await storage.get(dialog: dialog),
            equelTo: DataSourceException.notFound()
        )
        
        await XCTAssertThrowsException(
            try await storage.update(message: message),
            equelTo: DataSourceException.notFound()
        )
        
        await XCTAssertThrowsException(
            try await storage.get(user: user),
            equelTo: DataSourceException.notFound())
    }
}
