//
//  AIFeatureSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QBAITranslate
import QBAIRephrase
import QBAIAnswerAssistant

public class Feature {
    /// An instance of the AI module for AI-related settings and operations.
    public var ai: AIFeature = AIFeature()
    
    /// An instance of the ForwardFeature settings and operations.
    public var forward: ForwardFeature = ForwardFeature()
    
    /// An instance of the ReplyFeature settings and operations.
    public var reply: ReplyFeature = ReplyFeature()
}

public class AIFeature {
    /// Determines if AIfunctionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var apiKey = "" {
        didSet {
            if answerAssist.apiKey.isEmpty {
                answerAssist.apiKey = apiKey
            }
            if translate.apiKey.isEmpty {
                translate.apiKey = apiKey
            }
            if rephrase.apiKey.isEmpty {
                rephrase.apiKey = apiKey
            }
        }
    }
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var serverPath = "" {
        didSet {
            if answerAssist.serverPath.isEmpty {
                answerAssist.serverPath = serverPath
            }
            if translate.serverPath.isEmpty {
                translate.serverPath = serverPath
            }
            if rephrase.serverPath.isEmpty {
                rephrase.serverPath = serverPath
            }
        }
    }
    
    /// Settings for assist answer functionality using the OpenAI API key or QuickBlox token and proxy server.
    public var answerAssist: AIAnswerAssistSettings =
    AIAnswerAssistSettings(enable: true,
                           apiKey: "",
                           serverPath: "")
    
    /// Settings for translation functionality using the OpenAI API key or QuickBlox token and proxy server.
    public var translate: AITranslateSettings =
    AITranslateSettings(enable: true,
                        apiKey: "",
                        serverPath: "")
    
    /// Settings for edit functionality using the OpenAI API key or QuickBlox token and proxy server.
    public var rephrase: AIRephraseSettings =
    AIRephraseSettings(enable: true,
                       apiKey: "",
                       serverPath: "")
    
    public var ui: AIUISettings = AIUISettings(QuickBloxUIKit.settings.theme)
}

/// Settings for assist answer functionality.
public class AIAnswerAssistSettings {
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var apiKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var serverPath: String = ""
    
    /// Represents the available API versions for OpenAI.
    public var apiVersion: QBAIAnswerAssistant.APIVersion = .v1
    
    /// Optional organization information for OpenAI requests.
    public var organization: String? = nil
    
    /// Represents the available GPT models for OpenAI.
    public var model: QBAIAnswerAssistant.Model = .gpt3_5_turbo
    
    /// The temperature setting for generating responses (higher values make output more random).
    public var temperature: Float = 0.5
    
    /// The maximum number of tokens to generate in the request.
    public var maxRequestTokens: Int = 3000
    
    /// The maximum number of tokens to generate in the response.
    public var maxResponseTokens: Int? = nil
    
    /// Indicates if the AI settings are valid, i.e., either the OpenAI API key or proxy server URL is provided.
    public var isValid: Bool {
        return apiKey.isEmpty == false || serverPath.isEmpty == false
    }
    
    /// Initializes the AIAnswerAssistSettings with the given values.
    /// - Parameters:
    ///   - enable: Determines if assist answer functionality is enabled.
    ///   - apiKey: The OpenAI API key for direct API requests (if not using a proxy server).
    ///   - serverPath: The URL path of the proxy server for more secure communication (if not using the API key directly).
    required public init(enable: Bool, apiKey: String, serverPath: String) {
        self.enable = enable
        self.apiKey = apiKey
        self.serverPath = serverPath
    }
}

/// Settings for translation functionality.
public class AITranslateSettings {
    private var _language: QBAITranslate.Language? = nil
    
    /// The current `QBAITranslate.Language`.
    ///
    /// Default the same as system language or `.english` if `QBAITranslate.Language` is not support system language.
    public var language: QBAITranslate.Language {
        get {
            guard let value = _language else {
                let currentName = Locale.current.localizedLanguageName
                for language in QBAITranslate.Language.allCases {
                    if language.locale.localizedLanguageName == currentName {
                        return language
                    }
                }
                
                return QBAITranslate.Language.english
            }
            
            return value
        } set {
            _language = newValue
        }
    }
    
    /// Determines if translation functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var apiKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var serverPath: String = ""
    
    /// Represents the available API versions for OpenAI.
    public var apiVersion: QBAITranslate.APIVersion = .v1
    
    /// Optional organization information for OpenAI requests.
    public var organization: String? = nil
    
    /// Represents the available GPT models for OpenAI.
    public var model: QBAITranslate.Model = .gpt3_5_turbo
    
