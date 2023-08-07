//
//  CreateDialogScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 18.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

private struct CreateDialogScreenSettingsConstant {
    static let height: CGFloat = 56.0
    static let spacing: CGFloat = 16.0
    static let verticalPadding: CGFloat = 8.0
    static let checkboxHeight: CGFloat = 24.0
    static let lineWidth: CGFloat = 2.0
}

public class CreateDialogScreenSettings {
    public var header: CreateDialogHeaderSettings
    public var searchBar: DialogsSearchBarSettings
    public var userRow: UserRowSettings
    public var backgroundColor: Color
    public var itemsIsEmpty: String
    public var itemsIsEmptyFont: Font
    public var itemsIsEmptyColor: Color
    public var blurRadius: CGFloat = 12.0
    public var messageImage: Image
    public var messageImageColor: Color
    
    public init(_ theme: ThemeProtocol) {
        self.header = CreateDialogHeaderSettings(theme)
        self.searchBar = DialogsSearchBarSettings(theme)
        self.userRow = UserRowSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.itemsIsEmpty = theme.string.noResults
        self.itemsIsEmptyFont = theme.font.title3
        self.itemsIsEmptyColor = theme.color.caption
        self.messageImage = theme.image.magnifyingglass
        self.messageImageColor = theme.color.caption
    }
}

public struct CreateDialogHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: CreateDialogTitle
    public var rightButton: CreateButton
    public var opacity: CGFloat = 0.4
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = CreateDialogTitle(theme)
        self.rightButton = CreateButton(theme)
    }
    
    public struct CreateButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String?
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.newChat
            self.color = theme.color.mainElements
            self.title = theme.string.create
        }
    }
    
    public struct CreateDialogTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 0.0
        public var isHiddenAvatar: Bool = true
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.createDialog
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String?
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
            self.title = theme.string.cancel
        }
    }
}

public struct CreateDialogSearchBarSettings: SearchBarSettingsProtocol {
    public var isSearchable: Bool = true
    public var searchTextField: DialogsSearchTextField
    
    public init(_ theme: ThemeProtocol) {
        self.searchTextField = DialogsSearchTextField(theme)
    }
    
    public struct DialogsSearchTextField: SearchTextFieldSettingsProtocol {
        public var placeholderText: String
        public var placeholderColor: Color
        public var backgroundColor: Color
        
        public init(_ theme: ThemeProtocol) {
            self.placeholderColor = theme.color.secondaryText
            self.backgroundColor = theme.color.inputBackground
            self.placeholderText = theme.string.search
        }
    }
}

public struct UserRowSettings {
    public var avatar: Image
    public var name: UserNameSettings
    public var roleName: RoleUserNameSettings
    public var checkbox: UserCheckboxSettings
    public var backgroundColor: Color
    public var dividerColor: Color
    public var isHiddenAvatar: Bool = false
    
    public var height: CGFloat = CreateDialogScreenSettingsConstant.height
    public var contentHeight: CGFloat = CreateDialogScreenSettingsConstant.height - CreateDialogScreenSettingsConstant.verticalPadding * 2
    public var spacing: CGFloat = CreateDialogScreenSettingsConstant.spacing
    public var padding: EdgeInsets = EdgeInsets(top: CreateDialogScreenSettingsConstant.verticalPadding,
                                                leading: CreateDialogScreenSettingsConstant.spacing,
                                                bottom: CreateDialogScreenSettingsConstant.verticalPadding,
                                                trailing: CreateDialogScreenSettingsConstant.spacing)
    public var infoSpacer = Spacer(minLength: 8.0)
    public var infoSpacing: CGFloat = 2.0
    
    public init(_ theme: ThemeProtocol) {
        self.avatar = theme.image.avatarUser
        self.name = UserNameSettings(theme)
        self.roleName = RoleUserNameSettings(theme)
        self.checkbox = UserCheckboxSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.dividerColor = theme.color.divider
    }
}

public struct UserCheckboxSettings {
    public var heightSelected: CGFloat = 24.0
    public var foregroundColorSelected: Color
    public var font: Font
    public var backgroundColor: Color
    public var selected: Image
    public var strokeBorder: Color
    public var lineWidth: CGFloat = 2.0
    public var delete: Image
    public var heightButton: CGFloat = CreateDialogScreenSettingsConstant.height
    public var foregroundColorDelete: Color
    public var add: Image
    public var foregroundColorAdd: Color
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColorSelected = theme.color.secondaryBackground
        self.font = theme.font.footnote
        self.backgroundColor = theme.color.mainElements
        self.selected = theme.image.checkmark
        self.strokeBorder = theme.color.secondaryElements
        self.delete = theme.image.trash
        self.add = theme.image.plus
        self.foregroundColorDelete = theme.color.mainElements
        self.foregroundColorAdd = theme.color.mainElements
    }
}

public struct UserNameSettings {
    public var you: String
    public var foregroundColor: Color
    public var font: Font
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.mainText
        self.font = theme.font.callout
        self.you = theme.string.you
    }
}

public struct RoleUserNameSettings {
    public var admin: String
    public var foregroundColor: Color
    public var font: Font
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.tertiaryElements
        self.font = theme.font.footnote
        self.admin = theme.string.admin
    }
}

public struct UserAvatarSettings {
    public var avatar: Image
}
