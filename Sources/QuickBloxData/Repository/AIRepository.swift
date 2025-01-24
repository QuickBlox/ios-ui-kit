//
//  AIRepository.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxDomain

/// This is a class that implements the ``AIRepositoryProtocol`` protocol and contains methods and properties that allow it to interact with the ``AnswerAssistMessage`` items.
public class AIRepository {
    private let remote: RemoteDataSourceProtocol
    
    public init(remote: RemoteDataSourceProtocol) {
        self.remote = remote 
    }
}

extension AIRepository: AIRepositoryProtocol {

    public func answerAssist(message entity: AnswerAssistMessage) async throws -> String {
        do {
            return try await remote.answerAssist(message: RemoteAnswerAssistMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
    
    public func translate(message entity: TranslateMessage) async throws -> String {
        do {
            return try await remote.translate(message: RemoteTranslateMessageDTO(entity))
        } catch {
            throw try error.repositoryException
        }
    }
}

private extension RemoteAnswerAssistMessageDTO {
    init(_ value: AnswerAssistMessage) {
        id = value.id
        smartChatAssistantId = value.smartChatAssistantId
        message = value.message
        history = value.history.compactMap({ RemoteAnswerAssistHistoryMessageDTO($0) })
    }
}

private extension RemoteAnswerAssistHistoryMessageDTO {
    init(_ value: AnswerAssistHistoryMessage) {
        id = value.id
        role = value.role
        message = value.message
    }
}

private extension RemoteTranslateMessageDTO {
    init(_ value: TranslateMessage) {
        id = value.id
        message = value.message
        smartChatAssistantId = value.smartChatAssistantId
        languageCode = value.languageCode
    }
}
