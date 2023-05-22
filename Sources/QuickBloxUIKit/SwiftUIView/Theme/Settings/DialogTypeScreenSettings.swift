//
//  DialogTypeScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain

public class DialogTypeScreenSettings {
    public var header: DialogTypeHeaderSettings
    public var backgroundColor: Color
    public var opacity: CGFloat = 0.8
    public var dialogTypeBar: DialogTypeBarSettings
    
    public init(_ theme: ThemeProtocol) {
        self.header = DialogTypeHeaderSettings(theme)
        self.backgroundColor = theme.color.secondaryBackground
        self.dialogTypeBar = DialogTypeBarSettings(theme)
    }
}

public struct DialogTypeHeaderSettings {
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var title: DialogTypeTitle
    public var rightButton: CloseButton
    public var height: CGFloat = 44.0
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.title = DialogTypeTitle(theme)
        self.rightButton = CloseButton(theme)
    }
    
    public struct DialogTypeTitle: HeaderTitleSettingsProtocol {
        public var text: String = "Dialog Type"
        public var color: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
        }
    }
    
    public struct CloseButton: ButtonSettingsProtocol {
        public var title: String? = nil
        public var image: Image
        public var color: Color
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.close
            self.color = theme.color.secondaryElements
        }
    }
}

public struct DialogTypeBarSettings {
    public var backgroundColor: Color
    public var displayedTypes: [DialogType] = [.private, .group]
    public var privateSegment: DialogTypeSegment
    public var groupSegment: DialogTypeSegment
    public var publicSegment: DialogTypeSegment
    public var spacing: CGFloat = 16.0
    public var segmentSpacing: CGFloat = 6.0
    public var height: CGFloat = 80.0
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.privateSegment = DialogTypeSegment(title: "Private",
                                                color: theme.color.mainElements,
                                                font: theme.font.headline,
                                                image: theme.image.chat)
        self.groupSegment = DialogTypeSegment(title: "Group",
                                                color: theme.color.mainElements,
                                                font: theme.font.headline,
                                                image: theme.image.conference)
        self.publicSegment = DialogTypeSegment(title: "Public",
                                                color: theme.color.mainElements,
                                                font: theme.font.headline,
                                                image: theme.image.publicChannel)
    }
}

public struct DialogTypeSegment {
    public var title: String
    public var color: Color
    public var font: Font
    public var image: Image
    
    public init(title: String, color: Color, font: Font, image: Image) {
        self.title = title
        self.color = color
        self.font = font
        self.image = image
    }
}
