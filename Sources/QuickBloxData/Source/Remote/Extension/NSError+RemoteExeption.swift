//
//  NSError+RemoteExeption.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

extension NSError {
    var remoteException: Error {
        get throws {
            var info = "Status code: \(self.code). "
            
            switch self.code {
            case 401, 422:
                let key = NSLocalizedFailureReasonErrorKey
                if let reason = self.userInfo[key] as? NSDictionary {
                    let data =
                    try JSONSerialization.data(withJSONObject: reason,
                                               options: .prettyPrinted)
                    let payload =
                    try JSONDecoder().decode(ResponseError.self,
                                             from: data)
                    info = info + "Reason: \(payload.info)"
                }
                throw RemoteDataSourceException.unauthorised(info)
            default:
                throw DataSourceException.unexpected(self.localizedDescription)
            }
        }
    }
}

private struct ResponseError: Decodable {
    let info: String
    
    private enum CodingKeys: String, CodingKey {
        case errors, base
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errors = try? container.decode([String].self, forKey: .errors)
        let errorsInfo = try? container.decode([String: [String]].self,
                                               forKey: .errors)
        
        if let errors = errors {
            info = errors.joined(separator: ", ")
        } else if let errorsInfo = errorsInfo {
            if let base = errorsInfo[CodingKeys.base.rawValue] {
                info = base.joined(separator: ", ")
                return
            }
            
            var description = ""
            for (key, value) in errorsInfo {
                let subdescription = value.joined(separator: ", ")
                description += " \(key): \(subdescription)."
            }
            
            self.info = description
        } else {
            info = "Undefined error"
        }
    }
}
