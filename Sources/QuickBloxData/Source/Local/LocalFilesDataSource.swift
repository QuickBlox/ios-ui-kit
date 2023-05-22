//
//  LocalFilesDataSource.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

/// This is a class that implements the ``LocalFileDataSourceProtocol`` protocol and contains methods and properties that allow it to interact with the local file storage.
///
/// Stores data cache files in the Library/Caches/ directory. Cache data can be used for any information that needs to persist for longer than temporary data, but not as long as a support file. While the application does not necessarily need the cache data to function properly, it can use it to enhance performance. The system will automatically clear the Caches/ directory to free up disk space.
class LocalFilesDataSource {
    private let manager = FileManager.default
    private var fileURL: URL {
        get throws {
            // geting caches folder url
            let urls = manager.urls(for: .documentDirectory, in: .userDomainMask)
            guard var url = urls.first else {
                let info =
                "File manager failed to locate the caches directory URL."
                throw DataSourceException.unexpected(info)
            }
            
            // adding folders where files will be stored
            url = url.appendingPathComponent(#fileID, isDirectory: true)
            url.deletePathExtension()
            try manager.createDirectory(at: url, withIntermediateDirectories: true)
            
            return url
        }
    }
    
    private func fileURL(for dto: LocalFileDTO) throws -> URL {
        guard let components = URLComponents(string: dto.id),
              components.scheme != nil,
              let url = components.url else  {
            return try fileURL.appendingPathComponent("\(dto.id)")
        }
        guard let id = url.pathComponents.last else {
            let info = "Internal. Parse url: \(url) for LocalFileDTO with id: \(dto.id)"
            throw DataSourceException.unexpected(info)
        }
        
        if let uuid = id.components(separatedBy: ".").first {
            return try fileURL.appendingPathComponent(uuid)
        }
        
        return try fileURL.appendingPathComponent(id)
    }
}

//MARK: LocalFileDataSourceProtocol
extension LocalFilesDataSource: LocalFilesDataSourceProtocol {
    func createFile(_ dto: LocalFileDTO) async throws -> LocalFileDTO {
        var url = try fileURL(for: dto)
        url = url.appendingPathExtension(dto.ext.rawValue)
        if manager.fileExists(atPath: url.path) {
            let info = "File already exist at path: \(url.path)"
            throw DataSourceException.alreadyExist(description:info)
        }
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(dto)
        
        if manager.createFile(atPath: url.path, contents: encodedData) == false {
            let info =
            "File manager failed to create a file with the following path: \(url.path)."
            throw DataSourceException.unexpected(info)
        }
        
        var newDTO = dto
        newDTO.path.local = url.absoluteString
        newDTO.path.localURL = url
        return newDTO
    }
    
    func getFile(_ dto: LocalFileDTO) async throws -> LocalFileDTO {
        let url = try searchURL(for: dto)
        
        if manager.fileExists(atPath: url.path) == false {
            throw DataSourceException.notFound()
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        var result = try decoder.decode(LocalFileDTO.self, from:data)
        result.path.local = url.absoluteString
        result.path.localURL = url
        
        return result
    }
    
    func deleteFile(_ dto: LocalFileDTO) async throws {
        let url = try searchURL(for: dto)
        if manager.fileExists(atPath: url.path) == false {
            throw DataSourceException.notFound()
        }
        
        try manager.removeItem(at: url)
    }
    
    func cleareAll() async throws {
        if manager.fileExists(atPath: try fileURL.path) == false {
            return
        }
        try manager.removeItem(at: try fileURL)
    }
    
    private func searchURL(for dto: LocalFileDTO) throws -> URL {
        let url = try fileURL(for: dto)
        
        guard let id = url.pathComponents.last,
              let uuid = id.components(separatedBy: ".").first else {
            let info = "Internal. Parse url: \(url) for LocalFileDTO with id: \(dto.id)"
            throw DataSourceException.unexpected(info)
        }
        
        return try getFirstURL(forFileName: uuid)
    }
    
    private func getFirstURL(forFileName fileName: String) throws -> URL {
        let keys: [URLResourceKey] = [.isRegularFileKey, .nameKey]
        let dictionaryUrl = try fileURL
        let enumerator = manager.enumerator(at: dictionaryUrl,
                                                includingPropertiesForKeys: keys,
                                                options: .skipsHiddenFiles) { url, error in
            print("Error occurred while enumerating directory: \(error)")
            return true
        }
        
        guard let enumerator = enumerator else {
            throw DataSourceException.notFound()
        }

        for case let searchUrl as URL in enumerator {
            do {
                let resourceValues = try searchUrl.resourceValues(forKeys: Set(keys))

                if let isRegularFile = resourceValues.isRegularFile,
                   isRegularFile,
                   let name = resourceValues.name,
                   let findName = name.components(separatedBy: ".").first,
                    findName == fileName {
                    return searchUrl
                }
            } catch {
                throw error
            }
        }

        throw DataSourceException.notFound()
    }
}
