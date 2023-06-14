//
//  UserRowView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 02.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxLog

public enum UserRowType {
    case info
    case add
    case remove
}

public struct UserRowBuilder<Item: UserEntity> {
    @ViewBuilder
    public static func create(row type: UserRowType,
                              wiht user: Item,
                              selected: Bool,
                              isAdmin: Bool = false,
                              ownerId: String = "",
                              onTap: @escaping (_ user: Item) -> Void) ->  some View {
        switch type {
        case .info: UserRow(user,
                            isSelected: selected,
                            onTap: onTap)
        case .add: AddUserRow(user,
                              isSelected: selected,
                              onTap: onTap)
        case .remove: RemoveUserRow(user,
                                    isAdmin: isAdmin,
                                    ownerId: ownerId,
                                    isSelected: selected,
                                    onTap: onTap)
        }
    }
}

public struct UserRow<Item: UserEntity>: View  {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.createDialogScreen.userRow.avatar
    
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow
    
    public var user: Item
    
    public var isSelected: Bool
    
    public var avatarView: AvatarView?
    public var nameView: UserRowName?
    public var checkboxView: Checkbox?
    
    public var onTap: (Item) -> Void
    
    public init(_ user: Item,
                isSelected: Bool,
                onTap: @escaping (_ user: Item) -> Void) {
        self.user = user
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    @ViewBuilder
    public var contentView: some View {
        HStack(spacing: settings.spacing) {
            avatarView ?? AvatarView(image: avatar,
                                     height: settings.contentHeight,
                                     isShow: true )
            
            nameView ?? UserRowName(text: user.name)
            Spacer()
            checkboxView ?? Checkbox(isSelected: isSelected, onTap: {
                onTap(user)
            })
        }
        .padding(settings.padding)
        .frame(height: settings.height)
        .background(settings.backgroundColor)
    }
    
    public var body: some View {
        contentView.task {
            do { avatar = try await user.avatar } catch { prettyLog(error) }
        }
    }
}

public struct RemoveUserRow<Item: UserEntity>: View  {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.createDialogScreen.userRow.avatar
    
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow
    
    public var user: Item
    
    public var isSelected: Bool
    public var isAdmin = false
    public var ownerId: String
    
    public var avatarView: AvatarView?
    public var nameView: UserRowName?
    public var removeBoxView: RemoveUserButton?
    
    public var onTap: (Item) -> Void
    
    public init(_ user: Item,
                isAdmin: Bool,
                ownerId: String,
                isSelected: Bool,
                onTap: @escaping (_ user: Item) -> Void) {
        self.user = user
        self.isAdmin = isAdmin
        self.ownerId = ownerId
        self.isSelected = isSelected
        self.onTap = onTap
    }

    @ViewBuilder
    public var contentView: some View {
        HStack(spacing: settings.spacing) {
            avatarView ?? AvatarView(image: avatar,
                                     height: settings.contentHeight,
                                     isShow: true )
            
            nameView ?? UserRowName(text: user.isCurrent
                                    ? user.name + settings.name.you
                                    : user.name)
            Spacer()
            if user.id == ownerId {
                RoleUserRowName().padding(.trailing, 60)
            }
            
            if isAdmin == true, user.isCurrent == false {
                removeBoxView ?? RemoveUserButton(onTap: {
                    onTap(user)
                })
            }
        }
        .padding(settings.padding)
        .frame(height: settings.height)
        .background(settings.backgroundColor)
    }
    
    public var body: some View {
        contentView.task {
            do { avatar = try await user.avatar } catch { prettyLog(error) }
        }
    }
}

public struct AddUserRow<Item: UserEntity>: View  {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.createDialogScreen.userRow.avatar
    
    public var settings = QuickBloxUIKit.settings.createDialogScreen.userRow
    
    public var user: Item
    
    public var isSelected: Bool
    
    public var avatarView: AvatarView?
    public var nameView: UserRowName?
    public var addBoxView: AddUserButton?
    
    public var onTap: (Item) -> Void
    
    public init(_ user: Item,
                isSelected: Bool,
                onTap: @escaping (_ user: Item) -> Void) {
        self.user = user
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    @ViewBuilder
    public var contentView: some View {
        HStack(spacing: settings.spacing) {
            avatarView ?? AvatarView(image: avatar,
                                     height: settings.contentHeight,
                                     isShow: true )
            
            nameView ?? UserRowName(text: user.name)
            Spacer()
            addBoxView ?? AddUserButton(onTap: {
                onTap(user)
            })
        }
        .padding(settings.padding)
        .frame(height: settings.height)
        .background(settings.backgroundColor)
    }
    
    public var body: some View {
        contentView.task {
            do { avatar = try await user.avatar } catch { prettyLog(error) }
        }
    }
}

struct UserRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserRow(PreviewModel.user1, isSelected: false, onTap: { userId in

            })
                .previewDisplayName("User Row unSelected")
            UserRow(PreviewModel.user2, isSelected: false, onTap: { userId in

            })
                .previewDisplayName("User Row unSelected Dark")
                .preferredColorScheme(.dark)
            UserRow(PreviewModel.user3, isSelected: true, onTap: { userId in

            })
                .previewDisplayName("User Row Selected")
            UserRow(PreviewModel.user4, isSelected:true, onTap: { userId in

            })
                .previewDisplayName("User Row Selected Dark")
                .preferredColorScheme(.dark)
            UserRow(PreviewModel.user5, isSelected: true,  onTap: { userId in

            })
                .previewDisplayName("User Row Selected")
        }.previewLayout(.fixed(width: 375, height: 56.0))
    }
}
