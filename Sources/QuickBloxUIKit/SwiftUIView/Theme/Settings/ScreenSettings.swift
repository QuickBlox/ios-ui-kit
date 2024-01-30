//
//  ScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public protocol ScreensProtocol: AnyObject {
    var theme: ThemeProtocol { get set }
    var dialogsScreen: DialogsScreenSettings { get set }
    var dialogTypeScreen: DialogTypeScreenSettings { get set }
    var dialogNameScreen: DialogNameScreenSettings { get set }
    var createDialogScreen: CreateDialogScreenSettings { get set }
    var dialogScreen: DialogScreenSettings { get set }
    var dialogInfoScreen: DialogInfoScreenSettings { get set }
    var membersScreen: MembersScreenSettings { get set }
    var addMembersScreen: AddMembersScreenSettings { get set }
    var thumbnailImageSize: ThumbnailImageSizeSettings { get set }
    
    init(_ theme: ThemeProtocol)
}

public protocol ButtonSettingsProtocol {
    var title: String? { get set }
    var image: Image { get set }
    var color: Color { get set }
    var scale: Double { get set }
    var padding: EdgeInsets { get set }
    var imageSize: CGSize? { get set }
    var frame: CGSize? { get set }
    
    init(_ theme: ThemeProtocol)
}

public protocol HeaderSettingsProtocol {
    var displayMode: NavigationBarItem.TitleDisplayMode { get set }
    var backgroundColor: Color { get set }
    var leftButton: ButtonSettingsProtocol { get set }
    var title: HeaderTitleSettingsProtocol { get set }
    var rightButton: ButtonSettingsProtocol { get set }
    var opacity: CGFloat { get set }
    var isHidden: Bool { get set }
    
    init(_ theme: ThemeProtocol)
}

public protocol HeaderTitleSettingsProtocol {
    var text: String { get set }
    var color: Color { get set }
    var font: Font { get set }
    var avatarHeight: CGFloat { get set }
    var isHiddenAvatar: Bool { get set }
    
    init(_ theme: ThemeProtocol)
}

public protocol SearchTextFieldSettingsProtocol {
    var placeholderColor: Color { get set }
    var placeholderText: String { get set }
    var backgroundColor: Color { get set }
    
    init(_ theme: ThemeProtocol)
}

public protocol SearchBarSettingsProtocol {
    associatedtype SearchTextFieldSettings: SearchTextFieldSettingsProtocol
    
    var isSearchable: Bool { get set }
    var searchTextField: SearchTextFieldSettings { get set }
    
    init(_ theme: ThemeProtocol)
}

public protocol ProgressBarSettingsProtocol {
    var segments: Int { get set }
    var segmentColor: Color { get set }
    var segmentDuration: Double { get set }
    var progressSegmentColor: Color { get set }
    var lineWidth: CGFloat { get set }
    var rotationEffect: Angle { get set }
    var emptySpaceAngle: Angle { get set }
    var size: CGSize { get set }
    
    init(_ theme: ThemeProtocol)
}

public class ScreenSettings: ScreensProtocol {
    public var theme: ThemeProtocol {
        didSet {
            self.dialogsScreen = DialogsScreenSettings(theme)
            self.dialogTypeScreen = DialogTypeScreenSettings(theme)
            self.dialogNameScreen = DialogNameScreenSettings(theme)
            self.createDialogScreen = CreateDialogScreenSettings(theme)
            self.dialogScreen = DialogScreenSettings(theme)
            self.dialogInfoScreen = DialogInfoScreenSettings(theme)
            self.membersScreen = MembersScreenSettings(theme)
            self.addMembersScreen = AddMembersScreenSettings(theme)
            self.thumbnailImageSize = ThumbnailImageSizeSettings()
        }
    }
    public var dialogsScreen: DialogsScreenSettings
    public var dialogTypeScreen: DialogTypeScreenSettings
    public var dialogNameScreen: DialogNameScreenSettings
    public var createDialogScreen: CreateDialogScreenSettings
    public var dialogScreen: DialogScreenSettings
    public var dialogInfoScreen: DialogInfoScreenSettings
    public var membersScreen: MembersScreenSettings
    public var addMembersScreen: AddMembersScreenSettings
    public var thumbnailImageSize: ThumbnailImageSizeSettings
    
    required public init(_ theme: ThemeProtocol) {
        self.theme = theme
        
        self.dialogsScreen = DialogsScreenSettings(theme)
        self.dialogTypeScreen = DialogTypeScreenSettings(theme)
        self.dialogNameScreen = DialogNameScreenSettings(theme)
        self.createDialogScreen = CreateDialogScreenSettings(theme)
        self.dialogScreen = DialogScreenSettings(theme)
        self.dialogInfoScreen = DialogInfoScreenSettings(theme)
        self.membersScreen = MembersScreenSettings(theme)
        self.addMembersScreen = AddMembersScreenSettings(theme)
        self.thumbnailImageSize = ThumbnailImageSizeSettings()
    }
}
