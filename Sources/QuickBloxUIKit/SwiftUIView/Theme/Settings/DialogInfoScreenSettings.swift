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
    public var groupActionSegments: [DialogInfoAction] = [.members, .leaveDialog]
    public var privateActionSegments: [DialogInfoAction] = [.leaveDialog]
    public var editNameAlert: NameEditAlert
    public var editDialogAlert: DialogMediaEditAlert
    public var forwardAlert: ForwardAlert
    public var backgroundColor: Color
    public var dividerColor: Color
    public var segmentHeight: CGFloat = 56.0
    public var segmentSpacing: CGFloat = 16.0
    public var avatarSize: CGSize = CGSize(width: 80.0, height: 80.0)
    public var maximumMB: Double = 10
    
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
        self.forwardAlert = ForwardAlert(theme)
        self.dividerColor = theme.color.divider
    }
    
    public struct InfoAvatar {
        public var color: Color
        public var font: Font
        public var height: CGFloat = 80.0
        public var isHidden: Bool = false
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

public struct ForwardAlert {
    public var checkMark: Image
    public var checkMarkColor: Color
    public var checkMarkSize: CGSize = CGSize(width: 25, height: 17)
    public var title: String
    public var titleForeground: Color
    public var titleFont: Font
    public var titleFailure: String
    public var cornerRadius: CGFloat = 12.0
    public var size: CGSize = CGSize(width: 235.0, height: 100.0)
    public var background: Color
    public var cancel: String
    public var blurRadius: CGFloat = 12.0
    
    public init(_ theme: ThemeProtocol) {
        self.checkMark = theme.image.send
        self.checkMarkColor = theme.color.success
        self.titleForeground = theme.color.system
        self.titleFont = theme.font.footnote
        self.background = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.mainBackground)
            : UIColor(theme.color.secondaryElements)
        })
        self.title = theme.string.forwardSuccess
        self.titleFailure  = theme.string.forwardFailure
        self.cancel = theme.string.cancel
    }
}

public struct NonEditInfoHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: BackButton
    public var title: DialogInfoTitle
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = BackButton(theme)
        self.title = DialogInfoTitle(theme)
    }
    
    public struct DialogInfoTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 0.0
        public var isHiddenAvatar: Bool = true
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.dialogInformation
        }
    }
    
    public struct BackButton: ButtonSettingsProtocol {
        public var hidden: Bool = false
        
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

public struct PrivateDialogInfoHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: DialogInfoTitle
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogInfoTitle(theme)
    }
    
    public struct DialogInfoTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 0.0
        public var isHiddenAvatar: Bool = true
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.dialogInformation
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var hidden: Bool = false
        
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

public struct DialogInfoHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: DialogInfoTitle
    public var rightButton: EditButton
    public var opacity: CGFloat = 2.0
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogInfoTitle(theme)
        self.rightButton = EditButton(theme)
    }
    
    public struct EditButton: ButtonSettingsProtocol {
        public var hidden: Bool = false
        
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String?
        public var image: Image
        public var color: Color
        public var scale: Double = 0.5
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 16.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.newChat
            self.color = theme.color.mainElements
            self.title = theme.string.edit
        }
    }
    
    public struct DialogInfoTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 0.0
        public var isHiddenAvatar: Bool = true
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.dialogInformation
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var hidden: Bool = false
        
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

public struct DialogMediaEditAlert {
    public var title: String = ""
    public var cancel: String
    public var changeImage: String
    public var changeDialogName: String
    public var blurRadius: CGFloat = 12.0
    public var blurBackground: Color
    public var isHiddenFiles: Bool = true
    public var iPadBackgroundColor: Color
    public var iPadCancelColor: Color
    public var shadowColor: Color
    public var buttonSize: CGSize = CGSize(width: 260, height: 56)
    public var cornerRadius: CGFloat = 14.0
    
    public init(_ theme: ThemeProtocol) {
        self.changeImage = theme.string.changeImage
        self.changeDialogName = theme.string.changeDialogName
        self.iPadBackgroundColor = theme.color.secondaryBackground
        self.iPadCancelColor = theme.color.mainElements
        self.cancel = theme.string.cancel
        self.blurBackground = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.secondaryBackground)
            : UIColor(theme.color.incomingBackground)
        })
        self.shadowColor = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.secondaryBackground)
            : UIColor(theme.color.disabledElements)
        }).opacity(0.6)
    }
}

public struct NameEditAlert {
    public var title: String
    public var titleForeground: Color
    public var titleFont: Font
    public var textfieldPrompt: String
    public var textfieldRadius: CGFloat = 5.0
    public var textfieldPadding: CGFloat = 24.0
    public var textfieldSize: CGSize = CGSize(width: 238, height: 32)
    public var hintPadding: CGFloat = 18.0
    public var textForeground: Color
    public var textFont: Font
    public var hint: String
    public var hintForeground: Color
    public var hintFont: Font
    public var cancel: String
    public var cancelForeground: Color
    public var cancelFont: Font
    public var ok: String
    public var okForeground: Color
    public var okFont: Font
    public var errorValidation: String
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
        self.textfieldPrompt = theme.string.enterName
        self.title = theme.string.dialogName
        self.hint = theme.string.nameHint
        self.cancel = theme.string.cancel
        self.ok = theme.string.ok
        self.errorValidation = theme.string.errorValidation
    }
}

public struct NotificationSegment {
    public var title: String
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
        self.title = theme.string.notification
    }
}

public struct MembersSegment {
    public var title: String
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
        self.title = theme.string.members
    }
}

public struct SearchSegment {
    public var title: String
    public var foregroundColor: Color
    public var font: Font
    public var image: Image
    public var imageColor: Color
    
    public init(_ theme: ThemeProtocol) {
        self.foregroundColor = theme.color.mainText
        self.font = theme.font.callout
        self.image = theme.image.magnifyingglass
        self.imageColor = theme.color.mainElements
        self.title = theme.string.searchInDialog
    }
}

public struct LeaveSegment {
    public var title: String
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
        self.title = theme.string.leaveDialog
    }
}
