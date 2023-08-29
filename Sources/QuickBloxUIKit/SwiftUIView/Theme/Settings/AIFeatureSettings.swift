//
//  AIFeatureSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QBAITranslate

public enum AIFeatureType {
    case answerAssist, translate, rephrase
}

public class Feature {
    /// An instance of the AI module for AI-related settings and operations.
    public var aiFeature: AIFeature = AIFeature()
    
}

public class AIFeature {
    /// Determines if AIfunctionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var openAIAPIKey = "" {
        didSet {
            if assistAnswer.openAIAPIKey.isEmpty {
                assistAnswer.openAIAPIKey = openAIAPIKey
            }
            if translate.openAIAPIKey.isEmpty {
                translate.openAIAPIKey = openAIAPIKey
            }
            if rephrase.openAIAPIKey.isEmpty {
                rephrase.openAIAPIKey = openAIAPIKey
            }
        }
    }
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var proxyServerURLPath = "" {
        didSet {
            if assistAnswer.proxyServerURLPath.isEmpty {
                assistAnswer.proxyServerURLPath = proxyServerURLPath
            }
            if translate.proxyServerURLPath.isEmpty {
                translate.proxyServerURLPath = proxyServerURLPath
            }
            if rephrase.proxyServerURLPath.isEmpty {
                rephrase.proxyServerURLPath = proxyServerURLPath
            }
        }
    }
    
    /// Settings for assist answer functionality using the OpenAI API key or QuickBlox token and proxy server.
    public var assistAnswer: AIAnswerAssistSettings =
    AIAnswerAssistSettings(enable: true,
                           openAIToken: "",
                           proxyServerURLPath: "")
    
    /// Settings for translation functionality using the OpenAI API key or QuickBlox token and proxy server.
    public var translate: AITranslateSettings =
    AITranslateSettings(enable: true,
                        openAIToken: "",
                        proxyServerURLPath: "",
                        locale: Locale.current)
    
    /// Settings for edit functionality using the OpenAI API key or QuickBlox token and proxy server.
    public var rephrase: AIRephraseSettings =
    AIRephraseSettings(enable: false,
                       openAIToken: "",
                       proxyServerURLPath: "")
}

/// Settings for assist answer functionality.
public class AIAnswerAssistSettings {
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var openAIAPIKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var proxyServerURLPath: String = ""
    
    /// Indicates if the AI settings are valid, i.e., either the OpenAI API key or proxy server URL is provided.
    public var isValid: Bool {
        return openAIAPIKey.isEmpty == false || proxyServerURLPath.isEmpty == false
    }
    
    /// Initializes the AIAnswerAssistSettings with the given values.
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

/// Settings for translation functionality.
public class AITranslateSettings {
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = true
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var openAIAPIKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var proxyServerURLPath: String = ""
    
    /// Indicates if the AI settings are valid, i.e., either the OpenAI API key or proxy server URL is provided.
    public var isValid: Bool {
        return openAIAPIKey.isEmpty == false || proxyServerURLPath.isEmpty == false
    }
    
    /// Initializes the AITranslateSettings with the given values.
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

extension AITranslateSettings: QBAITranslate.LanguageSettings {
    
    /// The current language as a localized string. System language by default.
    public var language: String {
        QBAITranslate.settings.language
    }
    
    /// Sets a custom language using a `QBAITranslate.Language` enum case.
    /// - Parameter language: The language to set.
    public func setCustom(language: QBAITranslate.Language) {
        QBAITranslate.settings.setCustom(language: language)
    }
    
    /// Sets a custom language using a `Locale` object.
    ///
    /// Use this method to set a custom language using a `Locale` object.
    /// ```
    /// settings.setCustomLanguage(from: Locale(identifier: "es-US"))
    /// ```
    ///
    /// To see available `Locale` identifiers, you can use the following code:
    /// ```
    /// print(Locale.availableIdentifiers)
    /// ```
    ///
    /// - Parameter locale: The locale to set. Provide a `Locale` object corresponding to
    ///                     the desired language and region.
    public func setCustomLanguage(from locale: Locale) {
        QBAITranslate.settings.setCustomLanguage(from: locale)
    }
    
    /// Resets the custom language and falls back to the system locale.
    public func resetLanguage() {
        QBAITranslate.settings.resetLanguage()
    }
    
    public convenience init(enable: Bool, openAIToken: String, proxyServerURLPath: String, locale: Locale) {
        self.init(enable: enable, openAIToken: openAIToken, proxyServerURLPath: proxyServerURLPath)
        self.setCustomLanguage(from: locale)
    }
}

/// Settings for rephrase functionality.
public class AIRephraseSettings {
    public var tones: [AITone] = aiRephraseTones
    
    /// Determines if assist answer functionality is enabled.
    public var enable: Bool = false
    
    /// The OpenAI API key for direct API requests (if not using a proxy server).
    public var openAIAPIKey: String = ""
    
    /// The URL path of the proxy server for more secure communication (if not using the API key directly).
    /// [QuickBlox AI Assistant Proxy Server](https://github.com/QuickBlox/qb-ai-assistant-proxy-server).
    public var proxyServerURLPath: String = ""
    
    /// Indicates if the AI settings are valid, i.e., either the OpenAI API key or proxy server URL is provided.
    public var isValid: Bool {
        return openAIAPIKey.isEmpty == false || proxyServerURLPath.isEmpty == false
    }
    
    /// Initializes the AIRephraseSettings with the given values.
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

public protocol AIToneProtocol {
    var type: String { get set }
    var name: String { get set }
    var icon: String { get set }
}

public struct AITone: AIToneProtocol, Hashable {
    public var type: String
    public var name: String
    public var icon: String
}

public var aiRephraseTones: [AITone] = [
    AITone(type: "original", name: "Back to original text", icon: "✅"),
    AITone(type: "professional", name: "Professional Tone", icon: "👔"),
    AITone(type: "friendly", name: "Friendly Tone", icon: "🤝"),
    AITone(type: "encouraging", name: "Encouraging Tone", icon: "💪"),
    AITone(type: "empathetic", name: "Empathetic Tone", icon: "🤲"),
    AITone(type: "neutral", name: "Neutral Tone", icon: "😐"),
    AITone(type: "assertive", name: "Assertive Tone", icon: "🔨"),
    AITone(type: "instructive", name: "Instructive Tone", icon: "📖"),
    AITone(type: "persuasive", name: "Persuasive Tone", icon: "☝️"),
    AITone(type: "sarcastic", name: "Sarcastic/Ironic Tone", icon: "😏"),
    AITone(type: "poetic", name: "Poetic Tone", icon: "🎭")
]
