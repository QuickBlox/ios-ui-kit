//
// LocalDataSourceTest+Dialog.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 21.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest

@testable import QuickBloxDomain
@testable import QuickBloxData

//MARK: Save Dialog
extension LocalDataSourceTest {
    func testSaveDialogAlreadyExist() async throws {
        await storage.dialogsPublisher
            .dropFirst()
            .sink { dialogs in
                let dialog = dialogs.first(where: { $0.id == Test.stringId })
            XCTAssertEqual(dialog, LocalDialogDTO.default)
        }
        .store(in: &cancellables)
        
        _ = try await storage.save(dialog: LocalDialogDTO.default)
        
        await XCTAssertThrowsException(
            try await storage.save(dialog: LocalDialogDTO.default),
            equelTo: DataSourceException.alreadyExist()
        )
    }
}

//MARK: Get Dialog
extension LocalDataSourceTest {
    func testGetDialogNotFound() async throws {
        await XCTAssertThrowsException(
            try await storage.get(dialog: LocalDialogDTO.default),
            equelTo: DataSourceException.notFound()
        )
    }
}

//MARK: Update Dialogs
extension LocalDataSourceTest {
    func testUpdateDialogName() async throws {
        let saved = try await saveAndGet(dialogWithId: Test.stringId)
        
        await storage.dialogsPublisher
            .dropFirst()
            .sink { dialogs in
            let dialog = dialogs.first(where: { $0.id == Test.stringId })
                XCTAssertEqual(dialog?.name, Test.updatedName)
        }
        .store(in: &cancellables)
        
        try await storage.update(dialog: LocalDialogDTO(id: Test.stringId,
                                                        type: .private,
                                                        name: Test.updatedName))
        
        let updated = try await storage.get(dialog: saved)
        XCTAssertEqual(Test.updatedName, updated.name)
        XCTAssertNotEqual(saved.name, updated.name)
        
        XCTAssertEqual(saved.participantsIds, updated.participantsIds)
    }
    
    func testUpdateDialogParticipantsIds() async throws {
        let saved = try await saveAndGet(dialogWithId: Test.stringId)
        try await storage.update(
            dialog: LocalDialogDTO(id: Test.stringId,
                                   type: .private,
                                   participantsIds: Test.updatedStringableIntIds)
        )
        let result = try await storage.get(dialog: saved)
        XCTAssertEqual(Test.updatedStringableIntIds, result.participantsIds)
        XCTAssertNotEqual(saved.participantsIds, result.participantsIds)
    }
    
    func testUpdateDialogPhoto() async throws {
        let saved = try await saveAndGet(dialogWithId: Test.stringId)
        
        await storage.dialogsPublisher
            .dropFirst()
            .sink { dialogs in
            let dialog = dialogs.first(where: { $0.id == Test.stringId })
                XCTAssertEqual(dialog?.photo, Test.updatedPhoto)
        }
        .store(in: &cancellables)
        
        try await storage.update(
            dialog: LocalDialogDTO(id: Test.stringId,
                                   type: .private,
                                   photo: Test.updatedPhoto)
        )
        
        let updated = try await storage.get(dialog: saved)
        XCTAssertEqual(Test.updatedPhoto, updated.photo)
        XCTAssertNotEqual(saved.photo, updated.photo)
    }
    
    func testUpdateDialogUpdatedAt() async throws {
        let saved = try await saveAndGet(dialogWithId: Test.stringId)
        
        await storage.dialogsPublisher
            .dropFirst()
            .sink { dialogs in
            let dialog = dialogs.first(where: { $0.id == Test.stringId })
                XCTAssertEqual(dialog?.updatedAt, Test.updatedDate)
        }
        .store(in: &cancellables)
        
        try await storage.update(
            dialog: LocalDialogDTO(id: Test.stringId,
                                   type: .private,
                                   updatedAt: Test.updatedDate)
        )
        
        let updated = try await storage.get(dialog: saved)
        XCTAssertEqual(Test.updatedDate, updated.updatedAt)
        XCTAssertNotEqual(saved.updatedAt, updated.updatedAt)
    }
    
