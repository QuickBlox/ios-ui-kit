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
    var hasNextPage: Bool { get set}
    init(skip: Int, limit: Int, total: Int)
}

extension PaginationProtocol {
    public init(skip: Int, limit: Int = 10, total: Int = 0) {
        self.init(skip: skip, limit: limit, total: total)
    }
    
    public init(page: Int = 1, perPage: Int = 10, total: Int = 0) {
        self.init(skip: ((page - 1) * perPage),
                  limit: perPage,
                  total: total)
    }
}
