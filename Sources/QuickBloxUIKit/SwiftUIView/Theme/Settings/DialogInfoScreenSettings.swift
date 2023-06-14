//
//  DialogInfoScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

private struct DialogInfoScreenSettingsConstant {
    static let height: CGFloat = 56.0
    static let spacing: CGFloat = 16.0
    static let verticalPadding: CGFloat = 8.0
    static let checkboxHeight: CGFloat = 24.0
    static let lineWidth: CGFloat = 2.0
}

public class DialogInfoScreenSettings {
    public var header: DialogInfoHeaderSettings
    public var privateHeader: PrivateDialogInfoHeaderSettings
    public var nonEditHeader: NonEditInfoHeaderSettings
    public var avatar: InfoAvatar
    public var notification: NotificationSegment
    public var members: MembersSegment
    public var search: SearchSegment
    public var leave: LeaveSegment
    public var groupActionSegments: [DialogInfoAction] = [.members, .searchInDialog, .leaveDialog]
    public var privateActionSegments: [DialogInfoAction] = [.searchInDialog, .leaveDialog]
    public var editNameAlert: NameEditAlert
    public var editDialogAlert: DialogMediaEditAlert
    public var backgroundColor: Color
    public var dividerColor: Color
    public var segmentHeight: CGFloat = 56.0
    public var segmentSpacing: CGFloat = 16.0
    public var regexDialogName = "^(?=.{3,60}$)(?!.*([\\s])\\1{2})[\\w\\s]+$"
    public var avatarSize: CGSize = CGSize(width: 80.0, height: 80.0)
    
    public init(_ theme: ThemeProtocol) {
        self.header = DialogInfoHeaderSettings(theme)
        self.privateHeader = PrivateDialogInfoHeaderSettings(theme)
        self.nonEditHeader = NonEditInfoHeaderSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.avatar = InfoAvatar(theme)
        self.notification = NotificationSegment(theme)
        self.members = MembersSegment(theme)
        self.search = SearchSegment(theme)
        self.leave = LeaveSegment(theme)
        self.editNameAlert = NameEditAlert(theme)
        self.editDialogAlert = DialogMediaEditAlert(theme)
        self.dividerColor = theme.color.divider
    }
    
    public struct InfoAvatar {
        public var color: Color
        public var font: Font
        public var height: CGFloat = 80.0
        public var containerHeight: CGFloat = 110.0
        public var isShow: Bool = true
        public var padding: EdgeInsets = EdgeInsets(top: 24.0,
                                                   leading: 0.0,
                                                   bottom: 24.0,
                                                   trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
        }
    }
}

public struct NonEditInfoHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: DialogInfoTitle
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogInfoTitle(theme)
    }
    
    public struct DialogInfoTitle: HeaderTitleSettingsProtocol {
        public var text: String = "Dialog information"
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

public struct PrivateDialogInfoHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: DialogInfoTitle
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogInfoTitle(theme)
    }
    
    public struct DialogInfoTitle: HeaderTitleSettingsProtocol {
        public var text: String = "Dialog information"
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

public struct DialogInfoHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: DialogInfoTitle
    public var rightButton: EditButton
    public var opacity: CGFloat = 2.0
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogInfoTitle(theme)
        self.rightButton = EditButton(theme)
    }
    
    public struct EditButton: ButtonSettingsProtocol {
        public var title: String? = "Edit"
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.newChat
            self.color = theme.color.mainElements
        }
    }
    
    public struct DialogInfoTitle: HeaderTitleSettingsProtocol {
        public var text: String = "Dialog information"
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

public struct DialogMediaEditAlert {
    public var title: String = ""
    public var cancel: String = "Cancel"
    public var changeImage: String = "Change image"
    public var changeDialogName: String = "Change dialog name"
    public var blurRadius: CGFloat = 12.0
    public var blurBackground: Color
    
    public init(_ theme: ThemeProtocol) {
        self.blurBackground = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.secondaryBackground)
            : UIColor(theme.color.incomingBackground)
        })
    }
}

