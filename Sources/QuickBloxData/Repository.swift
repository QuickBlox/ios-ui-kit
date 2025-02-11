//
//  RepositoriesFabric.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 28.02.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain

public class DataSource {
    public static var remote = RemoteDataSource()
    public static var local: LocalDataSourceProtocol = LocalDataSource()
    public static var localFiles = LocalFilesDataSource()
    public static var permissions = PermissionsDataSource()
}

public class Repository {
    static public var dialogs: DialogsRepository {
        DialogsRepository(remote: DataSource.remote,
                          local: DataSource.local)
    }
    
    static public var users: UsersRepository {
        UsersRepository(remote: DataSource.remote,
                        local: DataSource.local)
    }
    
    static public var messages: MessagesRepository {
        MessagesRepository(remote: DataSource.remote,
                           local: DataSource.local)
    }
    
    static public var files: FilesRepository {
        FilesRepository(remote: DataSource.remote,
                        local: DataSource.localFiles)
    }
    
    static public var connection: ConnectionRepository {
        ConnectionRepository(remote: DataSource.remote)
    }
    
    static public var permissions: PermissionsRepository {
        PermissionsRepository(source: DataSource.permissions)
    }
    
    static public var ai: AIRepository {
        AIRepository(remote: DataSource.remote)
    }
}
