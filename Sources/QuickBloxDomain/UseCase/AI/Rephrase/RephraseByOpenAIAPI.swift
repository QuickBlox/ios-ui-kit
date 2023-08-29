//
//  RephraseByOpenAIAPI.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
//import QBAIRephrase

public class RephraseByOpenAIAPI: AIFeatureUseCaseProtocol {
    private let apiKey: String
    private let tone: String
    private let content: String

    public init(_ apiKey: String, tone: String, content: String) {
        self.apiKey = apiKey
        self.tone = tone
        self.content = content
    }
    
    public func execute() async throws -> String {
        
        return tone
        
        //        return try await QBAIRephrase.openAIRephrase(tone: tone,
        //                                                          to: content,
        //                                                          secret: apiKey)
    }
}
