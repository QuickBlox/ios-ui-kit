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

extension Task where Success == Never, Failure == Never {
    static func wait(second: Double) async throws {
        let duration = UInt64(second * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
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
    
    private var api = API()
    
    private var stream = ChatStream()
    
    private let qbChat = QBChat.instance
    
    override init() {
        super.init()
        //FIXME: Must be set QBSettings.applicationID before using QBSession.currentSession
        QBSettings.disableXMPPLogging()
        QBSettings.logLevel = .debug
        QBSettings.carbonsEnabled = true
        qbChat.addDelegate(self)
        
        AuthorizationObserver.shared.publisher
            .removeDuplicates()
            .sink(receiveValue: { event in
                switch event {
                case .loginEvent:
                    Task { [weak self] in
                        guard let self = self else { return }
                        
                        await self.stream.clear()
                        self.connectionSubject.send(.authorized)
                    }
                case .logoutEvent:
                    Task { [weak self] in
                        guard let self = self else { return }
                        
                        await self.stream.clear()
                        self.connectionSubject.send(.unauthorized)
                    }
                default: return
                }
            })
            .store(in: &cancellables)
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
            // TODO: add support custom identity provider
            // update user info
            _ = try await api.users.get(with: String(currentUser.id))
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
        if message.type == .removed || message.type == .update || message.type == .leave {
            let withId = RemoteDialogDTO(id: dialogID)
            Task {
                try await getAndUpdate(dialog: withId)
                await stream.process(message)
            }
        } else {
            Task {
                await stream.process(message)
            }
        }
    }
    
    func chatDidReceiveSystemMessage(_ message: QBChatMessage) {
        if message.senderID == currentUserId { return }
        Task {
            try await Task.wait(second: 1.0)
            await stream.process(message)
        }
    }
    
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        if readerID == QBSession.current.currentUserID { return }
        Task { await stream.didRead(messageID, dialogID: dialogID, readerID: String(readerID)) }
    }
    
    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        if userID == QBSession.current.currentUserID { return }
        Task { await stream.didDilivered(messageID, dialogID: dialogID, toUserID: String(userID)) }
    }
}

