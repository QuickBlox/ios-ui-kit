//
//  RemoteDataSource.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 19.01.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import QuickBloxDomain
import QuickBloxLog
import Quickblox
import Combine
import CoreFoundation

extension Task where Success == Never, Failure == Never {
    static func wait(second: Double) async throws {
        let duration = UInt64(second * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

private actor Chat {
    private let dialog: QBChatDialog
    
    var type: DialogType {
        return dialog.type.mapToDialogType
    }
    
    var qbChat: QBChatDialog {
        return dialog
    }
    
    init(_ dialog: QBChatDialog) {
        self.dialog = dialog
    }
    
    func subscribe() async {
        guard let id = dialog.id, dialog.type == .group else { return }
        guard dialog.isJoined() == false else { return }
        do {
            try await dialog.joinAsync()
            try Task.checkCancellation()
            try await Task.wait(second: 0.2)
        } catch {
            prettyLog(label: "Join to \(id)", error)
        }
    }
    
    func send(_ message: QBChatMessage) async {
        guard let id = dialog.id, id == message.dialogID else { return }
        if dialog.type != .private {
            await subscribe()
        }
        do {
            try await Task.wait(second: 0.3)
            try Task.checkCancellation()
            message.dateSent = Date()
            try await dialog.send(message)
            try Task.checkCancellation()
        } catch {
            prettyLog(label: "Send to \(id)", error)
        }
    }
    
    func unsubscribe() async {
        guard let id = dialog.id, dialog.type == .group else { return }
        guard dialog.isJoined() else { return }
        do {
            try await dialog.leaveAsync()
            let duration = UInt64(0.2 * 1_000_000_000)
            try await Task.sleep(nanoseconds: duration)
        } catch {
            prettyLog(label: "Leave from \(id)", error)
        }
    }
}

private actor MessagesStreamController {
    private let subject = PassthroughSubject<RemoteEvent, Never>()
    var eventPublisher: AnyPublisher<RemoteEvent, Never> {
        subject.eraseToAnyPublisher()
    }
    
    private var chats: [String: Chat] = [:]
    private var cancellables: [String: AnyCancellable] = [:]
    
    func typeOf(chat chatId: String) async throws -> DialogType {
        guard let chat = chats[chatId] else {
            let info = "Chat with id \(chatId) is absent"
            throw DataSourceException.notFound(description: info)
        }
        return await chat.type
    }
    
    func qbChat(with id: String) async throws -> QBChatDialog {
        guard let chat = chats[id] else {
            let info = "Chat with id \(id) is absent"
            throw DataSourceException.notFound(description: info)
        }
        return await chat.qbChat
    }
    
    func add(chat dialog: QBChatDialog) async {
        guard let id = dialog.id else { return }
        if let old = chats[id] {
            Task { await old.subscribe() }
            return
        }
        let new = Chat(dialog)
        chats[id] = new
        Task { await new.subscribe() }
    }
    
    func update(chat dialog: QBChatDialog) async {
        guard let id = dialog.id else { return }
        let new = Chat(dialog)
        chats[id] = new
        print("!!!!!!!! update(chat dialog")
        Task { await new.subscribe() }
    }
    
    func remove(chat id: String) async {
        guard let chat = chats[id] else { return }
        await chat.unsubscribe()
        chats.removeValue(forKey: id)
        
        if let cancellable = cancellables[id] {
            cancellable.cancel()
            cancellables.removeValue(forKey: id)
        }
    }
    
    func send(_ message: QBChatMessage) async {
        guard let id = message.dialogID, let chat = chats[id] else { return }
        Task { await chat.send(message) }
    }
    
    func process(_ message: QBChatMessage) async {
        let event = RemoteEvent(RemoteMessageDTO(message))
        subject.send(event)
    }
    
    func didRead(_ messageID: String, dialogID: String, readerID: String) async {
        var dto = RemoteMessageDTO()
        dto.dialogId = dialogID
        dto.id = messageID
        dto.readIds.append(readerID)
        dto.type = .event
        dto.eventType = .read
        let event = RemoteEvent(dto)
        subject.send(event)
    }
    
    func didDilivered(_ messageID: String, dialogID: String, toUserID userID: String) async {
        var dto = RemoteMessageDTO()
        dto.dialogId = dialogID
        dto.id = messageID
        dto.deliveredIds.append(userID)
        dto.type = .event
        dto.eventType = .delivered
        let event = RemoteEvent(dto)
        subject.send(event)
    }
    
    func process(_ event: RemoteEvent) async {
        subject.send(event)
    }
    
    func clear() async {
        for id in chats.keys {
            if let cancelable = cancellables[id] { cancelable.cancel() }
            if let chat = chats[id] { await chat.unsubscribe() }
        }
        cancellables.removeAll()
        chats.removeAll()
    }
}

extension CFNotificationName {
    static let qbLogoutEvent = CFNotificationName("com.quicklblox.logout.notificaiton" as CFString)
    static let qbLoginEvent = CFNotificationName("com.quicklblox.login.notificaiton" as CFString)
}
/// This is a class that implements the ``RemoteDataSourceProtocol`` protocol and contains methods and properties that allow it to interact with the remote data source.
///
/// An object of this class provides access for remote storage of items at the time of the application's life cycle.  Provides access to a single repository object by calling **RemoteDataSource.instance** static property.
class RemoteDataSource: NSObject, RemoteDataSourceProtocol {
    var eventPublisher: AnyPublisher<RemoteEvent, Never> {
        get async { await stream.eventPublisher.eraseToAnyPublisher() }
    }
    
    private let connectionSubject = PassthroughSubject<ConnectionState, Never>()
    
    var connectionPublisher: AnyPublisher<ConnectionState, Never> {
        return connectionSubject.eraseToAnyPublisher()
    }
    
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var stream = MessagesStreamController()
    
    private var observer: UnsafeRawPointer!
    
    private let qbChat = QBChat.instance
    
    override init() {
        super.init()
        //FIXME: Must be set QBSettings.applicationID before using QBSession.currentSession
        QBSettings.disableXMPPLogging()
        QBSettings.logLevel = .debug
        QBSettings.carbonsEnabled = true
        qbChat.addDelegate(self)
        
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        CFNotificationCenterAddObserver(center,
                                        observer,
                                        qbLoginCallback,
                                        CFNotificationName.qbLoginEvent.rawValue,
                                        nil, .deliverImmediately)
        CFNotificationCenterAddObserver(center,
                                        observer,
                                        qbLogoutCallback,
                                        CFNotificationName.qbLogoutEvent.rawValue,
                                        nil, .deliverImmediately)
    }
    
    private let qbLoginCallback: CFNotificationCallback = { center, observer, name, _, _ in
        guard let observer = observer,
              let name = name, name == .qbLoginEvent else { return }
        
        let remoteDataSource = Unmanaged<RemoteDataSource>.fromOpaque(observer).takeUnretainedValue()
        Task { await remoteDataSource.stream.clear() }
        remoteDataSource.connectionSubject.send(.authorized)
    }
    
    private let qbLogoutCallback: CFNotificationCallback = { center, observer, name, _, _ in
        guard let observer = observer,
              let name = name, name == .qbLogoutEvent else { return }
        
        let remoteDataSource = Unmanaged<RemoteDataSource>.fromOpaque(observer).takeUnretainedValue()
        remoteDataSource.connectionSubject.send(.unauthorized)
        Task { await remoteDataSource.stream.clear() }
    }
    
    func dealloc() {
        if let observer = observer {
            let center = CFNotificationCenterGetDarwinNotifyCenter()
            CFNotificationCenterRemoveObserver(center,
                                               observer,
                                               .qbLoginEvent,
                                               nil)
            CFNotificationCenterRemoveObserver(center,
                                               observer,
                                               .qbLogoutEvent,
                                               nil)
        }
    }
}

//MARK: Connection
extension RemoteDataSource {
    func connect() async throws {
        guard let details = QBSession.current.sessionDetails,
              let token = details.token,
              QBSession.current.tokenHasExpired == false else {
            connectionSubject.send(.unauthorized)
            throw RemoteDataSourceException.unauthorised()
        }
        
        do {
            connectionSubject.send(.connecting())
            try await qbChat.connect(withUserID: details.userID,
                                              password: token)
        } catch {
            //FIXME: catch connection errors 401, 422, etc
            throw RemoteDataSourceException.unauthorised(error.localizedDescription)
        }
    }
    
    func disconnect() async throws {
        if QBSession.current.tokenHasExpired || QBSession.current.sessionDetails?.token == nil {
            connectionSubject.send(.unauthorized)
            return
        }
        
        guard qbChat.isConnected || qbChat.isConnecting else {
            connectionSubject.send(.disconnected())
            return
        }
        
        do {
            try await qbChat.disconnect()
        } catch let nsError as NSError {
            switch nsError.code {
            case -1003:
                connectionSubject.send(.disconnected())
            default:
                throw DataSourceException.unexpected(nsError.localizedDescription)
            }
        } catch {
            //FIXME: catch connection errors 401, 422, etc
            throw RemoteDataSourceException.unauthorised(error.localizedDescription)
        }
    }
    
    func checkConnection() async throws {
        guard let currentUser = QBSession.current.currentUser,
              let token = QBSession.current.sessionDetails?.token else {
            connectionSubject.send(.unauthorized)
            return
        }
        
        guard currentUser.id > 0 || token.isEmpty else {
            connectionSubject.send(.unauthorized)
            return
        }
        
        if QBSession.current.tokenHasExpired {
            try await QBRequest.updateUserInfo(withId: currentUser.id)
            try Task.checkCancellation()
        }
        
        if qbChat.isConnecting {
            connectionSubject.send(.connecting())
        } else if qbChat.isConnected {
            connectionSubject.send(.connected)
        } else {
            connectionSubject.send(.disconnected())
        }
    }
    
    func readAsync(_ message: QBChatMessage) async throws {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<Void, Error>) in
            QBChat.instance.read(message) { (error) in
                if let error = error {
                    prettyLog(error)
                    continuation.resume(throwing:error)
                } else {
                    continuation.resume()
                }
            }
        })
    }
    
