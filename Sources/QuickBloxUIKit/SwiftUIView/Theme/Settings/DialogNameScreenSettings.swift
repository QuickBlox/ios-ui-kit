//
//  DialogNameScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public class DialogNameScreenSettings {
    public var header: DialogNameHeaderSettings
    public var backgroundColor: Color
    public var avatarCamera: Image
    public var blurRadius: CGFloat = 12.0
    public var dividerColor: Color
    public var height: CGFloat = 56.0
    public var spacing: CGFloat = 16.0
    public var hint: String = "Use alphanumeric characters and spaces in a range from 3 to 60. Cannot contain more than one space in a row."
    public var textfieldPrompt: String = "Enter name"
    public var mediaAlert: MediaAlert = MediaAlert()
    public var regexDialogName = "^(?=.{3,60}$)(?!.*([\\s])\\1{2})[\\w\\s]+$"
    
    public init(_ theme: ThemeProtocol) {
        self.header = DialogNameHeaderSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.avatarCamera = theme.image.avatarCamera
        self.dividerColor = theme.color.divider
    }
}

public struct MediaAlert {
    public var title: String = "Photo"
    public var removePhoto: String = "Remove photo"
    public var camera: String = "Camera"
    public var gallery: String = "Gallery"
    public var cancel: String = "Cancel"
    public var blurRadius:CGFloat = 12.0
}

public struct DialogNameHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: DialogsTitle
    public var rightButton: CreateButton
    public var opacity: CGFloat = 0.4
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogsTitle(theme)
        self.rightButton = CreateButton(theme)
    }
    
    public struct CreateButton: ButtonSettingsProtocol {
        public var title: String? = "Create"
        public var secondTitle: String? = "Next"
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.newChat
            self.color = theme.color.mainElements
        }
    }
    
    public struct DialogsTitle: HeaderTitleSettingsProtocol {
        public var text: String = "New Dialog"
        public var color: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var title: String? = "Cancel"
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
}
