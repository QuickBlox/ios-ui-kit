//
//  RephraseByOpenAIAPI.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QBAIRephrase

public class RephraseByOpenAIAPI<Tone>: AIFeatureUseCaseProtocol where Tone: QBAIRephrase.Tone {
    private let apiKey: String
    private let tone: Tone
    private let content: String

    public init(_ apiKey: String, tone: Tone, content: String) {
        self.apiKey = apiKey
        self.tone = tone
        self.content = content
    }
    
    public func execute() async throws -> String {
        
        return try await QBAIRephrase.openAI(rephrase: content,
                                             using: tone,
                                             secret: apiKey)
    }
}