    func markAsDeliveredAsync(_ message: QBChatMessage) async throws {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<Void, Error>) in
            QBChat.instance.mark(asDelivered: message) { (error) in
                if let error = error {
                    prettyLog(error)
                    continuation.resume(throwing:error)
                } else {
                    continuation.resume()
                }
            }
        })
    }
}

//MARK: QBChatDelegate
extension RemoteDataSource: QBChatDelegate { }

//MARK: QBChatConnectionProtocol
extension RemoteDataSource: QBChatConnectionProtocol {
    func chatDidNotConnectWithError(_ error: Error) {
        if let exeption = try? error.repositoryException {
            connectionSubject.send(.connecting(exeption))
        } else {
            connectionSubject.send(.disconnected())
        }
    }
    
    func chatDidConnect() {
        connectionSubject.send(.connected)
    }
    
    func chatDidDisconnectWithError(_ error: Error?) {
        if let exeption = try? error?.repositoryException {
            connectionSubject.send(.disconnected(exeption))
        } else {
            connectionSubject.send(.disconnected())
        }
    }
    
    func chatDidReconnect() {
        connectionSubject.send(.connected)
    }
}

//MARK: Events
extension RemoteDataSource: QBChatReceiveMessageProtocol {
    private var currentUserId: UInt {
        return QBSession.current.currentUserID
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        if message.senderID == currentUserId { return }
        Task { await stream.process(message) }
    }
    
