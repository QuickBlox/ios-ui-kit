//
//  Entity.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.12.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

import Foundation
import QuickBloxLog

/// Helps ensure that the systems that produce the data and the systems that consume the data are working with the same set of rules and requirements.
public protocol Entity: Identifiable,
                        Equatable,
                        Hashable,
                        DataStringConvertible { }

public protocol DataStringConvertible: CustomStringConvertible, Codable {}

extension DataStringConvertible {
    public var description: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let description = String(describing: Self.self)
        guard let json = try? encoder.encode(self),
              let info = String(data: json, encoding: .utf8) else {
            return description
        }
        
        return info
    }
}

public struct Warning {
    public static func push(_ info: String = "") {
        do {let warning = "Warning. \(info)"
            throw RepositoryException.incorrectData(description: warning)
        } catch { prettyLog(error) }
    }
}
