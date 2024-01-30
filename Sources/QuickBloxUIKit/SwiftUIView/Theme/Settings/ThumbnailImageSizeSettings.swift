//
//  ThumbnailImageSizeSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 03.01.2024.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation

public class ThumbnailImageSizeSettings {
    public var user = UserThumbnailSizeSettings()
    public var dialod = DialogThumbnailSizeSettings()
    public var message = MessageThumbnailSizeSettings()
}

public struct UserThumbnailSizeSettings {
    public var avatar1x: CGSize = CGSize(width: 40.0, height: 40.0)
    public var avatar2x: CGSize = CGSize(width: 56.0, height: 56.0)
    public var avatar3x: CGSize = CGSize(width: 80.0, height: 80.0)
}

public struct DialogThumbnailSizeSettings {
    public var avatar1x: CGSize = CGSize(width: 34.0, height: 34.0)
    public var avatar2x: CGSize = CGSize(width: 56.0, height: 56.0)
    public var avatar3x: CGSize = CGSize(width: 80.0, height: 80.0)
    public var attachment: CGSize = CGSize(width: 32.0, height: 32.0)
}

public struct MessageThumbnailSizeSettings {
    public var avatar: CGSize = CGSize(width: 44.0, height: 44.0)
    public var attachment: CGSize = CGSize(width: 240.0, height: 160.0)
}

public enum UserThumbnailScale: String, CaseIterable {
    case avatar1x, avatar2x, avatar3x
    
    var size: CGSize {
        switch self {
        case .avatar1x: return UserThumbnailSizeSettings().avatar1x
        case .avatar2x: return UserThumbnailSizeSettings().avatar2x
        case .avatar3x: return UserThumbnailSizeSettings().avatar3x
        }
    }
}

public enum DialogThumbnailSize: String, CaseIterable {
    case avatar1x, avatar2x, avatar3x, attachment
    
    var size: CGSize {
        switch self {
        case .avatar1x: return DialogThumbnailSizeSettings().avatar1x
        case .avatar2x: return DialogThumbnailSizeSettings().avatar2x
        case .avatar3x: return DialogThumbnailSizeSettings().avatar3x
        case .attachment: return DialogThumbnailSizeSettings().attachment
        }
    }
}

public enum MessageThumbnailSize: String, CaseIterable {
    case avatar, attachment
    
    var size: CGSize {
        switch self {
        case .avatar: return MessageThumbnailSizeSettings().avatar
        case .attachment: return MessageThumbnailSizeSettings().attachment
        }
    }
}
