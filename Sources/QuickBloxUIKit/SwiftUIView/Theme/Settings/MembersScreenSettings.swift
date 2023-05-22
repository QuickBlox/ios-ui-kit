//
//  MembersScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 21.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

private struct MembersScreenSettingsConstant {
    static let height: CGFloat = 56.0
    static let spacing: CGFloat = 16.0
    static let verticalPadding: CGFloat = 8.0
    static let checkboxHeight: CGFloat = 24.0
    static let lineWidth: CGFloat = 2.0
}

public class MembersScreenSettings {
    public var header: MembersHeaderSettings
    public var searchBar: DialogsSearchBarSettings
    public var userRow: UserRowSettings
    public var removeUser: RemoveUsersAlert
    
    public var backgroundColor: Color
    public var itemsIsEmpty: String = "You don’t have any users."
    public var blurRadius: CGFloat = 12.0
    
    public init(_ theme: ThemeProtocol) {
        self.header = MembersHeaderSettings(theme)
        self.searchBar = DialogsSearchBarSettings(theme)
        self.userRow = UserRowSettings(theme)
        self.removeUser = RemoveUsersAlert()
        self.backgroundColor = theme.color.mainBackground
    }
}

public struct RemoveUsersAlert {
    public var cancel: String = "Cancel"
    public var remove: String = "Remove"
    public var message: String = ""
    public func alertTitle(_ name: String) -> String {
        return "Are you sure you want to remove \(name)?"
    }
}

public struct MembersHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: MembersTitle
    public var rightButton: CreateButton
    public var opacity: CGFloat = 0.4
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = MembersTitle(theme)
        self.rightButton = CreateButton(theme)
    }
    
    public struct CreateButton: ButtonSettingsProtocol {
        public var title: String? = nil
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.plus
            self.color = theme.color.mainElements
        }
    }
    
    public struct MembersTitle: HeaderTitleSettingsProtocol {
        public var text: String = "Members"
        public var color: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var title: String? = nil
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
}