//MARK: Dialogs
extension RemoteDataSource {
    func create(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
        let dialog = QBChatDialog(dialogID: nil,
                                  type: dto.type.qbDialogType)
        let pIds = dto.participantsIds.map{ NSNumber(value: Int($0) ?? 0) }
        
        dialog.occupantIDs = pIds
        if dialog.type == .group {
            dialog.name = dto.name
            dialog.photo = dto.photo
        }
        let created = try await api.dialogs.create(new: dialog)
        await stream.add(chat: created)
        
        guard let dialogId = created.id else {
            let info = "Dialog with id: \(dto.id)"
            throw RemoteDataSourceException.incorrectData(info)
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

        await stream.process(RemoteEvent.create(created.id ?? "", byUser: true, message: RemoteMessageDTO(qbChatMessage)))
        
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
        
        let photo = dto.photo == "null" ? "null" : dto.photo
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
        
        if dto.toAddIds.isEmpty == false {
            for userId in dto.toAddIds {
                if let user = users.first(where: { $0.id == userId }) {
                    if pushIds.isEmpty {
                        pushLog = pushLog.add(user.name)
                    } else {
                        pushLog = pushLog.coma.add(user.name)
                    }
                    pushIds.append(user.id)
                }
            }
        }
        
        if dto.toDeleteIds.isEmpty == false {
            for userId in dto.toDeleteIds {
                if let user = users.first(where: { $0.id == userId }) {
                    if pullIds.isEmpty {
                        pullLog = pullLog.add(user.name)
                    } else {
                        pullLog = pullLog.coma.add(user.name)
                    }
                    pullIds.append(user.id)
                }
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
        
        let updated = try await api.dialogs.update(dialog)
        
        await stream.update(chat: updated)
        
        let message = RemoteMessageDTO.eventMessage(text.value,
                                                    dialogId: dialogId,
                                                    type: .chat,
                                                    eventType: .update)
        await stream.send(QBChatMessage(message, toSend: true))
       
        
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
        system.recipientId = String(user.id)
        await stream.process(QBChatMessage(system, toSend: true))
        
        for id in ids {
            system.recipientId = id
            try? await qbChat.sendSystemMessage(QBChatMessage(system, toSend: true))
        }
        
        
        return RemoteDialogDTO(updated)
    }
    
    func getAndUpdate(dialog dto: RemoteDialogDTO) async throws {
        do {
            let dialog = try await api.dialogs.get(with: dto.id)
            await stream.update(chat: dialog)
            
        } catch let nsError as NSError {
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
        do {
            let dialog = try await api.dialogs.get(with: dto.id)
            await stream.add(chat: dialog)
            
            return RemoteDialogDTO(dialog)
        } catch let nsError as NSError {
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(dialogs dto: RemoteDialogsDTO) async throws -> RemoteDialogsDTO {
        do {
            let page = QBResponsePage(limit: dto.pagination.limit,
                                      skip: dto.pagination.skip)
            let result = try await api.dialogs.get(for: page)
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
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func getAllDialogs() async throws -> RemoteDialogsDTO {
        do {
            let page = QBResponsePage(limit: 1, skip: 0, totalEntries: 1)
            
            let result = try await api.dialogs.get(for: page)
            
            try Task.checkCancellation()
            var allDialogs: [RemoteDialogDTO] = []
            for dialog in result.dialogs {
                await stream.add(chat: dialog)
                allDialogs.append(RemoteDialogDTO(dialog))
            }
            
            return RemoteDialogsDTO(dialogs: allDialogs)
        } catch let nsError as NSError {
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func delete(dialog dto: RemoteDialogDTO) async throws {
        if dto.id.isEmpty {
            let info = "Internal. Empty dialog id"
            throw RepositoryException.incorrectData(info)
        }
        
        let message = try QBChatMessage.leave(dialog: dto.id)
        if dto.type == .private {
            message.customParameters[QBChatMessage.Key.save] = false
        }
        
        await stream.send(message)
        
        if dto.type == .private {
            if dto.isOwnedByCurrentUser {
                try await api.dialogs.delete(with: dto.id, force: true)
            } else {
                try await api.dialogs.delete(with: dto.id, force: false)
            }
        } else if dto.type == .group {
            let dialog = try await stream.qbChat(with: dto.id)
            try await api.dialogs.leave(dialog)
        }
        await stream.process(.leave(dto.id, byUser: true))
        await stream.remove(chat: dto.id)
    }
    
    func subscribeToObserveTyping(dialog dialogId: String) async throws {
        await stream.subscribeToTyping(chat: dialogId)
    }
    
    func sendTyping(dialog dialogId: String) async throws {
        await stream.sendTyping(chat: dialogId)
    }
    
    func sendStopTyping(dialog dialogId: String) async throws {
        await stream.sendStopTyping(chat: dialogId)
    }
}

//MARK: Messages
extension RemoteDataSource {
    func get(messages dto: RemoteMessagesDTO) async throws -> RemoteMessagesDTO {
        do {
            let result = try await api.messages.get(for: dto.dialogId,
                                                    with: dto.ids,
                                                    page: dto.pagination)
            let messages = result.messages.map { RemoteMessageDTO($0) }
            let messagesDTO = RemoteMessagesDTO(dialogId: dto.dialogId,
                                                messages: messages,
                                                pagination: result.pagination)
            return messagesDTO
        } catch let nsError as NSError {
            throw try nsError.remoteException
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
            let user = try await api.users.get(with: dto.id)
            return RemoteUserDTO(user)
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(users dto: RemoteUsersDTO) async throws -> RemoteUsersDTO {
        do {
            var tuple: (users: [QBUUser], pagination: Pagination)
            if dto.ids.isEmpty == false {
                tuple = try await api.users.get(with: dto.ids,
                                                page: dto.pagination)
            } else if dto.name.isEmpty == false {
                tuple = try await api.users.get(with: dto.name,
                                                page: dto.pagination)
            } else {
                tuple = try await api.users.get(for: dto.pagination)
            }
            
            let users = tuple.users
                .map { RemoteUserDTO($0)}
            return RemoteUsersDTO(users: users,
                                  pagination: tuple.pagination)
        } catch let nsError as NSError {
            if nsError.code == 404 {
                return RemoteUsersDTO(users: [],
                                      pagination: dto.pagination)
            } 
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
}

//MARK: Files
extension RemoteDataSource {
    func create(file dto: RemoteFileDTO) async throws -> RemoteFileDTO {
        do {
            let blob = try await api.files.upload(file: dto)
            guard let uuid = blob.uid,
                  let path = QBCBlob.publicUrl(forFileUID: uuid) else {
                let info = "Internal. Generate path fails for file with id: \(blob.id)."
                throw RemoteDataSourceException.incorrectData(info)
            }
            
            let fileName = blob.name ?? "file"
            let fileId = String(blob.id)
            let fileUID = blob.uid ?? ""
            
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
                                 path: filePath,
                                 uid: fileUID)
        } catch let nsError as NSError {
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
    
    func get(file dto: RemoteFileDTO) async throws -> RemoteFileDTO {
        if dto.id.isNumber {
            if dto.id == "0" {
                let info = "Internal. Incorrect file path: \(dto.id)"
                throw RemoteDataSourceException.incorrectData(info)
            }
            do {
                guard let intId = UInt(dto.id) else {
                    let info = "Internal. Incorrect file path: \(dto.id)"
                    throw RemoteDataSourceException.incorrectData(info)
                }
                
                let blob = try await api.files.get(blob: intId)
                
                let fileName = blob.name ?? "file"
                let fileId = String(blob.id)
                
                var fileExtension: FileExtension
                if let contentType = blob.contentType {
                    fileExtension = FileExtension(mimeType: contentType)
                    if contentType.contains("mp4a") || contentType.contains("aac") {
                        fileExtension = .caf
                    }
                } else if let extStr = fileName.components(separatedBy: ".").last,
                   let ext = FileExtension(rawValue: extStr.lowercased()) {
                    fileExtension = ext
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
                    throw RemoteDataSourceException.incorrectData(info)
                }
                
                guard let path = QBCBlob.publicUrl(forFileUID: uuid) else {
                    let info = "Internal. Generate path fails for file with id: \(blob.id)."
                    throw RemoteDataSourceException.incorrectData(info)
                }
                
                let filePath = FilePath(remote: path)
                
                var uploaded = try await get(fileWithPath: uuid)
                uploaded.id = fileId
                
                uploaded.ext = fileExtension
                uploaded.name = fileName
                uploaded.type = fileExtension.type
                uploaded.path = filePath
                uploaded.uid = uuid
                return uploaded
            } catch let nsError as NSError {
                throw try nsError.remoteException
            } catch {
                throw DataSourceException.unexpected(error.localizedDescription)
            }
        } else {
            var uploaded = try await get(fileWithPath: dto.id)
            if uploaded.name.contains("json"), uploaded.ext != .json {
                uploaded.name = uploaded.name.replacingOccurrences(of: "json",
                                                             with: uploaded.ext.rawValue)
            }
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
            throw RemoteDataSourceException.incorrectData(info)
        }
        
        if components.scheme == nil,
           let endpoint = QBSettings.apiEndpoint {
            let path = endpoint + "/blobs/" + path + ".json"
            guard let modified = URLComponents(string: path) else {
                let info = "Internal. Generate url with path: \(path)."
                throw RemoteDataSourceException.incorrectData(info)
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
            throw RemoteDataSourceException.incorrectData(info)
        }
        
        return try await api.files.get(with: url)
    }
    
    func delete(file dto: RemoteFileDTO) async throws {
        do {
            guard let intId = UInt(dto.id) else {
                let info = "Internal. Incorrect id: \(dto.id)"
                throw RemoteDataSourceException.incorrectData(info)
            }
            
            try await api.files.delete(with: intId)
        } catch let nsError as NSError {
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
}
