//
//  AddMembersScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

private struct AddMembersScreenSettingsConstant {
    static let height: CGFloat = 56.0
    static let spacing: CGFloat = 16.0
    static let verticalPadding: CGFloat = 8.0
    static let checkboxHeight: CGFloat = 24.0
    static let lineWidth: CGFloat = 2.0
}

public class AddMembersScreenSettings {
    public var header: AddMembersHeaderSettings
    public var searchBar: DialogsSearchBarSettings
    public var userRow: UserRowSettings
    public var addUser: AddUsersAlert
    public var backgroundColor: Color
    public var itemsIsEmpty: String
    public var blurRadius: CGFloat = 12.0
    
    public init(_ theme: ThemeProtocol) {
        self.header = AddMembersHeaderSettings(theme)
        self.searchBar = DialogsSearchBarSettings(theme)
        self.userRow = UserRowSettings(theme)
        self.addUser = AddUsersAlert(theme)
        self.backgroundColor = theme.color.mainBackground
        self.itemsIsEmpty = theme.string.usersEmpty
    }
}

public struct AddUsersAlert {
    private var theme: ThemeProtocol
    public var cancel: String
    public var add: String
    public var message: String = ""
    public func alertTitle(_ name: String) -> String {
        return theme.string.addUser
        + name
        + theme.string.toDialog
    }
    
    public init(_ theme: ThemeProtocol) {
        self.theme = theme
        self.cancel = theme.string.cancel
        self.add = theme.string.add
    }
}

public struct AddMembersHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: AddMembersTitle
    public var opacity: CGFloat = 0.4
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = AddMembersTitle(theme)
    }
    
    public struct AddMembersTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 0.0
        public var isHiddenAvatar: Bool = true
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.addMembers
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var color: Color
        public var scale: Double = 0.6
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 10.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
}