public struct NameEditAlert {
    public var title: String = "Dialog name"
    public var titleForeground: Color
    public var titleFont: Font
    public var textfieldPrompt: String = "Enter name"
    public var textfieldRadius: CGFloat = 5.0
    public var textfieldPadding: CGFloat = 24.0
    public var textfieldSize: CGSize = CGSize(width: 238, height: 32)
    public var hintPadding: CGFloat = 18.0
    public var textForeground: Color
    public var textFont: Font
    public var hint: String = "Use alphanumeric characters and spaces in a range from 3 to 60. Cannot contain more than one space in a row."
    public var hintForeground: Color
    public var hintFont: Font
    public var cancel: String = "Cancel"
    public var cancelForeground: Color
    public var cancelFont: Font
    public var ok: String = "OK"
    public var okForeground: Color
    public var okFont: Font
    public var errorValidation: String = "Error Validation"
    public var blurRadius: CGFloat = 12.0
    public var cornerRadius: CGFloat = 14.0
    public var size: CGSize = CGSize(width: 270.0, height: 151.0)
    public var fullHeight: CGFloat = 196.0
    public var buttonHeight: CGFloat = 42.0
    public var divider: Color
    public var background: Color
    public var blurBackground: Color
    public var textfieldBackground: Color
    
    public init(_ theme: ThemeProtocol) {
        self.titleForeground = theme.color.mainText
        self.titleFont = theme.font.headline
        self.textForeground = theme.color.secondaryText
        self.textFont = theme.font.callout
        self.hintForeground = theme.color.secondaryText
        self.hintFont = theme.font.caption
        self.cancelForeground = theme.color.mainElements
        self.okForeground = theme.color.mainElements
        self.cancelFont = theme.font.headline
        self.okFont = theme.font.headline
        self.divider = theme.color.divider
        self.background = theme.color.mainBackground
        self.blurBackground = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.secondaryBackground)
            : UIColor(theme.color.incomingBackground)
        })
        self.textfieldBackground = theme.color.inputBackground
    }
}

public struct NotificationSegment {
    public var title: String = "Notification"
    public var foregroundColor: Color
    public var font: Font
    public var image: Image
    public var imageColor: Color
    public var toggleColor: Color
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.mainText
        self.font = theme.font.callout
        self.image = theme.image.bell
        self.imageColor = theme.color.mainElements
        self.toggleColor = theme.color.mainElements
    }
}

public struct MembersSegment {
    public var title: String = "Members"
    public var foregroundColor: Color
    public var font: Font
    public var image: Image
    public var imageColor: Color
    public var arrowRight: Image
    public var arrowColor: Color
    public var countColor: Color
    public var countFont: Font
    public var tralingSpacing: CGFloat = 8.0
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.mainText
        self.font = theme.font.callout
        self.image = theme.image.groupChat
        self.imageColor = theme.color.mainElements
        self.arrowRight = theme.image.chevronForward
        self.arrowColor = theme.color.secondaryElements
        self.countColor = theme.color.tertiaryElements
        self.countFont = theme.font.footnote
    }
}

public struct SearchSegment {
    public var title: String = "Search in dialog"
    public var foregroundColor: Color
    public var font: Font
    public var image: Image
    public var imageColor: Color
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.mainText
        self.font = theme.font.callout
        self.image = theme.image.magnifyingglass
        self.imageColor = theme.color.mainElements
    }
}

public struct LeaveSegment {
    public var title: String = "Leave dialog"
    public var foregroundColor: Color
    public var font: Font
    public var image: Image
    public var imagePNG: Image
    public var imageColor: Color
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.mainText
        self.font = theme.font.callout
        self.image = theme.image.leave
        self.imagePNG = theme.image.leavePNG
        self.imageColor = theme.color.error
    }
}
