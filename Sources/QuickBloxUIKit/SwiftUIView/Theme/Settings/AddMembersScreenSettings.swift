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
    public var itemsIsEmpty: String = "You don’t have any users."
    public var blurRadius: CGFloat = 12.0
    
    public init(_ theme: ThemeProtocol) {
        self.header = AddMembersHeaderSettings(theme)
        self.searchBar = DialogsSearchBarSettings(theme)
        self.userRow = UserRowSettings(theme)
        self.addUser = AddUsersAlert()
        self.backgroundColor = theme.color.mainBackground
    }
}

public struct AddUsersAlert {
    public var cancel: String = "Cancel"
    public var add: String = "Add"
    public var message: String = ""
    public func alertTitle(_ name: String) -> String {
        return "Are you sure you want to add  \(name) to this dialog?"
    }
}

public struct AddMembersHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: AddMembersTitle
    public var opacity: CGFloat = 0.4
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = AddMembersTitle(theme)
    }
    
    public struct AddMembersTitle: HeaderTitleSettingsProtocol {
        public var text: String = "Add Members"
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
