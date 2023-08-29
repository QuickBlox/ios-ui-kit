//
//  TranslationByOpenAIProxyServer.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 08.08.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QBAITranslate

public class TranslationByOpenAIProxyServer: AIFeatureUseCaseProtocol {
    private let serverURLPath: String
    private let content: any MessageEntity
    
    public init(_ serverURLPath: String, content: any MessageEntity) {
        self.serverURLPath = serverURLPath
        self.content = content
    }
    
    public func execute() async throws -> String {
        guard let qbToken = QBSession.current.sessionDetails?.token else {
            throw RepositoryException.unauthorised()
        }
        
        return try await QBAITranslate.openAI(translate: content.text,
                                              qbToken: qbToken,
                                              proxy: serverURLPath)
    }
}
