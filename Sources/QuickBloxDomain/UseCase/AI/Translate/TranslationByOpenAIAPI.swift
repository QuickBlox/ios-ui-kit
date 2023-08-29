//
//  TranslationByOpenAIAPI.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 08.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QBAITranslate

public class TranslationByOpenAIAPI: AIFeatureUseCaseProtocol {
    private let apiKey: String
    private let content: any MessageEntity
    
    public init(_ apiKey: String, content: any MessageEntity) {
        self.apiKey = apiKey
        self.content = content
    }
    
    public func execute() async throws -> String {
        return try await QBAITranslate.openAI(translate: content.text,
                                              secret: apiKey)
    }
}
