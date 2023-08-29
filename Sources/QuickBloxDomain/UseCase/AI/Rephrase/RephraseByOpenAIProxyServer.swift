//
//  RephraseByOpenAIProxyServer.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 11.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
//import QBAIRephrase

public class RephraseByOpenAIProxyServer: AIFeatureUseCaseProtocol {
    private let serverURLPath: String
    private let tone: String
    private let content: String
    
    public init(_ serverURLPath: String, tone: String, content: String) {
        self.serverURLPath = serverURLPath
        self.tone = tone
        self.content = content
    }
    
    public func execute() async throws -> String {
        guard let qbToken = QBSession.current.sessionDetails?.token else {
            throw RepositoryException.unauthorised()
        }
        
        return tone
        
//        return try await QBAIRephrase.openAIRephrase(tone: tone,
//                                                          to: content,
//                                                          qbToken: qbToken,
//                                                          proxy: serverURLPath)
    }
}
