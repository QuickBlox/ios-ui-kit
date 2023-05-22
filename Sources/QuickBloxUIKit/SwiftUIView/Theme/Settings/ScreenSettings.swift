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
    
    init(_ theme: ThemeProtocol)
}

public protocol ButtonSettingsProtocol {
    var title: String? { get set }
    var image: Image { get set }
    var color: Color { get set }
    
    init(_ theme: ThemeProtocol)
}

public protocol HeaderTitleSettingsProtocol {
    var text: String { get set }
    var color: Color { get set }
    var font: Font { get set }
    
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
    }
}
