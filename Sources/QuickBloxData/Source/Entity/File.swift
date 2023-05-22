//
//  File.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// Contain methods and properties that describe a File item.
///
/// This is an active model that conforms to the ``FileEntity`` protocol.
public struct File: FileEntity {
    public let id: String
    public var info: FileInfo
    public var data: Data
    
    public init(id: String, info: FileInfo, data: Data) {
        self.id = id
        self.info = info
        self.data = data
    }
}

public struct FileInfo: FileInfoEntity {
    public let id: String
    public let ext: FileExtension
    public var name: String
    public var type: FileType
    public var path: FilePath
    
    public init(id: String,
                ext: FileExtension,
                name: String) {
        self.id = id
        self.ext = ext
        if let extStr = name.components(separatedBy: ".").last,
            extStr.isEmpty == false {
            self.name = name
        } else {
            self.name = "\(name).\(ext.rawValue)"
        }
        type = ext.type
        path = FilePath()
    }
}

public struct FilePath: FilePathEntity {
    public var remote = ""
    public var local = ""
    
    public var uuid: String? {
        let fileName = remoteURL?.pathComponents.last
        return fileName?.components(separatedBy: ".").first
    }
    
    public var remoteURL: URL? { return URL(string: remote) }
    public var localURL: URL? 
    
    public init() {}
}
