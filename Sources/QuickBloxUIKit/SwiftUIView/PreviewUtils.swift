//
//  PreviewUtils.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func previewSettings(layout: PreviewLayout = .sizeThatFits,
                         scheme: ColorScheme = .light,
                         name: String) -> some View {
        self
            .previewLayout(layout)
            .preferredColorScheme(scheme)
            .previewDisplayName(name)
    }
}

struct PreviewDialog: DialogEntity {
    public let id: String
    public let type: DialogType
    
    public var name: String
    public var participantsIds: [String]
    public var participants: [User] = []
    public var photo: String
    public var ownerId: String
    public var isOwnedByCurrentUser = false
    public var createdAt: Date
    public var updatedAt: Date
    public var lastMessage = LastMessage(id: "",
                                         text: "",
                                         userId: "")
    public var messages: [Message] = []
    public var unreadMessagesCount: Int
    public var decrementCounter: Bool = false
    
    public init(id: String = "",
                type: DialogType,
                name: String = "",
                participantsIds: [String] = [],
                participants: [User] = [],
                photo: String = "",
                ownerId: String = "",
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                lastMessage: LastMessage =
                LastMessage(id: "",
                            text: "",
                            userId: ""),
                messages: [Message] = [],
                unreadMessagesCount: Int = 0,
                decrementCounter: Bool = false) {
        self.id = id
        self.type = type
        self.name = name
        self.participantsIds = participantsIds
        self.photo = photo
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastMessage = lastMessage
        self.messages = messages
        self.unreadMessagesCount = unreadMessagesCount
        self.decrementCounter = decrementCounter
    }
    
    //MARK: mock dialogs actions
    var avatar: Image {
        get async throws {
            print("OVERIDED")
            return placeholder
        }
    }
}

struct PreviewModel {
    static var customTheme: Theme {
        let theme = Theme()
        theme.color.mainElements = .orange
        theme.color.mainText = .yellow
        theme.color.mainBackground = .brown
        theme.color.secondaryText = .green
        
        return theme
    }
    
    static var privateDialog: PreviewDialog {
        PreviewDialog(id:"1a2b3c4d",
                      type: .private,
                      name: "Private Dialog",
                      lastMessage: LastMessage(id: "123456",
                                               text: "I'm not even going to pretend to understand what you're talking about.",
                                               dateSent: Date(),
                                               userId: "23456"))
    }
    
    static var groupDialog: PreviewDialog {
        PreviewDialog(id:"2b3c4d5e",
                      type: .group,
                      name: "Group Dialog",
                      ownerId: "2b3c4d5e",
                      lastMessage: LastMessage(id: "123456",
                                               text: "I'm not even going to pretend to understand what you're talking about.",
                                               dateSent: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                               userId: "23456"),
                      unreadMessagesCount: 1)
    }
    
    static var shortTextGroupDialog: PreviewDialog {
        PreviewDialog(id:"2b3c4d5e6f",
                      type: .group,
                      name: "Group Dialog",
                      ownerId: "2b3c4d5e6f7g",
                      lastMessage: LastMessage(id: "123456",
                                               text: "Short text",
                                               dateSent: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                               userId: "23456"),
                      unreadMessagesCount: 1)
    }
    
    static var longNameGroupDialog: PreviewDialog {
        PreviewDialog(id:"2b3c4d5e6f7g",
                      type: .group,
                      name: "Group Dialog with very big name",
                      ownerId: "2b3c4d5e6f7g8r9h",
                      lastMessage: LastMessage(id: "123456",
                                               text: "Short text",
                                               dateSent: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                               userId: "23456"),
                      unreadMessagesCount: 1)
    }
    
    static var publicDialog: PreviewDialog {
        PreviewDialog(id:"3c4d5e6f",
                      type: .public,
                      name: "Public Dialog",
                      lastMessage: LastMessage(id: "123456",
                                               text: "I'm not even going to pretend to understand what you're talking about.",
                                               dateSent: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                                               userId: "23456"),
                      unreadMessagesCount: 2)
    }
    
    static var oldMessagePublicDialog: PreviewDialog {
        PreviewDialog(id:"3c4d5e6f7g",
                      type: .public,
                      name: "Public Dialog",
                      lastMessage: LastMessage(id: "123456",
                                               text: "I'm not even going to pretend to understand what you're talking about.",
                                               dateSent: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
                                               userId: "23456"),
                      unreadMessagesCount: 2)
    }
    
    static var dialogs: [PreviewDialog] { [
        PreviewModel.privateDialog,
        PreviewModel.groupDialog,
        PreviewModel.publicDialog,
    ] }
    
    static var user1: User {
        User(id:"1a2b3c4d",
             name: "User1")
    }
    
    static var user2: User {
        User(id:"2b3c4d5e",
             name: "User2")
    }
    
    static var user3: User {
        User(id:"2b3c4d5e6f",
             name: "User3")
    }
    
    static var user4: User {
        User(id:"2b3c4d5e6f7g",
             name: "User4")
    }
    
    static var user5: User {
        User(id:"2b3c4d5e6f7g8r",
             name: "User5")
    }
    
    static var user6: User {
        User(id:"2b3c4d5e6f7g8r9h",
             name: "User6")
    }
    
    static var users: [User] {
        [ PreviewModel.user1,
          PreviewModel.user2,
          PreviewModel.user3,
          PreviewModel.user4,
          PreviewModel.user5,
          PreviewModel.user6
        ]
    }
    
    static var selectedUsersIds: [String] {
        [ "2b3c4d5e",
          "2b3c4d5e6f7g",
          "2b3c4d5e6f7g8r9h"
        ]
    }
    
    static var selectedUsers: [User] {
        [ PreviewModel.user2,
          PreviewModel.user4,
          PreviewModel.user6
        ]
    }
}

import QuickBloxData
import QuickBloxDomain

struct PreviewRow: DialogRowView {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogsScreen.dialogRow.avatar.privateAvatar
    
    var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    @State public var dialogAvatar: Image?
    
    var dialog: any DialogEntity
    
    var badgeView: DialogRowBadge?
    var nameView: DialogRowName?
    var avatarView: AvatarView?
    var timeView: DialogRowTime?
    var messageView: DialogRowMessage?
    
    init(_ dialog: any DialogEntity) {
        self.dialog = dialog
    }
    
    public var body: some View {
        contentView
    }
    
    static var `private`: PreviewRow {
        PreviewRow(PreviewModel.privateDialog)
    }
}
