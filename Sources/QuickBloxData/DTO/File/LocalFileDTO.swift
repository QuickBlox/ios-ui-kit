//
//  LocalFileDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 07.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import QuickBloxDomain
import QuickBloxLog

/// Contains properties that describe the characteristics and content of a data file..
///
/// This is a DTO model for saving file data locally in the cache.
public struct LocalFileDTO: DataStringConvertible {
    public let id: String
    public var ext: FileExtension = .json
    public var name: String = ""
    public var type: FileType = .file
    public var data: Data = Data()
    public var path: FilePath = FilePath()
}