    func chatRoomDidReceive(_ message: QBChatMessage,
                            fromDialogID dialogID: String) {
        message.dialogID = dialogID
        if message.senderID == currentUserId { return }
        
        if message.type == .leave || message.type == .removed || message.type == .update {
            let withId = RemoteDialogDTO(id: dialogID)
            Task {
                try await getAndUpdate(dialog: withId)
                await stream.process(message)
                return
            }
        }
        Task {
            await stream.process(message)
        }
    }
    
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        if message.senderID == currentUserId { return }
        Task { await stream.process(message) }
    }
    
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        Task { await stream.didRead(messageID, dialogID: dialogID, readerID: String(readerID)) }
    }

    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        Task { await stream.didDilivered(messageID, dialogID: dialogID, toUserID: String(userID)) }
    }
}

//MARK: Dialogs
extension RemoteDataSource {
    func create(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
            let dialog = QBChatDialog(dialogID: nil,
                                      type: dto.type.mapToQBDialogType)
            let pIds = dto.participantsIds.map{ NSNumber(value: Int($0) ?? 0) }
            
            dialog.occupantIDs = pIds
            if dialog.type == .group {
                dialog.name = dto.name
                dialog.photo = dto.photo
            }
            let created = try await QBRequest.create(dialog: dialog)
            try? await Task.wait(second: 0.2)
            await stream.add(chat: created)
            
            guard let dialogId = created.id else {
                let info = "Dialog with id: \(dto.id)"
                throw RemoteDataSourceException.incorrectData(description: info)
            }
            
            var message = RemoteMessageDTO.eventMessage(create(dialogText: dto.name),
                                                        dialogId: dialogId,
                                                        type: .chat,
                                                        eventType: .create)
            if dto.type == .private, let recipientId = dto.participantsIds.first {
                message.recipientId = recipientId
            }
            
            let qbChatMessage = QBChatMessage(message, toSend: true)
            
            if dto.type == .private {
                qbChatMessage.customParameters[QBChatMessage.Key.save] = false
            }
            
            await stream.send(qbChatMessage)
            
            let system = QBChatMessage()
            let params = NSMutableDictionary()
            params[QBChatMessage.Key.type] = QBChatMessage.Value.create
            params[QBChatMessage.Key.dialogId] = created.id
            system.customParameters = params
            
            system.senderID = QBSession.current.currentUserID
            system.text = "Create Dialog"
            system.markable = false
            system.dateSent = Date()
            
            system.recipientID = QBSession.current.currentUserID
            await stream.process(system)
            
            for id in dto.participantsIds {
                system.recipientID = UInt(id) ?? 0
                try? await qbChat.sendSystemMessage(system)
            }
            
            return RemoteDialogDTO(created)
        }
        
        private func create(dialogText chatName: String) -> String {
            let actionMessage = "created the group chat"
            guard let current = QBSession.current.currentUser else {
                return ""
            }
            return "\(current.fullName ?? "\(current.id)") \(actionMessage) \"\(chatName)\""
        }
    
    
//    func create(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
//        let dialog = QBChatDialog(dialogID: nil,
//                                  type: dto.type.mapToQBDialogType)
//        let pIds = dto.participantsIds.map{ NSNumber(value: Int($0) ?? 0) }
//
//        dialog.occupantIDs = pIds
//        if dialog.type == .group {
//            dialog.name = dto.name
//            dialog.photo = dto.photo
//        }
//        let created = try await QBRequest.create(dialog: dialog)
//        try await Task.wait(second: 0.2)
//        await stream.add(chat: created)
//        try await Task.wait(second: 0.6)
//
//        guard let dialogId = created.id else {
//            let info = "Dialog with id: \(dto.id)"
//            throw RemoteDataSourceException.incorrectData(description: info)
//        }
//
//        let message = try QBChatMessage.create(dialog: dialogId, dialogName: dto.name)
//        if dto.type == .private {
//            message.customParameters[QBChatMessage.Key.save] = false
//        }
//        await stream.send(message)
//
//        let system = try QBChatMessage.createSystem(dialog: dialogId)
//        await stream.process(system)
//
//        if dto.type == .group {
//            for id in dto.participantsIds {
//                system.recipientID = UInt(id) ?? 0
//                try? await qbChat.sendSystemMessage(system)
//            }
//        }
//
//        return RemoteDialogDTO(created)
//    }
    
    func update(dialog dto: RemoteDialogDTO,
                users: [RemoteUserDTO]) async throws -> RemoteDialogDTO {
        let dialog = try await stream.qbChat(with: dto.id)
        
        guard let dialogId = dialog.id else {
            let info = "Not found dialog with id: \(dto.id)"
            throw DataSourceException.notFound(description: info)
        }
        guard let user = QBSession.current.currentUser,
              let userName = user.fullName else {
            let info = "Current user not found"
            throw DataSourceException.notFound(description: info)
        }
        var text = Log()
        if dto.name.isEmpty == false, dialog.name != dto.name {
            dialog.name = dto.name
            text = text
                .add("The dialog renamed by user \(userName)")
                .newLine
        }
        
        let photo = dto.photo == "" ? nil : dto.photo
        if dialog.photo != photo {
            dialog.photo = photo
            
            text = text
                .add("The avatar was changed")
                .newLine
        }
        var pullIds: [String] = []
        var pullLog = Log()
        var pushIds: [String] = []
        var pushLog = Log()
        var set: Set<String> = []
        if let occupants = dialog.occupantIDs {
            let ids = occupants.map { $0.stringValue }
            set.formUnion(ids)
        }
        
        for user in users {
            if set.contains(user.id) {
                if pullIds.isEmpty {
                    pullLog = pullLog.add(user.name)
                } else {
                    pullLog = pullLog.coma.add(user.name)
                }
                pullIds.append(user.id)
            } else {
                if pushIds.isEmpty {
                    pushLog = pushLog.add(user.name)
                } else {
                    pushLog = pushLog.coma.add(user.name)
                }
                pushIds.append(user.id)
            }
        }
        
        if pushIds.isEmpty == false {
            text = text.add(pushLog).space.add("added by \(userName)")
        }
        
        if pullIds.isEmpty == false {
            text = text.add(pullLog).space.add("removed by \(userName)")
        }
        
        dialog.pushOccupantsIDs = pushIds
        dialog.pullOccupantsIDs = pullIds
        
        let updated = try await QBRequest.update(dialog: dialog)
        
        let message = RemoteMessageDTO.eventMessage(text.value,
                                                    dialogId: dialogId,
                                                    type: .chat,
                                                    eventType: .update)
        await stream.send(QBChatMessage(message, toSend: true))
        await stream.update(chat: updated)
        
        var system = RemoteMessageDTO.eventMessage(text.value,
                                                   dialogId: dialogId,
                                                   type: .event,
                                                   eventType: .update)
        var ids: Set<String> = []
        if pushIds.isEmpty == false {
            ids.formUnion(pushIds)
        }
        if pullIds.isEmpty == false {
            system.eventType = .removed
            ids.formUnion(pullIds)
        }
        for id in ids {
            system.recipientId = id
            try? await qbChat.sendSystemMessage(QBChatMessage(system, toSend: true))
        }
        system.recipientId = String(user.id)
        await stream.process(QBChatMessage(system, toSend: true))
        
        return RemoteDialogDTO(updated)
    }
    
