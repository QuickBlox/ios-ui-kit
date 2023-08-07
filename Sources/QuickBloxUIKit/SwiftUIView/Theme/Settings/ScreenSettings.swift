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

public class Feature {
    /// An instance of the AI module for AI-related settings and operations.
    public var ai: AI = AI()
    
}

public class AI {
    /// Settings for assist answer functionality using the OpenAI API key or QuickBlox token and proxy server.
    public var assistAnswer: AssistAnswerSettings =
    AssistAnswerSettings(enable: true,
                         openAIToken: "",
                         proxyServerURLPath: "")
}

/// Settings for assist answer functionality.
public class AssistAnswerSettings {
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = false
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var openAIAPIKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var proxyServerURLPath: String = ""
    
    /// Indicates if the AI settings are valid, i.e., either the OpenAI API key or proxy server URL is provided.
    public var isValidAI: Bool {
        return openAIAPIKey.isEmpty == false || proxyServerURLPath.isEmpty == false
    }
    
    /// Initializes the AssistAnswerSettings with the given values.
    /// - Parameters:
    ///   - enable: Determines if assist answer functionality is enabled.
    ///   - openAIToken: The OpenAI API key for direct API requests (if not using a proxy server).
    ///   - proxyServerURLPath: The URL path of the proxy server for more secure communication (if not using the API key directly).
    required public init(enable: Bool, openAIToken: String, proxyServerURLPath: String) {
        self.enable = enable
        self.openAIAPIKey = openAIToken
        self.proxyServerURLPath = proxyServerURLPath
    }
}
