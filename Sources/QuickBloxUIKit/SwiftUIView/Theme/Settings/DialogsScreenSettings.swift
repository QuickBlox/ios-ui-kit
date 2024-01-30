//
//  DialogsScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public class DialogsScreenSettings {
    public var header: DialogsHeaderSettings
    public var searchBar: DialogsSearchBarSettings
    public var dialogRow: DialogRowSettings
    public var connectStatus: ConnectStatusStringConstant
    public var backgroundColor: Color
    public var itemsIsEmpty: String
    public var selectDialog: String
    public var itemsIsEmptyFont: Font
    public var itemsIsEmptyColor: Color
    public var blurRadius: CGFloat = 12.0
    public var messageImage: Image
    public var messageImageColor: Color
    public var progressBar: ProgressBarSettings
    public var useToolbar: Bool = true
    public var tabIndex: TabIndexSettings
    
    public init(_ theme: ThemeProtocol) {
        self.header = DialogsHeaderSettings(theme)
        self.searchBar = DialogsSearchBarSettings(theme)
        self.dialogRow = DialogRowSettings(theme)
        self.connectStatus = ConnectStatusStringConstant(theme)
        self.backgroundColor = theme.color.mainBackground
        self.itemsIsEmpty = theme.string.dialogsEmpty
        self.selectDialog = theme.string.selectDialog
        self.itemsIsEmptyFont = theme.font.title3
        self.itemsIsEmptyColor = theme.color.caption
        self.messageImage = theme.image.message
        self.messageImageColor = theme.color.caption
        self.progressBar = ProgressBarSettings(theme)
        self.tabIndex = TabIndexSettings(theme)
    }
}

public struct TabIndexSettings {
    public var backgroundColor: Color
    public var externalIndexes: [TabIndex] = [.settings]
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
    }
}

public struct ProgressBarSettings: ProgressBarSettingsProtocol {
    public var segments: Int = 8
    public var segmentColor: Color
    public var segmentDuration: Double = 0.16
    public var progressSegmentColor: Color
    public var lineWidth: CGFloat = 2.0
    public var rotationEffect: Angle = Angle(degrees: -90)
    public var emptySpaceAngle: Angle = Angle(degrees: 10)
    public var size: CGSize = CGSize(width: 60.0, height: 60.0)
    
    public init(_ theme: ThemeProtocol) {
        self.segmentColor = theme.color.system
        self.progressSegmentColor = theme.color.mainElements
    }
}

public struct ConnectStatusStringConstant {
    public var connecting: String = "connecting"
    public var update: String = "update"
    public var disconnected: String = "disconnected"
    public var connected: String = "connected"
    public var unauthorized: String = "unauthorized"
    public var authorized: String = "authorized"
    
    public var connectingLocalize: String
    public var updateLocalize: String
    public var disconnectedLocalize: String
    public var connectedLocalize: String
    public var unauthorizedLocalize: String
    public var authorizedLocalize: String
    
    public func connectionText(_ text: String) -> String {
        if text.contains(connecting) == true {
            return text.replacingOccurrences(of: connecting, with: connectingLocalize)
        } else if text.contains(update) == true {
            return text.replacingOccurrences(of: update, with: updateLocalize)
        } else if text.contains(disconnected) == true {
            return text.replacingOccurrences(of: disconnected, with: disconnectedLocalize)
        } else if text.contains(connected) == true {
            return text.replacingOccurrences(of: connected, with: connectedLocalize)
        } else if text.contains(unauthorized) == true {
            return text.replacingOccurrences(of: unauthorized, with: unauthorizedLocalize)
        } else if text.contains(authorized) == true {
            return text.replacingOccurrences(of: authorized, with: authorizedLocalize)
        } else {
            return text
        }
    }
    
    public init(_ theme: ThemeProtocol) {
        self.connectingLocalize = theme.string.connecting
        self.updateLocalize = theme.string.update
        self.disconnectedLocalize = theme.string.disconnected
        self.connectedLocalize = theme.string.connected
        self.unauthorizedLocalize = theme.string.unauthorized
        self.authorizedLocalize = theme.string.authorized
    }
}

public struct DialogsHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: BackButton
    public var title: DialogsTitle
    public var rightButton: SelectTypeButton
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = BackButton(theme)
        self.title = DialogsTitle(theme)
        self.rightButton = SelectTypeButton(theme)
    }
    
    public struct SelectTypeButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String? = nil
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
        }
    }
    
    public struct DialogsTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 0.0
        public var isHiddenAvatar: Bool = true
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.dialogs
        }
    }
    
    public struct BackButton: ButtonSettingsProtocol {
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
        public var hidden: Bool = false
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
}

public struct DeleteDialogAlertSettings {
    private var theme: ThemeProtocol
    public var cancel: String
    public var remove: String
    public var message: String = ""
    public func alertTitle(_ name: String) -> String {
        return theme.string.removeItem
        + name
        + theme.string.questionMark
    }
    
    public init(_ theme: ThemeProtocol) {
        self.theme = theme
        self.cancel = theme.string.cancel
        self.remove = theme.string.remove
    }
}

public struct DialogsSearchBarSettings: SearchBarSettingsProtocol {
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
    public var isHiddenAvatar: Bool = false
    public var isHiddenLastMessage: Bool = false
    public var isHiddenCounter: Bool = false
    public var isHiddenTime: Bool = false
    public var separatorInset: CGFloat = 88.0
    public var avatarSize: CGSize = CGSize(width: 56.0, height: 56.0)
    public var height: CGFloat = 76
    public var selectHeight: CGFloat = 56
    public var selectAvatarSize: CGSize = CGSize(width: 40.0, height: 40.0)
    public var selectPadding: EdgeInsets = EdgeInsets(top: 0,
                                                leading: 16,
                                                bottom: 0,
                                                trailing: 16)
    public var contentHeight: CGFloat = 56
    public var spacing: CGFloat = 16
    public var padding: EdgeInsets = EdgeInsets(top: 10,
                                                leading: 16,
                                                bottom: 10,
                                                trailing: 16)
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
        public var isHidden: Bool = false
        
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
