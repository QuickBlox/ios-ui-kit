//
//  PaginationProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 07.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import Foundation

public protocol PaginationProtocol {
    var skip: Int { get set }
    var limit: Int { get }
    var total: Int { get }
    var hasNext: Bool { get set}
    init(skip: Int, limit: Int, total: Int)
    mutating func next()
}

extension PaginationProtocol {
    public mutating func next() {
        self.skip += self.limit
    }
}
