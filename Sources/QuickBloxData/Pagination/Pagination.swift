//
//  Pagination.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 07.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import Foundation
import QuickBloxDomain

public struct Pagination: PaginationProtocol {
    public var skip: Int
    public let limit: Int
    public let total: Int
    
    var currentPage: Int {
        return skip / limit + (skip % limit == 0 ? 0 : 1)
    }
    
    var totalPages: Int {
        return (total + limit - 1) / limit
    }
    
    public var hasNextPage: Bool = false
    
    public init(skip: Int, limit: Int, total: Int) {
        self.skip = skip
        self.limit = limit
        self.total = total
    }
    
    init(page: Int = 1, perPage: Int = 10, total: Int = 0) {
        self.skip = (page - 1) * perPage
        self.limit = perPage
        self.total = total
    }
}