    func getAndUpdate(dialog dto: RemoteDialogDTO) async throws {
        do {
            let dialog = try await QBRequest.dialog(with: dto.id)
            await stream.update(chat: dialog)

        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
        do {
            let dialog = try await QBRequest.dialog(with: dto.id)
            await stream.add(chat: dialog)
                
            return RemoteDialogDTO(dialog)
        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(dialogs dto: RemoteDialogsDTO) async throws -> RemoteDialogsDTO {
        do {
            let page = QBResponsePage(limit: dto.pagination.limit,
                                      skip: dto.pagination.skip)
            let result = try await QBRequest.dialogs(with: page)
            for dialog in result.dialogs {
                await stream.add(chat: dialog)
            }
            let dialogs = result.dialogs.map { RemoteDialogDTO($0) }
            let usersIds = result.usersIds.map { $0.stringValue }
            let pagination = Pagination(skip: result.page.skip,
                                        limit: result.page.limit,
                                        total: Int(result.page.totalEntries))
            let dialogsDTO = RemoteDialogsDTO(dialogs: dialogs,
                                              usersIds: usersIds,
                                              pagination: pagination)
            return dialogsDTO
        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func getAllDialogs() async throws -> RemoteDialogsDTO {
        do {
            let page = QBResponsePage(limit: 1, skip: 0, totalEntries: 1)
            
            let result = try await QBRequest.dialogs(with: page)
            
            try Task.checkCancellation()
            var allDialogs: [RemoteDialogDTO] = []
            for dialog in result.dialogs {
                await stream.add(chat: dialog)
                allDialogs.append(RemoteDialogDTO(dialog))
            }
            
            return RemoteDialogsDTO(dialogs: allDialogs)
        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func delete(dialog dto: RemoteDialogDTO) async throws {
        if dto.id.isEmpty {
            let info = "Internal. Empty dialog id"
            throw RepositoryException.incorrectData(description: info)
        }
        
        let message = try QBChatMessage.leave(dialog: dto.id)
        if dto.type == .private {
            message.customParameters[QBChatMessage.Key.save] = false
        }
        await stream.send(message)
        try await Task.wait(second: 0.6)
        
        if dto.type == .private {
            if dto.isOwnedByCurrentUser {
                try await QBRequest.delete(dialog: dto.id, force: true)
            } else {
                try await QBRequest.delete(dialog: dto.id, force: false)
            }
        } else if dto.type == .group {
            let dialog = try await stream.qbChat(with: dto.id)
            try await QBRequest.leave(dialog: dialog)
        }
        
        try await Task.wait(second: 0.6)
        await stream.remove(chat: dto.id)
        
        await stream.process(.leave(dto.id, byUser: true))
    }
}

//MARK: Messages
extension RemoteDataSource {
    func get(messages dto: RemoteMessagesDTO) async throws -> RemoteMessagesDTO {
        do {
            let result = try await QBRequest.messages(withDialogId: dto.dialogId,
                                                       messagesIds: dto.ids,
                                                       pagination: dto.pagination)
            let messages = result.messages.map { RemoteMessageDTO($0) }
            let messagesDTO = RemoteMessagesDTO(dialogId: dto.dialogId,
                                                messages: messages,
                                                pagination: result.pagination)
            return messagesDTO
        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func send(message dto: RemoteMessageDTO) async throws {
        let message = QBChatMessage(dto, toSend: true)
        await stream.send(message)
        await stream.process(message)
    }
    
    func update(message dto: RemoteMessageDTO) async throws -> RemoteMessageDTO {
        throw DataSourceException.unexpected()
    }
    
    func delete(message dto: RemoteMessageDTO) async throws {
        throw DataSourceException.unexpected()
    }
    
    func read(message dto: RemoteMessageDTO) async throws {
        let userId = QBSession.current.currentUserID
        if dto.readIds.contains(String(userId)) == true { return }
        let message = QBChatMessage(dto, toSend: false)
        try await readAsync(message)
        await stream.didRead(dto.id, dialogID: dto.dialogId, readerID: String(userId))
    }
    
    func markAsDelivered(message dto: RemoteMessageDTO) async throws {
        let userId = QBSession.current.currentUserID
        if dto.deliveredIds.contains(String(userId)) == true { return }
        let message = QBChatMessage(dto, toSend: false)
        try await markAsDeliveredAsync(message)
        await stream.didDilivered(dto.id, dialogID: dto.dialogId, toUserID: String(userId))
    }
}

//MARK: Users
extension RemoteDataSource {
    func get(user dto: RemoteUserDTO) async throws -> RemoteUserDTO {
        do {
            let user = try await QBRequest.user(withId: dto.id)
            return RemoteUserDTO(user)
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(users dto: RemoteUsersDTO) async throws -> RemoteUsersDTO {
        do {
            var tuple: (users: [QBUUser], pagination: Pagination)
            if dto.ids.isEmpty == false {
                tuple = try await QBRequest.users(withIDs: dto.ids,
                                                  pagination: dto.pagination)
            } else if dto.name.isEmpty == false {
                tuple = try await QBRequest.users(withFullName: dto.name,
                                                  pagination: dto.pagination)
            } else {
                tuple = try await QBRequest.users(pagination: dto.pagination)
            }
        
            let users = tuple.users
                .map { RemoteUserDTO($0)}
            return RemoteUsersDTO(users: users,
                                  pagination: tuple.pagination)
        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
}

//MARK: Files
extension RemoteDataSource {
    func create(file dto: RemoteFileDTO) async throws -> RemoteFileDTO {
        do {
            let blob = try await QBRequest.upload(file: dto.data,
                                                  fileName: dto.name,
                                                  contentType: dto.ext.mimeType,
                                                  isPublic: dto.public)
            guard let uuid = blob.uid,
                  let path = QBCBlob.publicUrl(forFileUID: uuid) else {
                let info = "Internal. Generate path fails for file with id: \(blob.id)."
                throw RemoteDataSourceException.incorrectData(description: info)
            }
            
            let fileName = blob.name ?? "file"
            let fileId = String(blob.id)
            
            var fileExtension: FileExtension
            if let extStr = fileName.components(separatedBy: ".").last,
               let ext = FileExtension(rawValue: extStr.lowercased()) {
                fileExtension = ext
            } else if let contentType = blob.contentType {
                fileExtension = FileExtension(mimeType: contentType)
            }  else {
                fileExtension = .json
                let info = """
                Created file \(blob.id) is named \(fileName) without a file extension.
                Instead, \(fileExtension.rawValue) is used.
                """
                Warning.push(info)
            }
            
            let filePath = FilePath(remote: path)
            
            return RemoteFileDTO(id: fileId,
                                 ext: fileExtension,
                                 name: fileName,
                                 type: fileExtension.type,
                                 data: dto.data,
                                 path: filePath)
        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(file dto: RemoteFileDTO) async throws -> RemoteFileDTO {
        if dto.id.isNumber {
            if dto.id == "0" {
                let info = "Internal. Incorrect file path: \(dto.id)"
                throw RemoteDataSourceException.incorrectData(description: info)
            }
            do {
                guard let intId = UInt(dto.id) else {
                    let info = "Internal. Incorrect file path: \(dto.id)"
                    throw RemoteDataSourceException.incorrectData(description: info)
                }
                
                let blob = try await QBRequest.get(blobWithId: intId)
                
                let fileName = blob.name ?? "file"
                let fileId = String(blob.id)
                
                var fileExtension: FileExtension
                if let extStr = fileName.components(separatedBy: ".").last,
                   let ext = FileExtension(rawValue: extStr.lowercased()) {
                    fileExtension = ext
                } else if let contentType = blob.contentType {
                    fileExtension = FileExtension(mimeType: contentType)
                } else {
                    fileExtension = dto.ext
                    let info = """
                    Received file \(blob.id) is named \(fileName) without a file extension.
                    Instead, \(fileExtension.rawValue) is used.
                    """
                    Warning.push(info)
                }
                
                guard let uuid = blob.uid else {
                    let info = "Internal. Incorrect uuid."
                    throw RemoteDataSourceException.incorrectData(description: info)
                }
                
                guard let path = QBCBlob.publicUrl(forFileUID: uuid) else {
                    let info = "Internal. Generate path fails for file with id: \(blob.id)."
                    throw RemoteDataSourceException.incorrectData(description: info)
                }
                
                let filePath = FilePath(remote: path)
                
                var uploaded = try await get(fileWithPath: uuid)
                uploaded.id = fileId
                uploaded.ext = fileExtension
                uploaded.name = fileName
                uploaded.type = fileExtension.type
                uploaded.path = filePath
                return uploaded
            } catch let nsError as NSError {
                throw try nsError.convertToRemoteException()
            } catch {
                throw DataSourceException.unexpected(error.localizedDescription)
            }
        } else {
            var uploaded = try await get(fileWithPath: dto.id)
            if dto.name.contains(dto.ext.rawValue) {
                let fileName = dto.name.replacingOccurrences(of: dto.ext.rawValue,
                                                             with: "")
                uploaded.name = fileName + uploaded.ext.rawValue
            }
            return uploaded
        }
    }
    
    func get(fileWithPath path: String) async throws -> RemoteFileDTO {
        guard var components = URLComponents(string: path),
              let token = QBSession.current.sessionDetails?.token else {
            let info = "Internal. Generate url token is not exist."
            throw RemoteDataSourceException.incorrectData(description: info)
        }
        
        if components.scheme == nil,
           let endpoint = QBSettings.apiEndpoint {
            let path = endpoint + "/blobs/" + path + ".json"
            guard let modified = URLComponents(string: path) else {
                let info = "Internal. Generate url with path: \(path)."
                throw RemoteDataSourceException.incorrectData(description: info)
            }
            
            components = modified
        }
        
        let tokenItem = URLQueryItem(name: "token", value: token)
        if components.queryItems == nil {
            components.queryItems = [tokenItem]
        } else {
            components.queryItems?.append(tokenItem)
        }
        
        guard let url = components.url else {
            let info = "Internal. Generate url with path: \(path)."
            throw RemoteDataSourceException.incorrectData(description: info)
        }
        
        return try await QBRequest.download(file: url)
    }
    
    func delete(file dto: RemoteFileDTO) async throws {
        do {
            guard let intId = UInt(dto.id) else {
                let info = "Internal. Incorrect id: \(dto.id)"
                throw RemoteDataSourceException.incorrectData(description: info)
            }
            
            try await QBRequest.delete(file: intId)
        } catch let nsError as NSError {
            throw try nsError.convertToRemoteException()
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
}

//MARK: Utils

//TOTO: for typing

//class QBDialogListener: NSObject {
//    var dialog: QBChatDialog
//    weak var delegate: QBDialogListenerDelegate?
//
//    init
//
//    func subscribe() {
//        self.dialog = dialog
//
//        dialog.onUserIsTyping = { [weak self] userID in
//            guard let self = self else { return }
//            self.delegate?.chatDidReceiveIsTyping(userID: NSNumber(value: userID), dialogID: self.dialog?.id)
//        }
//
//        dialog.onUserStoppedTyping = { [weak self] userID in
//            guard let self = self else { return }
//            self.delegate?.chatDidReceiveStopTyping(userID: NSNumber(value: userID), dialogID: self.dialog?.id)
//        }
//    }
//
//    func unsubscribe() {
//        dialog?.clearTypingStatusBlocks()
//        dialog = nil
//    }
//}

protocol QBDialogListenerDelegate: AnyObject {
    func chatDidReceiveIsTyping(userID: NSNumber, dialogID: String?)
    func chatDidReceiveStopTyping(userID: NSNumber, dialogID: String?)
}


private struct QBResponseErrorPayload: Decodable {
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

private extension QBChatDialog {
    func joinWithCompletion(_ completion:@escaping QBChatCompletionBlock) {
        if type != .private, isJoined() {
            completion(nil)
        } else {
            join { error in
                if let error = error, error._code == -1006 {
                    completion(nil)
                } else if let error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func joinAsync() async throws {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<Void, Error>) in
            joinWithCompletion { (error) in
                if let error = error {
                    prettyLog(error)
                    continuation.resume(throwing:error)
                } else {
                    continuation.resume()
                }
            }
        })
    }
    
    func leaveWithCompletion(_ completion:@escaping QBChatCompletionBlock) {
        if type == .private, isJoined() == false {
            completion(nil)
        } else {
            leave { error in
                if let error = error, error._code == -1001 {
                    completion(nil)
                } else if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func leaveAsync() async throws {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<Void, Error>) in
            leaveWithCompletion { (error) in
                if let error = error {
                    prettyLog(error)
                    continuation.resume(throwing:error)
                } else {
                    continuation.resume()
                }
            }
        })
    }
}

//TODO: handle errors
private extension QBRequest {
    struct QBDialogsPayload {
        let dialogs:[QBChatDialog]
        let usersIds: Set<NSNumber>
        let page: QBResponsePage
    }
    
    static func dialogs(with startPage: QBResponsePage) async throws -> QBDialogsPayload {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<QBDialogsPayload, any Error>) in
            let extended = ["sort_desc": "updated_at"]
            QBRequest.dialogs(for: startPage, extendedRequest: extended, successBlock: { response,
                dialogs, dialogsUsersIDs, page in
                continuation.resume(returning: QBDialogsPayload(dialogs: dialogs,
                                                                usersIds: dialogsUsersIDs,
                                                                page: page))
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func dialog(with dialogId: String) async throws -> QBChatDialog {
        let extendedRequest = ["_id": dialogId]
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.dialogs(for: QBResponsePage(),
                              extendedRequest: extendedRequest,
                              successBlock: { _, dialogs, _, _ in
                if let dialog = dialogs.first {
                    continuation.resume(returning: dialog)
                } else {
                    let info = "Dialog with id: \(dialogId)"
                    let error = DataSourceException.notFound(description: info)
                    continuation.resume(throwing: error)
                }
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        }
    }
    
    static func create(dialog: QBChatDialog) async throws -> QBChatDialog {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.createDialog(dialog, successBlock: { _, dialog in
                continuation.resume(returning: dialog)
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        }
    }
    
    static func update(dialog: QBChatDialog) async throws -> QBChatDialog {
        return try await withCheckedThrowingContinuation { continuation in
            QBRequest.update(dialog, successBlock: { _, dialog in
                continuation.resume(returning: dialog)
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        }
    }
    
    static func leave(dialog: QBChatDialog) async throws {
        let userId = QBSession.current.currentUserID
        dialog.pullOccupantsIDs = [(NSNumber(value: userId)).stringValue]
        _ = try await QBRequest.update(dialog: dialog)
    }
    
    static func delete(dialog id: String, force: Bool) async throws {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<Void, Error>) in
            print("remove Force \(force)")
            QBRequest.deleteDialogs(withIDs: Set([id]),
                                    forAllUsers: force,
                                    successBlock: { _,_,_,_ in
                continuation.resume()
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    
    static func updateUserInfo(withId id: UInt) async throws {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<Void, Error>) in
            QBRequest.user(withID: id, successBlock: { _, _ in
                continuation.resume()
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func user(withId userId: String) async throws -> QBUUser {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<QBUUser, Error>) in
            guard let id = UInt(userId) else {
                let info = "Incorrect user id: \(userId)"
                let ex = RemoteDataSourceException.incorrectData(description: info)
                continuation.resume(throwing:ex)
                return
            }
            QBRequest.user(withID: id, successBlock: { _, user in
                continuation.resume(returning: user)
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func users(withIDs userIds: [String], pagination startPage: Pagination)
    async throws -> (users: [QBUUser], pagination: Pagination) {
        let page = QBGeneralResponsePage(currentPage: UInt(startPage.currentPage + 1),
                                         perPage: UInt(startPage.limit))
        
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<(users: [QBUUser],
                                                pagination: Pagination), Error>) in
            QBRequest.users(withIDs: userIds,
                            page: page,
                            successBlock: { _, page, users in
                let pagination = Pagination(page: Int(page.currentPage),
                                            perPage: Int(page.perPage),
                                            total: Int(page.totalEntries))
                continuation.resume(returning: (users, pagination))
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func users(pagination startPage: Pagination)
    async throws -> (users: [QBUUser], pagination: Pagination) {
        let page = QBGeneralResponsePage(currentPage: UInt(startPage.currentPage + 1),
                                         perPage: UInt(startPage.limit))
        
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<(users: [QBUUser],
                                                pagination: Pagination), Error>) in
            let extendedRequest: [String: String] = ["order": "desc date last_request_at"]
            QBRequest.users(withExtendedRequest: extendedRequest,
                            page: page,
                            successBlock: { _, page, users in
                let pagination = Pagination(page: Int(page.currentPage),
                                            perPage: Int(page.perPage),
                                            total: Int(page.totalEntries))
                continuation.resume(returning: (users, pagination))
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func users(withFullName name: String,
                      pagination startPage: Pagination)
    async throws -> (users: [QBUUser], pagination: Pagination) {
        let page = QBGeneralResponsePage(currentPage: UInt(startPage.currentPage + 1),
                                         perPage: UInt(startPage.limit))
        
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<(users: [QBUUser],
                                                pagination: Pagination), Error>) in
            QBRequest.users(withFullName: name,
                            page: page,
                            successBlock: { _, page, users in
                let pagination = Pagination(page: Int(page.currentPage),
                                            perPage: Int(page.perPage),
                                            total: Int(page.totalEntries))
                continuation.resume(returning: (users, pagination))
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func messages(withDialogId dialogId: String,
                          messagesIds: [String],
                          pagination startPage: Pagination)
    async throws -> (messages: [QBChatMessage], pagination: Pagination) {
        let page = QBResponsePage(limit: startPage.limit,
                                  skip: startPage.skip)
        let extendedRequest = messagesIds.isEmpty
        ? ["sort_desc": "date_sent", "mark_as_read": "0"]
        : ["_id[in]": messagesIds.joined(separator: ",")]
        
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<(messages: [QBChatMessage],
                                                pagination: Pagination), Error>) in
            QBRequest.messages(withDialogID: dialogId, extendedRequest: extendedRequest, for: page, successBlock: { _, messages, newPage in
                continuation.resume(returning: (messages, Pagination(skip: newPage.skip,
                                                                     limit: newPage.limit,
                                                                     total: Int(newPage.totalEntries))))
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    
    static func upload(file data: Data,
                       fileName: String,
                       contentType: String,
                       isPublic: Bool) async throws -> QBCBlob {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<QBCBlob, Error>) in
            QBRequest.tUploadFile(data,
                                  fileName: fileName,
                                  contentType: contentType,
                                  isPublic: isPublic,
                                  successBlock: { _, blob in
                continuation.resume(returning: blob)
            }, statusBlock: { _,_ in
                //TODO: add progress handler
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func get(blobWithId id: UInt) async throws -> QBCBlob {
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<QBCBlob, Error>) in
            QBRequest.blob(withID: id, successBlock: { _, blob in
                continuation.resume(returning: blob)
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
            })
        })
    }
    
    static func download(file url: URL) async throws -> RemoteFileDTO {
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
            throw RemoteDataSourceException.incorrectData(description: info)
        }
        
        let uuid = fileName.components(separatedBy: ".").first
        
        let filePath = FilePath(remote: path)
        let fileExt = FileExtension(mimeType: mimeType)
        return RemoteFileDTO(id: uuid ?? fileName,
                             ext: fileExt,
                             name: fileName,
                             type: fileExt.type,
                             data: data,
                             path: filePath)
    }
    
    static func delete(file id: UInt) async throws {
        try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<Void, Error>) in
            QBRequest.deleteBlob(withID: id,
                                 successBlock: { _ in
                continuation.resume()
            }, errorBlock: { response in
                continuation.resume(throwing: response.error?.error
                                    ?? DataSourceException.unexpected())
                
            })
        })
    }
}

private extension QBChatDialogType {
    var mapToDialogType: DialogType {
        switch self {
        case .publicGroup: return .public
        case .group: return .group
        case .private: return .private
        @unknown default:
            return .unknown
        }
    }
}

private extension DialogType {
    var mapToQBDialogType: QBChatDialogType {
        switch self {
        case .public: return .publicGroup
        case .group: return .group
        case .private, .unknown: return .private
        }
    }
}

private extension RemoteDialogDTO {
    init(_ value: QBChatDialog) {
        id = value.id ?? UUID().uuidString
        type = value.type.mapToDialogType
        name = value.name ?? ""
        if let occupantIDs = value.occupantIDs {
            participantsIds = occupantIDs
                .map({ $0.stringValue })
        }
        ownerId = String(value.userID)
        isOwnedByCurrentUser = value.userID == QBSession.current.currentUserID
        
        //FIXME: Need implement
        
        createdAt = value.createdAt ?? Date()
        updatedAt = value.updatedAt ?? Date()
        
        if let lastMessageId = value.lastMessageID {
            self.lastMessageId = lastMessageId
            lastMessageText = value.lastMessageText ?? ""
            if value.lastMessageUserID != 0 {
                lastMessageUserId = String(value.lastMessageUserID)
            }
            //FIXME: Need implement
            if let lastMessageDate = value.lastMessageDate {
                lastMessageDateSent = lastMessageDate
            }
            
        }
        photo = value.photo ?? ""
        unreadMessagesCount = Int(value.unreadMessagesCount)
    }
}

private extension RemoteMessageDTO {
    init (_ value: QBChatMessage) {
        id = value.id ?? UUID().uuidString
        dialogId = value.dialogID ?? ""
        text = value.text ?? ""
        recipientId = value.recipientID != 0 ? String(value.recipientID) : ""
        senderId = value.senderID != 0 ? String(value.senderID) : ""
        senderResource = value.senderResource ?? ""
        if let date = value.dateSent { self.dateSent = date }
        if let params = value.customParameters as? [String: String] {
            customParameters = params
            if let save = params[QBChatMessage.Key.save] {
                saveToHistory = save == "1" ? true : false
            }
            if dialogId.isEmpty, let id = params[QBChatMessage.Key.dialogId] {
                dialogId = id
            }
        }
        
        if let attachments = value.attachments {
            self.filesInfo = attachments.compactMap {
                do {
                    return try RemoteFileInfoDTO($0)
                } catch {
                    prettyLog(error)
                    return nil
                }
            }
        }
        
        delayed = value.delayed
        markable = value.markable
        if let date = value.createdAt { createdAt = date }
        if let date = value.updatedAt { updatedAt = date }
        
        eventType = value.type
        type = eventType == .message ? .chat : .event
        
        let current = String(QBSession.current.currentUserID)
//        if let ids = value.deliveredIDs {
//            deliveredIds = ids.map { $0.stringValue }.filter { $0 != current }
//        }
//
//        if let ids = value.readIDs {
//            readIds = ids.map { $0.stringValue }.filter { $0 != current }
//        }
        isOwnedByCurrentUser = senderId == current
        if isOwnedByCurrentUser {
            if let ids = value.deliveredIDs {
                isDelivered = ids.map { $0.stringValue }.filter { $0 != current }.isEmpty == false
            }
            if let ids = value.readIDs {
                isReaded = ids.map { $0.stringValue }.filter { $0 != current }.isEmpty == false
            }
        } else {
            if let ids = value.readIDs {
                isReaded = ids.map { $0.stringValue }.contains(current) == true
            }
            if let ids = value.deliveredIDs {
                isDelivered = ids.map { $0.stringValue }.contains(current) == true
            }
        }
    }
    
    static func eventMessage(_ text: String,
                             dialogId: String,
                             type: MessageType,
                             eventType: MessageEventType) -> RemoteMessageDTO {
        var message = RemoteMessageDTO(dialogId: "",
                                       text: text,
                                       senderId: String(QBSession.current.currentUserID),
                                       dateSent: Date(),
                                       eventType: eventType,
                                       type: type)
        message.markable = false
        switch eventType {
        case .create:
            message.customParameters[QBChatMessage.Key.dialogId] = dialogId
            message.customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.create
        case .update:
            message.customParameters[QBChatMessage.Key.dialogId] = dialogId
            message.customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.update
        case .leave:
            message.customParameters[QBChatMessage.Key.dialogId] = dialogId
            message.customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.leave
        case .removed:
            message.customParameters[QBChatMessage.Key.dialogId] = dialogId
            message.customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.removed
        case .message:
            message.markable = true
            message.dialogId = dialogId
            message.customParameters[QBChatMessage.Key.save] = "1"
            message.deliveredIds = [message.senderId]
            message.readIds = [message.senderId]
        case .read:
            break
        case .delivered:
            break
        }
        if type == .chat {
            message.dialogId = dialogId
        }
        return message
    }
}

extension QBChatMessage {
    convenience init(_ value: RemoteMessageDTO, toSend: Bool) {
        self.init()
        if toSend == false {
            id = value.id
        }
        dialogID = value.dialogId
        text = value.text
        senderID = (toSend == true ? QBSession.current.currentUserID : UInt(value.senderId)) ?? 0
        recipientID = UInt(value.recipientId) ?? 0
        senderResource = value.senderResource
        dateSent = toSend == true ? Date() : value.dateSent
        customParameters = NSMutableDictionary(dictionary: value.customParameters)
        if value.type == .chat {
            customParameters[QBChatMessage.Key.save] = true
            if value.dialogId.isEmpty,
                let id = customParameters[QBChatMessage.Key.dialogId] as? String {
                dialogID = id
            }
        }
        
        switch value.eventType {
        case .create:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.create
        case .update:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.update
        case .leave:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.leave
        case .removed:
            customParameters[QBChatMessage.Key.type]
            = QBChatMessage.Value.removed
        case .message:
            break
        case .read:
            break
        case .delivered:
            break
        }
        
        attachments = value.filesInfo.compactMap {
            return QBChatAttachment($0)
        }
        
        delayed = value.delayed
        markable = value.markable
        
        readIDs = toSend == true ? [NSNumber(value: QBSession.current.currentUserID)] : value.readIds.compactMap { NSNumber(value: UInt($0) ?? 0) }
        deliveredIDs = toSend == true ? [NSNumber(value: QBSession.current.currentUserID)] : value.deliveredIds.compactMap { NSNumber(value: UInt($0) ?? 0) }
    }
}

private extension RemoteFileInfoDTO {
    init (_ value: QBChatAttachment) throws {
        guard let id = value.id else {
            let info = "\(String(describing: QBChatAttachment.self)) id is missing"
            throw MapperException.incorrectData(description: info)
        }
        self.id = id
        
        name = value.name ?? ""
        type = value.type ?? ""
        path = value.url ?? ""
    }
}

extension QBChatAttachment {
    convenience init(_ value: RemoteFileInfoDTO) {
        self.init()
        id = value.id
        name = value.name
        type = value.type
        url = value.path
    }
}

private extension RemoteUserDTO {
    init (_ value: QBUUser) {
        id = String(value.id)
        name = value.fullName ?? ""
        if (value.blobID > 0) {
            avatarPath = String(value.blobID)
        }
        lastRequestAt = value.lastRequestAt ??
        Date(timeIntervalSince1970: 0)
        isCurrent = QBSession.current.currentUserID == value.id
    }
}

private extension NSError {
    func convertToRemoteException() throws -> Error {
        var info = "Status code: \(self.code). "
        
        switch self.code {
        case 401, 422:
            if let reason = self.userInfo[NSLocalizedFailureReasonErrorKey] as? NSDictionary {
                let data = try JSONSerialization.data(withJSONObject: reason,
                                                      options: .prettyPrinted)
                let payload = try JSONDecoder().decode(QBResponseErrorPayload.self,
                                                       from: data)
                info = info + "Reason: \(payload.info)"
            }
            throw RemoteDataSourceException.unauthorised(info)
        default:
            throw DataSourceException.unexpected(self.localizedDescription)
        }
    }
}

private extension String {
    var isNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}
