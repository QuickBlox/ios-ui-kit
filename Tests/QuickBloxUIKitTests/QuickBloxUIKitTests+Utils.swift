//
//  QuickBloxUIKitTests+Utils.swift
//  QuickBloxUIKitTests
//
//  Created by Injoit on 29.12.2022.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import XCTest
import QuickBloxLog

/// Async throws and comparison the exceptions
func XCTAssertThrowsException<T, E>(
    _ expression: @autoclosure () async throws -> T,
    equelTo expression2: @autoclosure () -> E,
    file: StaticString = #filePath,
    line: UInt = #line,
    function: String = #function.components(separatedBy: "(")[0]
) async where E: Equatable, E: Error {
    do {
        _ = try await expression()
        let reason = "did not throw an error"
        XCTFail(message(reason, function), file: file, line: line)
    } catch let exception as E where exception == expression2() {
        
    } catch {
        let reason = ".\(error) is not equal to .\(expression2())"
        XCTFail(message(reason, function), file: file, line: line)
    }
}

enum XCTException: Error {
    case unexpected
}

/// Async no throws
func XCTAssertNoThrowsException<T>(
    _ expression: @autoclosure () async throws -> T,
    file: StaticString = #filePath,
    line: UInt = #line,
    function: String = #function.components(separatedBy: "(")[0]
) async throws -> T {
    do {
        return try await expression() as T
    } catch {
        let reason = "\(error.localizedDescription)"
        XCTFail(message(reason, function), file: file, line: line)
    }
    throw XCTException.unexpected
}

/// Сomparison result with test object
func XCTAssertResultNotEqual<T, U>(
    _ expression1: @autoclosure () -> T,
    _ expression2: @autoclosure () -> U,
    file: StaticString = #filePath,
    line: UInt = #line,
    function: String = #function.components(separatedBy: "(")[0]
) where U : Equatable {
    let entity = expression1()
    let entity2 = expression2()
    
    guard let entity1 = entity as? U else {
        return
    }
    
    if entity1 == entity2 {
        let reason = "\(entity1) is equel to \(entity2)"
        XCTFail(message(reason, function), file: file, line: line)
        return
    }
}

fileprivate func message(
    _ reason: String,
    _ function: String
) -> String {
    return function + " failed: " + reason
}
