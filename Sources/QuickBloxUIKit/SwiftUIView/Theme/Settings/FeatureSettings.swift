//
//  FeatureSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 19.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import SwiftUI

public class ForwardFeature {
    /// Determines if ForwardFeature functionality is enabled.
    public var enable: Bool = true
    public var forwardedMessageKey: String = "[Forwarded_Message]"
    public var forwardedMessage: String = "forwarded message"
}

public struct ForwardUISettings {
    public init(_ theme: ThemeProtocol) {
    }
}

public class ReplyFeature {
    /// Determines if ReplyFeature functionality is enabled.
    public var enable: Bool = true
}

public struct ReplyUISettings {
    
    public init(_ theme: ThemeProtocol) {
    }
}

public class RegexFeature {
    public var userName = "^(?=[a-zA-Z])[-a-zA-Z_ ]{3,49}(?<! )$"
    public var dialogName = "^(?=.{3,60}$)(?!.*([\\s])\\1{2})[\\w\\s]+$"
}

public class ToolbarFeature {
    public var enable: Bool = true
    public var externalIndexes: [TabIndex] = [.settings]
}

public struct ToolbarUISettings {
    public var backgroundColor: Color
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
    }
}

public struct TabIndex: Hashable {
    public var title: String
    public var systemIcon: String
    
    public init(title: String, systemIcon: String) {
        self.title = title
        self.systemIcon = systemIcon
    }
}

public extension TabIndex {
    static let dialogs = TabIndex(title: "Dialogs",
                                  systemIcon: "message.fill")
    static let settings = TabIndex(title: "Settings",
                                   systemIcon: "gearshape.fill")
}

public enum StartScreens {
    case dialogs
    case dialog
}

public class StartScreenFeature {
    public var screen: StartScreens = .dialogs
}
