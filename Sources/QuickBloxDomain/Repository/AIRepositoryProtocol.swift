//
//  AIRepositoryProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 16.05.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// Provides a set of methods for getting, saving and manipulating with ``AnswerAssistMessageEntity`` and  ``TranslateMessageEntity`` items.
public protocol AIRepositoryProtocol {
    associatedtype AnswerAssistMessageEntityItem: AnswerAssistMessageEntity
    associatedtype TranslateMessageEntityItem: TranslateMessageEntity
    
    /// Retrieve an ai answer assist from a remote storage.
    /// - Parameter message: ``AnswerAssistMessageEntity`` item you want to get answer for.
    /// - Returns: answer.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData** when wrong format of data, missing required fields, or providing incorrect values.
    func answerAssist(message entity: AnswerAssistMessageEntityItem) async throws -> String
    
    /// Retrieve a translate from a remote storage.
    /// - Parameter message: ``TranslateMessageEntity`` item to translate.
    /// - Returns: translate.
    ///
    /// - Throws: ``RepositoryException``**.incorrectData**  when a translate is missing from remote storage.
    func translate(message entity: TranslateMessageEntityItem) async throws -> String
}
