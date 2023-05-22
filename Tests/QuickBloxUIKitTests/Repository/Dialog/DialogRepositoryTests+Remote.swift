////
////  DialogRepositoryTests+Remote.swift
////  QuickBloxUIKitTests
////
////  Created by Injoit on 23.01.2023.
////  Copyright © 2023 QuickBlox. All rights reserved.
////
//
//import XCTest
//import Combine
//@testable import QuickBloxDomain
//@testable import QuickBloxData
//
////MARK: Utils
//extension DialogsRepositoryTests {
//     private func repository(mock results: [String: Result<[Any], Error>]) -> DialogsRepository {
//        DialogsRepository(remote: RemoteDataSourceMock(results), local: LocalDataSource())
//    }
//}
//
////MARK: Create Dialogs
//extension DialogsRepositoryTests {
//    func testCreateDialogInRemote() async throws {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.createDialog: .success([RemoteDialogDTO.default])]
//        let entity = Dialog.default
//        let dialog = try await
//        repository(mock: results).create(dialogInRemote: entity)
//        XCTAssertEqual(dialog.type, entity.type)
//    }
//    
//    func testCreateDialogWithNegativeCases() async throws {
//        try await
//        createThrow(exception: .unauthorised(),
//                    withMock: RemoteDataSourceException.unauthorised())
//        try await
//        createThrow(exception: .incorrectData(),
//                    withMock: RemoteDataSourceException.incorrectData())
//    }
//    
//    private func createThrow(exception: RepositoryException,
//                             withMock result: Error) async throws  {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.createDialog: .failure(result)]
//        let repository = repository(mock: results)
//        
//        await XCTAssertThrowsException(
//            try await repository.create(dialogInRemote: Dialog.withEmptyId),
//            equelTo: exception
//        )
//    }
//}
//
////MARK: Update Dialog
//extension DialogsRepositoryTests {
//    func testUpdateDialogInRemote() async throws {
//        let mockEntity = RemoteDialogDTO(id: Test.stringId,
//                                         type: .private,
//                                         name: Test.name,
//                                         participantsIds: Test.stringableIntIds)
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.updateDialog: .success([mockEntity])]
//
//        var entity = Dialog.default
//        entity.name = Test.name
//        entity.participantsIds = Test.stringableIntIds
//
//        let dialog = try await
//        repository(mock: results).update(dialogInRemote: entity, users: [])
//        
//        XCTAssertEqual(dialog.name, entity.name)
//        XCTAssertEqual(dialog.participantsIds, entity.participantsIds)
//    }
//
//    func testUpdateDialogWithNegativeCases() async throws {
//        try await
//        updateThrow(exception: .unauthorised(),
//                    withMock: RemoteDataSourceException.unauthorised())
//        try await
//        updateThrow(exception: .incorrectData(),
//                    withMock: RemoteDataSourceException.incorrectData())
//        try await
//        updateThrow(exception: .restrictedAccess(),
//                    withMock: RemoteDataSourceException.restrictedAccess())
//    }
//
//    private func updateThrow(exception: RepositoryException,
//                             withMock result: Error) async throws  {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.updateDialog: .failure(result)]
//        let repository = repository(mock: results)
//
//        await XCTAssertThrowsException(
//            try await repository.update(dialogInRemote: Dialog.default,
//                                        users: []),
//            equelTo: exception
//        )
//    }
//}
//
////MARK: Get Dialog
//extension DialogsRepositoryTests {
//    func testGetDialogFromRemote() async throws {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.getDialog: .success([RemoteDialogDTO.default])]
//        let repository = repository(mock: results)
//
//        let dialog = try await repository.get(dialogFromRemote: Test.stringId)
//        XCTAssertEqual(dialog.id, Test.stringId)
//    }
//
//    func testGetDialogFromRemoteNegativeCases() async throws {
//        try await
//        getThrow(exception: .unauthorised(), withMock: RemoteDataSourceException.unauthorised())
//        try await
//        getThrow(exception: .notFound(), withMock: DataSourceException.notFound())
//    }
//
//    private func getThrow(exception: RepositoryException,
//                          withMock result: Error) async throws {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.getDialog: .failure(result)]
//        let repository = repository(mock: results)
//
//        await XCTAssertThrowsException(
//            try await repository.get(dialogFromRemote: Test.stringId),
//            equelTo: exception)
//    }
//}
//
////MARK: Delete Dialog
//extension DialogsRepositoryTests {
//    func testDeleteDialogFromRemote() async throws {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.deleteDialog: .success([])]
//        let repository = repository(mock: results)
//
//        let entity = Dialog.default
//        try await repository.delete(dialogFromRemote: entity)
//    }
//
//    func testDeleteDialogFromRemoteNegativeCases() async throws {
//        try await
//        deleteDialogThrow(exception: .notFound(), withMock: DataSourceException.notFound())
//        try await
//        deleteDialogThrow(exception: .restrictedAccess(), withMock: RemoteDataSourceException.restrictedAccess())
//    }
//
//    private func deleteDialogThrow(exception: RepositoryException,
//                          withMock result: Error) async throws {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.deleteDialog: .failure(result)]
//        let repository = repository(mock: results)
//
//        let entity = Dialog.default
//        await XCTAssertThrowsException(
//            try await repository.delete(dialogFromRemote: entity),
//            equelTo: exception)
//    }
//}
//
////MARK: Get Dialogs
//extension DialogsRepositoryTests {
//    func testGetAllDialogsFromeRemoteNotFound() async throws {
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.getDialogs: .failure(DataSourceException.notFound())]
//        let repository = repository(mock: results)
//        
//        await XCTAssertThrowsException(
//            try await repository.getAllDialogsFromRemote(),
//            equelTo: RepositoryException.notFound())
//    }
//    
//    func testGetAllDialogsFromeRemote() async throws {
//        let mockEntity = RemoteDialogsDTO(dialogs: [RemoteDialogDTO.default])
//        let results: [String: Result<[Any], Error>] =
//        [MockMethod.getDialogs: .success([mockEntity])]
//        let repository = repository(mock: results)
//        
//        let dialogs = try await repository.getAllDialogsFromRemote()
//        XCTAssertEqual(dialogs.count, 1)
//    }
//}
//
////MARK: Subscribe
////extension DialogsRepositoryTests {
////    func testSubscribeToRemote() {
////        let repository = repository(mock: [:])
////        let sub = repository.remoteEventPublisher
////        XCTAssertNotNil(sub)
////    }
////}
