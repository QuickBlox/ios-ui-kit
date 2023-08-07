//
//  MessageRepositoryTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
@testable import QuickBloxData

extension Message {
    static var `default` =
    Message(id: MessageRepositoryTests.Test.stringId, dialogId: MessageRepositoryTests.Test.dialogId, text: "", userId: "2a3b4c5d6e", date: Date())
    
//    Message(id: MessageRepositoryTests.Test.stringId, dialogId: MessageRepositoryTests.Test.dialogId)
    
    static var withEmptyId =  Message(id: "", dialogId: MessageRepositoryTests.Test.dialogId, text: "", userId: "2a3b4c5d6e", date: Date())
    static var withEmptyDialogId =  Message(id: MessageRepositoryTests.Test.stringId, dialogId: "", text: "", userId: "2a3b4c5d6e", date: Date())
    
    static var newMessage = Message (
        id: MessageRepositoryTests.Test.stringId,
        dialogId: MessageRepositoryTests.Test.dialogId,
        text: MessageRepositoryTests.Test.text,
        userId: MessageRepositoryTests.Test.senderId,
        date: MessageRepositoryTests.Test.date,
//        customParameters: MessageRepositoryTests.Test.params,
        isOwnedByCurrentUser: MessageRepositoryTests.Test.isOwnedByCurrentUser
    )
}

extension RemoteMessageDTO {
    static var newMessage = RemoteMessageDTO(
        id: MessageRepositoryTests.Test.stringId,
        dialogId: MessageRepositoryTests.Test.dialogId,
        text: MessageRepositoryTests.Test.text,
        senderId: MessageRepositoryTests.Test.senderId,
        dateSent: MessageRepositoryTests.Test.date,
        customParameters: MessageRepositoryTests.Test.params,
        isOwnedByCurrentUser: MessageRepositoryTests.Test.isOwnedByCurrentUser
    )
    
    static var `default` =
    RemoteMessageDTO(id: MessageRepositoryTests.Test.stringId, dialogId: MessageRepositoryTests.Test.dialogId, text: "")
    
    static var withEmptyId =  RemoteMessageDTO(id: "", dialogId: MessageRepositoryTests.Test.dialogId, text: "")
    static var withEmptyDialogId =  RemoteMessageDTO(id: MessageRepositoryTests.Test.stringId, dialogId: "", text: "")
}

final class MessageRepositoryTests: XCTestCase {
    typealias MockMethod = RemoteDataSourceMock.MockMethod
    
    struct Test {
        // id
        static let stringId = "1a2b3c4d5e"
        static let dialogId = "a1b2c3d4e5"
        // ids
        static let stringIds = ["2a3b4c5d6e", "3a4b5c6d7e", "4a5b6c7d8e"]
        
        static let text = "TestMessageText"
        static let senderId = "b2c3d4e5f6"
        static let date = Date()
        static let isOwnedByCurrentUser = true
        static let params: [String: String] = ["CustomKey": "CustomValue"]
    }
}
