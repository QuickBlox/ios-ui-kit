//
//  DialogsScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

private struct DialogsScreenSettingsConstant {
    static let height: CGFloat = 76.0
    static let spacing: CGFloat = 16.0
    static let verticalPadding: CGFloat = 10.0
}

public class DialogsScreenSettings {
    public var header: DialogsHeaderSettings
    public var searchBar: DialogsSearchBarSettings
    public var dialogRow: DialogRowSettings
    public var backgroundColor: Color
    public var itemsIsEmpty: String = "You don’t have any dialogs."
    public var blurRadius: CGFloat = 12.0
    
    public init(_ theme: ThemeProtocol) {
        self.header = DialogsHeaderSettings(theme)
        self.searchBar = DialogsSearchBarSettings(theme)
        self.dialogRow = DialogRowSettings(theme)
        self.backgroundColor = theme.color.mainBackground
    }
}

public struct DialogsHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: BackButton
    public var title: DialogsTitle
    public var rightButton: SelectTypeButton
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = BackButton(theme)
        self.title = DialogsTitle(theme)
        self.rightButton = SelectTypeButton(theme)
    }
    
    public struct SelectTypeButton: ButtonSettingsProtocol {
        public var title: String? = nil
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.newChat
            self.color = theme.color.mainElements
        }
    }
    
    public struct DialogsTitle: HeaderTitleSettingsProtocol {
        public var text: String = "Dialogs"
        public var color: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
        }
    }
    
    public struct BackButton: ButtonSettingsProtocol {
        public var title: String? = nil
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
}

public struct DialogsSearchBarSettings: SearchBarSettingsProtocol {
    public var isSearchable: Bool = true
    public var searchTextField: DialogsSearchTextField
    
    public init(_ theme: ThemeProtocol) {
        self.searchTextField = DialogsSearchTextField(theme)
    }
    
    public struct DialogsSearchTextField: SearchTextFieldSettingsProtocol {
        public var placeholderText: String = "Search"
        public var placeholderColor: Color
        public var backgroundColor: Color
        
        public init(_ theme: ThemeProtocol) {
            self.placeholderColor = theme.color.secondaryText
            self.backgroundColor = theme.color.inputBackground
        }
    }
}

public struct DialogAvatarSettings {
    public var privateAvatar: Image
    public var groupAvatar: Image
    public var publicAvatar: Image
    
    public init(_ theme: ThemeProtocol) {
        self.privateAvatar = theme.image.avatarUser
        self.groupAvatar = theme.image.avatarGroup
        self.publicAvatar = theme.image.avatarPublic
    }
}

public struct DialogNameSettings {
    public var foregroundColor: Color
    public var font: Font
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.mainText
        self.font = theme.font.footnote
    }
}

public struct DialogRowSettings {
    public var avatar: DialogAvatarSettings
    public var name: DialogNameSettings
    public var lastMessage: DialogLastMessageSettings
    public var time: DialogTimeSettings
    public var unreadCount: UnreadCountSettings
    public var backgroundColor: Color
    public var dividerColor: Color
    public var leaveImage: Image
    public var isShowAvatar: Bool = true
    public var isShowLastMessage: Bool = true
    public var isShowTime: Bool = true
    public var separatorInset: CGFloat = 88.0
    public var avatarSize: CGSize = CGSize(width: 56.0, height: 56.0)
    public var height: CGFloat = DialogsScreenSettingsConstant.height
    public var contentHeight: CGFloat = DialogsScreenSettingsConstant.height - DialogsScreenSettingsConstant.verticalPadding * 2
    public var spacing: CGFloat = DialogsScreenSettingsConstant.spacing
    public var padding: EdgeInsets = EdgeInsets(top: DialogsScreenSettingsConstant.verticalPadding,
                                                leading: DialogsScreenSettingsConstant.spacing,
                                                bottom: DialogsScreenSettingsConstant.verticalPadding,
                                                trailing: DialogsScreenSettingsConstant.spacing)
    public var infoSpacer = Spacer(minLength: 8.0)
    public var infoSpacing: CGFloat = 2.0
    
    
    public init(_ theme: ThemeProtocol) {
        self.avatar = DialogAvatarSettings(theme)
        self.name = DialogNameSettings(theme)
        self.lastMessage = DialogLastMessageSettings(theme)
        self.time = DialogTimeSettings(theme)
        self.unreadCount = UnreadCountSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.dividerColor = theme.color.divider
        self.leaveImage = theme.image.leavePNG
    }
    
    public struct DialogLastMessageSettings {
        public var foregroundColor: Color
        public var font: Font
        public var imagePlaceholder: Image
        public var filePlaceholder: Image
        public var audioPlaceholder: Image
        public var videoPlaceholder: Image
        public var placeholderForeground: Color
        public var placeholderBackground: Color
        public var size: CGSize = CGSize(width: 32.0, height: 32.0)
        public var placeholderSize: CGSize = CGSize(width: 17.0, height: 17.0)
        public var imageCornerRadius = 8.0
        
        public init(_ theme: ThemeProtocol) {
            self.foregroundColor = theme.color.secondaryText
            self.font = theme.font.caption
            self.imagePlaceholder = theme.image.photo
            self.filePlaceholder = theme.image.doctext
            self.audioPlaceholder = theme.image.speakerwave
            self.videoPlaceholder = theme.image.play
            self.placeholderForeground = theme.color.caption
            self.placeholderBackground = theme.color.inputBackground
        }
    }

    public struct DialogTimeSettings {
        public var foregroundColor: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.foregroundColor = theme.color.secondaryText
            self.font = theme.font.caption2
        }
    }

    public struct UnreadCountSettings {
        public var maxCount: Int = 99
        public var foregroundColor: Color
        public var backgroundColor: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.foregroundColor = theme.color.mainBackground
            self.backgroundColor = theme.color.mainElements
            self.font = theme.font.caption
        }
    }
}
