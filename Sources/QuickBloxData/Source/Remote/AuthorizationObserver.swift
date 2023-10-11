//
//  AuthorizationObserver.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import Foundation
import Combine

extension CFNotificationName {
    static let logoutEvent = CFNotificationName("com.quicklblox.logout.notificaiton" as CFString)
    static let loginEvent = CFNotificationName("com.quicklblox.login.notificaiton" as CFString)
}

class AuthorizationObserver: NSObject {
    static var shared = AuthorizationObserver()
    
    private let subject = PassthroughSubject<CFNotificationName, Never>()
    
    var publisher: AnyPublisher<CFNotificationName, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    func send(notification name: CFNotificationName) {
        subject.send(name)
    }
    
    override init() {
        super.init()
        
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        let loginCallback: CFNotificationCallback = { center, _, name, _, _ in
            guard let name = name, name == .loginEvent else { return }
            
            AuthorizationObserver.shared.send(notification: name)
        }
        
        let logoutCallback: CFNotificationCallback = { center, _, name, _, _ in
            guard let name = name, name == .logoutEvent else { return }
            
            AuthorizationObserver.shared.send(notification: name)
        }
        
        CFNotificationCenterAddObserver(center,
                                        observer,
                                        loginCallback,
                                        CFNotificationName.loginEvent.rawValue,
                                        nil, .deliverImmediately)
        CFNotificationCenterAddObserver(center,
                                        observer,
                                        logoutCallback,
                                        CFNotificationName.logoutEvent.rawValue,
                                        nil, .deliverImmediately)
    }
    
    func dealloc() {
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterRemoveObserver(center,
                                           observer,
                                           .loginEvent,
                                           nil)
        
        CFNotificationCenterRemoveObserver(center,
                                           observer,
                                           .logoutEvent,
                                           nil)
    }
}
