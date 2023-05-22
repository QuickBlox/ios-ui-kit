//
//  ClearLocalDataSourceProtocol.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

//TODO: Please check if necessary.
/// Clear data source.
public protocol ClearLocalDataSourceProtocol {
    /// Remove all items from storage.
    func cleareAll() async throws
}
