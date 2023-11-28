//
//  FeatureSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 19.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

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
