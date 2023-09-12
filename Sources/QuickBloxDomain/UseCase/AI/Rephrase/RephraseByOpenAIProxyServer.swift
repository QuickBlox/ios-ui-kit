//
//  RephraseByOpenAIProxyServer.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QBAIRephrase

public class RephraseByOpenAIProxyServer<Tone>: AIFeatureUseCaseProtocol where Tone: QBAIRephrase.Tone {
    private let serverURLPath: String
    private let tone: Tone
    private let content: String
    
    public init(_ serverURLPath: String, tone: Tone, content: String) {
        self.serverURLPath = serverURLPath
        self.tone = tone
        self.content = content
    }
    
    public func execute() async throws -> String {
        guard let qbToken = QBSession.current.sessionDetails?.token else {
            throw RepositoryException.unauthorised()
        }
        
        return try await QBAIRephrase.openAI(rephrase: content,
                                             using: tone,
                                             qbToken: qbToken,
                                             proxy: serverURLPath)
    }
}
