//
//  APIFiles.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Quickblox
import QuickBloxDomain

public struct APIFiles {
    public func `get`(with url: URL) async throws -> RemoteFileDTO {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RemoteDataSourceException.incorrectData()
        }
        
        var mimeType: String
        if let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
            mimeType = contentType
        } else {
            mimeType = FileExtension.json.mimeType
            let info = """
            Downloaded file response \(url) without a content type.
            Instead, \(mimeType) is used.
            """
            Warning.push(info)
        }
        
        guard let fileName = url.pathComponents.last,
              let path = url.absoluteString.components(separatedBy: "?").first else {
            let info = "Internal. Parse url: \(url)"
            throw RemoteDataSourceException.incorrectData(info)
        }
        
        let uuid = fileName.components(separatedBy: ".").first
        
        let filePath = FilePath(remote: path)
        let fileExt = FileExtension(mimeType: mimeType)
        return RemoteFileDTO(id: uuid ?? fileName,
                             ext: fileExt,
                             name: fileName,
                             type: fileExt.type,
                             data: data,
                             path: filePath,
                             uid: uuid ?? "")
    }
    
    public func `get`(blob id: UInt) async throws -> QBCBlob {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.blob(withID: id) {  _, blob in
                continuation.resume(returning: blob)
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }

        }
    }
    
    public func upload(file content: RemoteFileDTO) async throws -> QBCBlob {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.tUploadFile(content.data,
                                  fileName: content.name,
                                  contentType: content.ext.mimeType,
                                  isPublic: content.public) { _, blob in
                continuation.resume(returning: blob)
            } statusBlock: { _,_ in
                //TODO: add progress handler
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }

        }
    }
    
    public func delete(with id: UInt) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.deleteBlob(withID: id) { _ in
                continuation.resume()
            } errorBlock: { response in
                continuation.resume(throwing: response.remoteError)
            }
        }
    }
}
