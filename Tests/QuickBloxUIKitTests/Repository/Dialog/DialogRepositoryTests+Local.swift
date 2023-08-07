////
////  DialogRepositoryTests+Local.swift
////  QuickBloxUIKitTests
////
////  Created by Injoit on 01.02.2023.
////  Copyright © 2023 QuickBlox. All rights reserved.
////
//
//import XCTest
//
//@testable import QuickBloxDomain
//@testable import QuickBloxData
//
////MARK: Utils
//extension DialogsRepositoryTests {
//     private func repository(mock result: Result<[Any], Error>) -> DialogsRepository {
//        DialogsRepository(remote: RemoteDataSource(), local: LocalDataSourceMock(result))
//    }
//}
//
////MARK: Save Dialog
//extension DialogsRepositoryTests {
//    func testSaveDialogInLocal() async throws {
//        let result = [LocalDialogDTO.default]
//        let repository = repository(mock: .success(result))
//
//        let entity = Dialog.default
//        try await repository.save(dialogToLocal: entity)
//        let dialog = try await repository.get(dialogFromLocal: Test.stringId)
//        XCTAssertFalse(dialog.id.isEmpty)
//        XCTAssertEqual(dialog.type, entity.type)
//        XCTAssertEqual(dialog.id, entity.id)
//        XCTAssertEqual(dialog.participantsIds, entity.participantsIds)
//    }
//    
//    func testSaveDialogInLocalAlreadyExist() async throws {
//        let repository = repository(mock: .failure(DataSourceException.alreadyExist()))
//        
//        await XCTAssertThrowsException(
//            try await repository.save(dialogToLocal: Dialog.default),
//            equelTo: RepositoryException.alreadyExist())
//    }
//}
//
////MARK: Save Dialogs
//extension DialogsRepositoryTests {
//    func testSaveDialogsInLocal() async throws {
//        let result = LocalDialogsDTO(dialogs: [
//            LocalDialogDTO.default,
//            LocalDialogDTO.withEmptyId
//        ])
//        
//        let repository = repository(mock: .success([result]))
//        
//        let entities = [
//            Dialog.default,
//            Dialog.withEmptyId
//        ]
//        
//        try await XCTAssertNoThrowsException(
//            try await repository.save(dialogsToLocal: entities)
//        )
//    }
//}
//
////MARK: Update Dialog
//extension DialogsRepositoryTests {
//    func testUpdateDialogInLocal() async throws {
//        let mockEntity = LocalDialogDTO(id: Test.stringId,
//                                        type: .private,
//                                        name: Test.updatedName,
//                                        participantsIds: Test.updatedStringIds)
//        let mockResult = [mockEntity]
//        let repository = repository(mock: .success(mockResult))
//
//        let entity = Dialog.default
//        try await repository.save(dialogToLocal: entity)
//        
//        var toUpdate = Dialog.default
//        toUpdate.name = Test.updatedName
//        toUpdate.participantsIds = Test.updatedStringIds
//
//        try await repository.update(dialogInLocal: toUpdate)
//        let result = try await repository.get(dialogFromLocal: toUpdate.id)
//
//        XCTAssertFalse(result.id.isEmpty)
//        XCTAssertEqual(toUpdate.name, result.name)
//        XCTAssertEqual(toUpdate.participantsIds, result.participantsIds)
//    }
//    
//    func testUpdateDialogInLocalNotFound() async throws {
//        let repository = repository(mock: .failure(DataSourceException.notFound()))
//        
//        await XCTAssertThrowsException(
//            try await repository.update(dialogInLocal: Dialog.default),
//            equelTo: RepositoryException.notFound())
//    }
//}
//
////MARK: Get Dialog
//extension DialogsRepositoryTests {
//    func testGetDialogFromLocal() async throws {
//        let mockResult = [LocalDialogDTO.default]
//        let repository = repository(mock: .success(mockResult))
//
//        let entity = Dialog.default
//        try await repository.save(dialogToLocal: entity)
//        let result = try await repository.get(dialogFromLocal: Test.stringId)
//        XCTAssertFalse(result.id.isEmpty)
//        XCTAssertEqual(entity.type, result.type)
//        XCTAssertEqual(entity.id, result.id)
//    }
//    
//    func testGetDialogFromLocalNotFound() async throws {
//        let repository = repository(mock: .failure(DataSourceException.notFound()))
//        
//        await XCTAssertThrowsException(
//            try await repository.get(dialogFromLocal: Test.stringId),
//            equelTo: RepositoryException.notFound())
//    }
//}
//
////MARK: Delete Dialog
//extension DialogsRepositoryTests {
//    func testDeleteDialogFromLocal() async throws {
//        let repository = repository(mock: .success([]))
//
//        let entity = Dialog.default
//        try await repository.save(dialogToLocal: entity)
//        try await repository.delete(dialogFromLocal: Test.stringId)
//    }
//    
//    func testDeleteDialogFromLocalNotFound() async throws {
//        let repository = repository(mock: .failure(DataSourceException.notFound()))
//        
//        await XCTAssertThrowsException(
//            try await repository.delete(dialogFromLocal: Test.stringId),
//            equelTo: RepositoryException.notFound())
//    }
//}
//
////MARK: Get Dialogs
//extension DialogsRepositoryTests {
//    func testGetDialogsFromLocal() async throws {
//        let repository = repository(mock: .success([LocalDialogsDTO.default]))
//
//        try await repository.save(dialogToLocal: Dialog.default)
//        let result = try await repository.getAllDialogsFromLocal()
//        XCTAssertEqual(result.count, LocalDialogsDTO.default.dialogs.count)
//    }
//}
//
//extension DialogsRepositoryTests {
//    func testRemoveAllDialogsFromLocal() async throws {
//        let repository = repository(mock: .failure(DataSourceException.notFound()))
//        
//        await XCTAssertThrowsException(
//            try await repository.removeAllDialogsFromLocal(),
//            equelTo: RepositoryException.notFound()
//        )
//    }
//}
//
////MARK: Subscribe
//extension DialogsRepositoryTests {
//    func testSubscribeToLocal() async {
//        let repository = repository(mock: .success([]))
//        let sub = await repository.localDialogsPublisher
//        XCTAssertNotNil(sub)
//    }
//}
