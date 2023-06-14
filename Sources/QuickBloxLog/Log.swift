//
//  SyncDialogsTests.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 09.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

enum LogType {
    case nothing
    case details
}

struct LogSettings {
    static var type: LogType = .details
}

public struct LogSeparator {
    static let lower = LogSeparator("_")
    static let center = LogSeparator("-")
    static let upArrow = LogSeparator("^")
    
    static let width = 60
    
    let value: String
    
    init(_ part: String, width: Int = LogSeparator.width) {
        var separator = ""
        for _ in 0...width { separator += part }
        value = separator
    }
}

public struct Log {
    public let value: String
    
    public init() { value = "" }
    public init(_ value: String) { self.value = value }
    public init(_ log: Log) { value = log.value }
    init(_ value: String, append: String) { self.value = value + append }
}

//MARK: Log Line Wrapping
public extension Log {
    var nextLine: Log { self.add("\r") }
    var newLine: Log { self.add("\n") }
    var space: Log { self.add(" ") }
    var tab: Log { self.add("\t")}
    var colon: Log { self.add(": ") }
    var coma: Log { self.add(", ") }
}

//MARK: Log Conntent
public extension Log {
    func add(_ content: String) -> Log {
        Log(self.value, append: content)
    }
    
    func add(_ content: Int) -> Log {
        self.add("\(content)")
    }
    
    func add(_ log: Log) -> Log {
        self.add(log.value)
    }
    
    func add(separator: LogSeparator) -> Log {
        self.add(separator.value).nextLine
    }
    
    func add(tag: String) -> Log {
        self.add("[\(tag)]")
    }
    
    func add(specification: Log) -> Log {
        self.add("(\(specification.value))")
    }
}

//MARK: Tags
extension Log {
    struct Tags {
        @propertyWrapper struct Tag {
            var wrappedValue: String {
                didSet { wrappedValue = "[\(wrappedValue)]" }
            }
            
            init(wrappedValue: String) {
                self.wrappedValue = "[\(wrappedValue)]"
            }
        }
        
        @Tag var icon: String
        @Tag var module: String
        @Tag var file: String
        @Tag var method: String
        
        init(_ fileId: String, _ function: String, _ isError: Bool) {
            icon = isError ? "⚠️" : "✅"
            let components = fileId.components(separatedBy: "/")
            module = components[0]
            file = components[1]
            if function.last == ")",
               let name = function.components(separatedBy: "(").first {
                method = name
            } else {
                method = function
            }
        }
    }
    
    static func tagsList(_ fileId: String, _ function: String, _ isError: Bool) -> Log {
        let tags = Tags(fileId, function, isError)
        
        return Log()
            .add(separator: .center)
            .add(tags.icon).space.add(tags.module).nextLine
            .tab.space.add(tags.file).nextLine
            .tab.space.add(tags.method).nextLine
            .add(separator: .center)
    }
}

extension Log {
    struct Details {
        let time: String
        let function: String
        let line: String
        let type: String
        
        init(function: String, line: Int, type: String) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss.SSS"
            self.time = dateFormatter.string(from: Date())
            
            self.function = function
            self.line = String(line)
            self.type = type
        }
    }
    
    static func detailsInfo(_ function: String, _ line: Int, _ type: String) -> Log {
        let info = Details(function: function, line: line, type: type)
        var details = Log().add(separator: .lower)
        Mirror(reflecting: info).children.forEach { child in
            let label = child.label ?? ""
            details = details.add(label).colon.add("\(child.value)").nextLine
        }
        return details.add(separator: .upArrow)
    }
}

//MARK: Print
public func prettyLog<T: Any>(label: String = ""
                              ,_ item: T,
                              fileId: String = #fileID,
                              function: String = #function,
                              line: Int = #line) {
#if DEBUG
    if LogSettings.type == .nothing {  return }
    
    let tags = Log.tagsList(fileId, function, item is Error)
    
    let typeName = String(describing: type(of: item))
    let description = String(describing: item)
    
    var itemLabel = Log(label.isEmpty ? typeName : label)
    
    if let collection = item as? (any Collection) {
        let count = Log("count").colon.add(collection.count)
        itemLabel = itemLabel.add(specification: count)
    }
    
    if itemLabel.value.count + description.count > LogSeparator.width {
        itemLabel = itemLabel.colon.nextLine
    } else {
        itemLabel = itemLabel.colon
    }
    
    let body = Log()
        .add(itemLabel)
        .add(description).nextLine
    
    // details
    let type = String(describing: type(of: item))
    let details = Log.detailsInfo(function, line, type)
    
    print(Log().add(tags).add(body).add(details).value)
#endif
}