    func testUpdateDialogUnreadCount() async throws {
        let saved = try await saveAndGet(dialogWithId: Test.stringId)
        
        await storage.dialogsPublisher
            .dropFirst()
            .sink { dialogs in
            let dialog = dialogs.first(where: { $0.id == Test.stringId })
                XCTAssertEqual(dialog?.unreadMessagesCount, Test.updatedCount)
        }
        .store(in: &cancellables)
        
        try await storage.update(
            dialog: LocalDialogDTO(id: Test.stringId,
                                   type: .private,
                                   unreadMessagesCount: Test.updatedCount)
        )
        
        let updated = try await storage.get(dialog: saved)
        XCTAssertEqual(Test.updatedCount, updated.unreadMessagesCount)
        XCTAssertNotEqual(saved.unreadMessagesCount, updated.unreadMessagesCount)
    }
    
    func testUpdateDialogLastMessage() async throws {
        let saved = try await saveAndGet(dialogWithId: Test.stringId)
        
        await storage.dialogsPublisher
            .dropFirst()
            .sink { dialogs in
            let dialog = dialogs.first(where: { $0.id == Test.stringId })
                XCTAssertEqual(dialog?.lastMessageId, Test.updatedMId)
                XCTAssertEqual(dialog?.lastMessageText, Test.updatedMText)
                XCTAssertEqual(dialog?.lastMessageDateSent,
                               Test.updatedMDateSent)
                XCTAssertEqual(dialog?.lastMessageUserId, Test.updatedMUserId)
        }
        .store(in: &cancellables)
        
        try await storage.update(
            dialog: LocalDialogDTO(id: Test.stringId,
                                   type: .private,
                                   lastMessageId: Test.updatedMId,
                                   lastMessageText: Test.updatedMText,
                                   lastMessageDateSent: Test.updatedMDateSent,
                                   lastMessageUserId: Test.updatedMUserId)
        )
        
        let updated = try await storage.get(dialog: saved)
        XCTAssertEqual(Test.updatedMId, updated.lastMessageId)
        XCTAssertNotEqual(saved.lastMessageId, updated.lastMessageId)
        
        XCTAssertEqual(Test.updatedMText, updated.lastMessageText)
        XCTAssertNotEqual(saved.lastMessageText, updated.lastMessageText)
        
        XCTAssertEqual(Test.updatedMDateSent, updated.lastMessageDateSent)
        XCTAssertNotEqual(saved.lastMessageDateSent, updated.lastMessageDateSent)
        
        XCTAssertEqual(Test.updatedMUserId, updated.lastMessageUserId)
        XCTAssertNotEqual(saved.lastMessageUserId, updated.lastMessageUserId)
    }
    
    func testUpdateDialogNotFound() async throws {
        await XCTAssertThrowsException(
            try await storage.update(dialog: LocalDialogDTO.default),
            equelTo: DataSourceException.notFound()
        )
    }
}

//MARK: Delete Dialog
extension LocalDataSourceTest {
    func testDeleteDialog() async throws {
        let saved = try await saveAndGet(dialogWithId: Test.stringId)
        try await storage.delete(dialog: saved)
        
        await XCTAssertThrowsException(
            try await storage.get(dialog:  LocalDialogDTO.default),
            equelTo: DataSourceException.notFound()
        )
    }
    
    func testDeleteDialogNotFound() async throws {
        await XCTAssertThrowsException(
            try await storage.delete(dialog:  LocalDialogDTO.default),
            equelTo: DataSourceException.notFound()
        )
    }
}

//MARK: Get Dialogs
extension LocalDataSourceTest {
    func testGetDialogsWithEmptyStorage() async throws {
        let dialogs = try await storage.getAllDialogs().dialogs
        XCTAssertEqual(dialogs.count, 0)
    }
    
    func testGetDialogs() async throws {
        _ = try await storage.save(dialog: LocalDialogDTO.default)
        
        let dialogs = try await storage.getAllDialogs().dialogs
        XCTAssertEqual(dialogs.count, 1)
    }
}

//MARK: Remove All Dialogs
extension LocalDataSourceTest {
    func testRemoveAllDialogs() async throws {
        _ = try await storage.save(dialog: LocalDialogDTO.default)
        try await storage.removeAllDialogs()
        let dialogs = try await storage.getAllDialogs().dialogs
        XCTAssertEqual(dialogs.count, 0)
    }
}
