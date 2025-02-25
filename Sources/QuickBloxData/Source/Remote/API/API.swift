//
//  API.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox

extension QBResponse {
    var remoteError: Error {
        let unexpected = DataSourceException.unexpected()
        let error = error?.error ?? unexpected
        return error
    }
}

extension Pagination {
    init(_ page: QBGeneralResponsePage) {
        self.init(page: Int(page.currentPage),
                  perPage: Int(page.perPage),
                  total: Int(page.totalEntries))
        self.hasNext = self.total > self.skip + self.limit
    }
}

extension Pagination {
    init(_ page: QBResponsePage) {
        self.init(skip: page.skip,
                  limit: page.limit,
                  total: Int(page.totalEntries))
        self.hasNext = self.total > self.skip + self.limit
    }
}

extension QBGeneralResponsePage {
    convenience init(_ pagination: Pagination) {
        self.init(currentPage: UInt(pagination.currentPage + 1),
                  perPage: UInt(pagination.limit),
                  totalEntries: 0)
    }
}

extension QBResponsePage {
    convenience init(_ pagination: Pagination) {
        self.init(limit: pagination.limit, skip: pagination.skip)
    }
}

public struct API {
    public let dialogs = APIDialogs()
    public let users = APIUsers()
    public let messages = APIMessages()
    public let files = APIFiles()
    public let ai = APIAI()
}