    /// The temperature setting for generating responses (higher values make output more random).
    public var temperature: Float = 0.5
    
    /// The maximum number of tokens to generate in the request.
    public var maxRequestTokens: Int = 3000
    
    /// The maximum number of tokens to generate in the response.
    public var maxResponseTokens: Int? = nil
    
    /// Indicates if the AI settings are valid, i.e., either the OpenAI API key or proxy server URL is provided.
    public var isValid: Bool {
        return apiKey.isEmpty == false || serverPath.isEmpty == false
    }
    
    /// Initializes the AITranslateSettings with the given values.
    /// - Parameters:
    ///   - enable: Determines if assist answer functionality is enabled.
    ///   - apiKey: The OpenAI API key for direct API requests (if not using a proxy server).
    ///   - serverPath: The URL path of the proxy server for more secure communication (if not using the API key directly).
    required public init(enable: Bool, apiKey: String, serverPath: String) {
        self.enable = enable
        self.apiKey = apiKey
        self.serverPath = serverPath
    }
}

/// Settings for rephrase functionality.
public class AIRephraseSettings {
    public var tones: [QBAIRephrase.AITone] = [
        QBAIRephrase.AITone.professional,
        QBAIRephrase.AITone.friendly,
        QBAIRephrase.AITone.encouraging,
        QBAIRephrase.AITone.empathetic,
        QBAIRephrase.AITone.neutral,
        QBAIRephrase.AITone.assertive,
        QBAIRephrase.AITone.instructive,
        QBAIRephrase.AITone.persuasive,
        QBAIRephrase.AITone.sarcastic,
        QBAIRephrase.AITone.poetic
    ]
    
    /// Determines if rephrase functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var apiKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var serverPath: String = ""
    
    /// Represents the available API versions for OpenAI.
    public var apiVersion: QBAIRephrase.APIVersion = .v1
    
    /// Optional organization information for OpenAI requests.
    public var organization: String? = nil
    
    /// Represents the available GPT models for OpenAI.
    public var model: QBAIRephrase.Model = .gpt3_5_turbo
    
    /// The temperature setting for generating responses (higher values make output more random).
    public var temperature: Float = 0.5
    
    /// The maximum number of tokens to generate in the request.
    public var maxRequestTokens: Int = 3000
    
    /// The maximum number of tokens to generate in the response.
    public var maxResponseTokens: Int? = nil
    
    /// Indicates if the AI settings are valid, i.e., either the OpenAI API key or proxy server URL is provided.
    public var isValid: Bool {
        return apiKey.isEmpty == false || serverPath.isEmpty == false
    }
    
    /// Initializes the AIRephraseSettings with the given values.
    /// - Parameters:
    ///   - enable: Determines if assist answer functionality is enabled.
    ///   - apiKey: The OpenAI API key for direct API requests (if not using a proxy server).
    ///   - serverPath: The URL path of the proxy server for more secure communication (if not using the API key directly).
    required public init(enable: Bool, apiKey: String, serverPath: String) {
        self.enable = enable
        self.apiKey = apiKey
        self.serverPath = serverPath
    }
}

public extension QBAIRephrase.AITone {
    static let professional = QBAIRephrase.AITone (
        name: "Professional",
        description: "This would edit messages to sound more formal, using technical vocabulary, clear sentence structures, and maintaining a respectful tone. It would avoid colloquial language and ensure appropriate salutations and sign-offs.",
        icon: "👔"
    )
    
    static let friendly = QBAIRephrase.AITone (
        name: "Friendly",
        description: "This would adjust messages to reflect a casual, friendly tone. It would incorporate casual language, use emoticons, exclamation points, and other informalities to make the message seem more friendly and approachable.",
        icon: "🤝"
    )
    
    static let encouraging = QBAIRephrase.AITone (
        name: "Encouraging",
        description: "This tone would be useful for motivation and encouragement. It would include positive words, affirmations, and express support and belief in the recipient.",
        icon: "💪"
    )
    
    static let empathetic = QBAIRephrase.AITone (
        name: "Empathetic",
        description: "This tone would be utilized to display understanding and empathy. It would involve softer language, acknowledging feelings, and demonstrating compassion and support.",
        icon: "🤲"
    )
    
    static let neutral = QBAIRephrase.AITone (
        name: "Neutral",
        description: "For times when you want to maintain an even, unbiased, and objective tone. It would avoid extreme language and emotive words, opting for clear, straightforward communication.",
        icon: "😐"
    )
    
    static let assertive = QBAIRephrase.AITone (
        name: "Assertive",
        description: "This tone is beneficial for making clear points, standing ground, or in negotiations. It uses direct language, is confident, and does not mince words.",
        icon: "🔨"
    )
    
