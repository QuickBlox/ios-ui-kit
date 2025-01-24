//
//  Feature.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 27.01.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public class Feature {
    /// An instance of the AI module for AI-related settings and operations.
    public var ai: AIFeature = AIFeature()
    
    /// An instance of the ForwardFeature settings and operations.
    public var forward: ForwardFeature = ForwardFeature()
    
    /// An instance of the ReplyFeature settings and operations.
    public var reply: ReplyFeature = ReplyFeature()
    
    /// An instance of the RegexFeature settings and operations.
    public var regex: RegexFeature = RegexFeature()
    
    /// An instance of the ToolbarFeature settings and operations.
    public var toolbar: ToolbarFeature = ToolbarFeature()
    
    /// An instance of the StartScreenFeature settings and operations.
    public var startScreen: StartScreenFeature = StartScreenFeature()
}
