//
//  Result+Utils.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxData
import QuickBloxLog

extension Result where Success: Collection {
    func getFirst<T>() throws -> T {
        let results = try self.get()
        
        guard let result = results.first as? T else {
            let info = "\(self.self) " + #function +
            " failed: there result is missing or not respond \(T.self)"
            throw DataSourceException.unexpected(info)
        }
        
        return result
    }
    
    func getResults<T>() throws -> T {
        let results = try self.get()
        
        guard let result = results as? T else {
            let info = "\(self.self) " + #function +
            " failed: there result is missing or not respond \(T.self)"
            throw DataSourceException.unexpected(info)
        }
        
        return result
    }
}

struct AcyncMockVoid {
    let seconds: Task.SecondsDuration = .default
    let closure: () -> Void
}

struct AcyncMockReturn<T: Any> {
    let seconds: Task.SecondsDuration = .default
    let closure: () -> T
}

struct AcyncMockError {
    let closure: () -> Error
}

extension Result where Success: Collection {
    func callAcyncVoid() async throws {
        switch self {
        case .success(let ressult):
            if let mock: AcyncMockVoid = ressult.first as? AcyncMockVoid {
                try await Task.sleep(mock.seconds)
                mock.closure()
            } else if let mock = ressult.first as? AcyncMockError {
                throw mock.closure()
            }  else {
                let info = "info is not a AcyncMock"
                throw DataSourceException.unexpected(info)
            }
        case .failure(let exception):
            throw exception
        }
    }
    
    func callAcyncReturn<T: Any>() async throws -> T {
        switch self {
        case .success(let ressult):
            if let mock = ressult.first as? AcyncMockReturn<T> {
                try await Task.sleep(mock.seconds)
                return mock.closure()
            } else if let mock = ressult.first as? AcyncMockError {
                throw mock.closure()
            } else {
                let info = "info is not a AcyncMock"
                throw DataSourceException.unexpected(info)
            }
        case .failure(let exception):
            throw exception
        }
    }
}

extension Task where Success == Never, Failure == Never {
    enum SecondsDuration: Double {
        case `default` = 0.1
        case double = 0.2
        case triple = 0.3
        case halfSecond = 0.5
        case second = 1.0
        case twoSeconds = 2.0
    }
    
    static func sleep(_ seconds: SecondsDuration) async throws {
        let duration = UInt64(seconds.rawValue * 1_000_000_000)
        do {
            try await Task.sleep(nanoseconds: duration)
        } catch { prettyLog(error) }
    }
}

import QuickBloxDomain
class Mock {
    var results: [String: Result<[Any], Error>]
    
    var mockMetods: [String] {
        return Array(results.keys)
    }
    
    init(_ results: [String: Result<[Any], Error>] = [:]) {
        self.results = results
    }
    
    func mock(function: String = #function) throws -> Result<[Any], Error> {
        guard let mock = results[function] else {
            throw RepositoryException.unexpected("mock function")
        }
        results.removeValue(forKey: function)
        return mock
    }
}