    static let instructive = QBAIRephrase.AITone (
        name: "Instructive",
        description: "This tone would be useful for tutorials, guides, or other teaching and training materials. It is clear, concise, and walks the reader through steps or processes in a logical manner.",
        icon: "📚"
    )
    
    static let persuasive = QBAIRephrase.AITone (
        name: "Persuasive",
        description: "This tone can be used when trying to convince someone or argue a point. It uses persuasive language, powerful words, and logical reasoning.",
        icon: "👆"
    )
    
    static let sarcastic = QBAIRephrase.AITone (
        name: "Sarcastic/Ironic",
        description: "This tone can make the communication more humorous or show an ironic stance. It is harder to implement as it requires the AI to understand nuanced language and may not always be taken as intended by the reader.",
        icon: "😏"
    )
    
    static let poetic = QBAIRephrase.AITone (
        name: "Poetic",
        description: "This would add an artistic touch to messages, using figurative language, rhymes, and rhythm to create a more expressive text.",
        icon: "🎭"
    )
}

public struct AIUISettings {
    public var translate: AITranslateUISettings
    public var answerAssist: AIAnswerAssistUISettings
    public var rephrase: AIRephraseUISettings
    public var answerFailed: AIAnswerFailedSettings
    
    public var robot: AIRobotSettings
    
    public init(_ theme: ThemeProtocol) {
        self.translate = AITranslateUISettings(theme)
        self.answerAssist = AIAnswerAssistUISettings(theme)
        self.rephrase = AIRephraseUISettings(theme)
        self.answerFailed = AIAnswerFailedSettings(theme)
        
        self.robot = AIRobotSettings(theme)
    }
}

public struct AIAnswerFailedSettings {
    public var font: Font
    public var foreground: Color
    public var background: Color
    public var padding: EdgeInsets = EdgeInsets(top: 2,
                                                leading: 8,
                                                bottom: 2,
                                                trailing: 8)
    public var hidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.font = theme.font.caption
        self.foreground = theme.color.system
        self.background = theme.color.tertiaryBackground
    }
}

public struct AIRobotSettings {
    public var icon: Image
    public var foreground: Color
    public var size: CGSize = CGSize(width: 24.0, height: 24.0)
    public var hidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.icon = theme.image.robot
        self.foreground = theme.color.mainElements
    }
}

public struct AIRephraseUISettings {
    public var nameForeground: Color
    public var nameFont: Font
    public var iconFont: Font
    public var bubbleBackground: Color
    public var bubbleRadius: CGFloat = 12.5
    public var contentSpacing: CGFloat = 4.0
    public var buttonHeight: CGFloat = 52.0
    public var contentPadding: EdgeInsets = EdgeInsets(top: 8,
                                                leading: 4,
                                                bottom: 0,
                                                trailing: 4)
    
    public var bubblePadding: EdgeInsets = EdgeInsets(top: 6,
                                                      leading: 8,
                                                      bottom: 6,
                                                      trailing: 8)
    
    public init(_ theme: ThemeProtocol) {
        self.nameForeground = theme.color.mainText
        self.nameFont = theme.font.callout
        self.iconFont = theme.font.caption
        self.bubbleBackground = theme.color.outgoingBackground
    }
}

public struct AITranslateUISettings {
    public var showOriginal: String
    public var showTranslation: String
    public var width: CGFloat
    public var buttonOffset: CGFloat = 18.0
    
    public init(_ theme: ThemeProtocol) {
        self.showOriginal = theme.string.showOriginal
        self.showTranslation = theme.string.showTranslation
        self.width = max(self.showTranslation, self.showOriginal)
            .size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)])
            .width + 24.0
    }
}

public struct AIAnswerAssistUISettings {
    public var title: String
    
    public init(_ theme: ThemeProtocol) {
        self.title = theme.string.answerAssistTitle
    }
}

public enum AIFeatureType {
    case answerAssist, translate, rephrase
    
    var invalid: String {
        switch self {
        case .answerAssist: return QuickBloxUIKit.settings.theme.string.invalidAIAnswerAssist
        case .translate: return QuickBloxUIKit.settings.theme.string.invalidAITranslate
        case .rephrase: return QuickBloxUIKit.settings.theme.string.invalidAIRephrase
        }
    }
    
    var answerFailed: String {
        switch self {
        case .answerAssist: return QuickBloxUIKit.settings.theme.string.answerFailedAnswerAssist
        case .translate: return QuickBloxUIKit.settings.theme.string.answerFailedTranslate
        case .rephrase: return QuickBloxUIKit.settings.theme.string.answerFailedRephrase
        }
    }
}
