//
//  RemoteFileDTO.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 Quickblox. All rights reserved.
//

import QuickBloxDomain
import Foundation

/// This is a DTO model for saving file model in remote storage.
public struct RemoteFileDTO: DataStringConvertible {
    public var id: String = UUID().uuidString
    public var ext: FileExtension = .json
    public var name: String = ""
    public var type: FileType = .file
    public var data: Data = Data()
    public var path: FilePath = FilePath()
    
    public var `public`: Bool = false
}
