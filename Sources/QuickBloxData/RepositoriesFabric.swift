//
//  RepositoriesFabric.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain

public class RepositoriesFabric {
    private class Service {
        static let remote = RemoteDataSource()
        static let local = LocalDataSource()
        static let localFiles = LocalFilesDataSource()
        static let permissions = PermissionsSource()
    }
    
    static public var dialogs: DialogsRepository {
        DialogsRepository(remote: Service.remote,
                          local: Service.local)
    }
    
    static public var users: UsersRepository {
        UsersRepository(remote: Service.remote,
                        local: Service.local)
    }
    
    static public var messages: MessagesRepository {
        MessagesRepository(remote: Service.remote,
                           local: Service.local)
    }
    
    static public var files: FilesRepository {
        FilesRepository(remote: Service.remote,
                        local: Service.localFiles)
    }
    
    static public var connection: ConnectionRepository {
        ConnectionRepository(remote: Service.remote)
    }
    
    static public var permissions: PermissionsRepository {
        PermissionsRepository(repo: Service.permissions)
    }
    
    static public var ai: AIRepository {
        AIRepository(remote: Service.remote)
    }
}
