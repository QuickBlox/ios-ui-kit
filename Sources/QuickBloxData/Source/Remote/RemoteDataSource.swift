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
    
    private var user: QBUUser?
    
    override init() {
        super.init()
        //FIXME: Must be set QBSettings.applicationID before using QBSession.currentSession
        QBChat.instance.addDelegate(self)
        
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
                        self.user = nil
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
            try await QBChat.instance.connect(withUserID: details.userID,
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
        
        guard QBChat.instance.isConnected || QBChat.instance.isConnecting else {
            connectionSubject.send(.disconnected())
            return
        }
        
        do {
            try await QBChat.instance.disconnect()
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
    
    func checkConnection() async throws -> ConnectionState {
        guard let token = QBSession.current.sessionDetails?.token else {
            connectionSubject.send(.unauthorized)
            return .unauthorized
        }
        
        let userId = QBSession.current.currentUserID
        
        guard userId > 0 || token.isEmpty else {
            connectionSubject.send(.unauthorized)
            return .unauthorized
        }
        
        let fullName = user?.fullName ?? ""
        if QBSession.current.tokenHasExpired || fullName.isEmpty {
            // TODO: add support custom identity provider
            // update user info
            user = try await api.users.get(with: String(userId))
            try Task.checkCancellation()
        }
        
        if QBChat.instance.isConnecting {
            connectionSubject.send(.connecting())
            return .connecting()
        } else if QBChat.instance.isConnected {
            connectionSubject.send(.connected)
            return .connected
        } else {
            connectionSubject.send(.disconnected())
            return .disconnected()
        }
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
        
        guard let dialogId = created.id else {
            let info = "Dialog with id: \(dto.id)"
            throw RemoteDataSourceException.incorrectData(info)
        }
        
        await stream.update(with: created)
        await self.stream.subscribe(chat: dialogId)
        
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

        await stream.process(.create(created.id ?? "", byUser: true, message: RemoteMessageDTO(qbChatMessage)))
        
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
            try? await QBChat.instance.sendSystemMessage(system)
        }
        return RemoteDialogDTO(created)
    }
    
    private func create(dialogText chatName: String) -> String {
        let actionMessage = "created the group chat"
        guard let current = user else { return "" }
        return "\(current.fullName ?? "\(current.id)") \(actionMessage) \"\(chatName)\""
    }
    
    func update(dialog dto: RemoteDialogDTO,
                users: [RemoteUserDTO]) async throws -> RemoteDialogDTO {
        let dialog = try await stream.qbChat(with: dto.id)
        
        guard let dialogId = dialog.id else {
            let info = "Not found dialog with id: \(dto.id)"
            throw DataSourceException.notFound(description: info)
        }
        guard let user = user else {
            let info = "Current user not found"
            throw DataSourceException.notFound(description: info)
        }
        
        var userName = String(user.id)
        if let fullName = user.fullName, fullName.isEmpty == false {
            userName = fullName
        }
        
        var text = Log()
        if dto.name.isEmpty == false, dialog.name != dto.name {
            dialog.name = dto.name
            text = text
                .add("The dialog renamed by user \(userName)")
                .newLine
        }

        if dialog.avatarPath != dto.photo {
            dialog.photo = dto.photo.isEmpty == true ? "null" : dto.photo
            
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

        await stream.update(with: updated)
        await self.stream.subscribe(chat: dialogId)
        
        let message = RemoteMessageDTO.eventMessage(text.value,
                                                    dialogId: dialogId,
                                                    type: .chat,
                                                    eventType: .update)
        let qbMessage = QBChatMessage(message, toSend: true)
        await stream.send(qbMessage)
        await stream.process(qbMessage)
        
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
            try? await QBChat.instance.sendSystemMessage(QBChatMessage(system, toSend: true))
        }
        
        
        return RemoteDialogDTO(updated)
    }
    
    func get(dialog dto: RemoteDialogDTO) async throws -> RemoteDialogDTO {
        do {
            let dialog = try await api.dialogs.get(with: dto.id)
            await stream.update(with: dialog)
            if let dialogId = dialog.id {
                await stream.subscribe(chat: dialogId)
            }
            
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
            await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                guard let self = self else {
                    group.cancelAll()
                    return
                }
                
                for dialog in result.dialogs {
                    group.addTask {
                        await self.stream.update(with: dialog)
                        Task {
                            guard let dialogId = dialog.id else { return }
                            await self.stream.subscribe(chat: dialogId)
                        }
                    }
                }
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
            
            await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                guard let self = self else {
                    group.cancelAll()
                    return
                }
                
                for dialog in result.dialogs {
                    group.addTask { await self.stream.update(with: dialog) }
                    Task {
                        guard let dialogId = dialog.id else { return }
                        await self.stream.subscribe(chat: dialogId)
                    }
                    allDialogs.append(RemoteDialogDTO(dialog))
                }
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
        
        guard let user = user else {
            let info = "Internal: Invalid or unauthorized current user."
            throw RepositoryException.incorrectData(info)
        }
        
        let message = try QBChatMessage.event(user, leaveDialog: dto.id)
        if dto.type == .private {
            message.customParameters[QBChatMessage.Key.save] = false
        }
        
        await stream.send(message)
        let dialog = try await stream.qbChat(with: dto.id)
        await stream.remove(chat: dto.id)
        
        if dto.type == .private {
            if dto.isOwnedByCurrentUser {
                try await api.dialogs.delete(with: dto.id, force: true)
            } else {
                try await api.dialogs.delete(with: dto.id, force: false)
            }
        } else if dto.type == .group {
            try await api.dialogs.leave(dialog)
        }
        
        await stream.process(.leave(dto.id))
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
        try await stream.read(message)
    }
    
    func delivered(message dto: RemoteMessageDTO) async throws {
        let userId = QBSession.current.currentUserID
        if dto.deliveredIds.contains(String(userId)) == true { return }
        let message = QBChatMessage(dto, toSend: false)
        try await stream.delivered(message)
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

//MARK: AI
extension RemoteDataSource {
    // Quickblox Server API
    func answerAssist(message dto: RemoteAnswerAssistMessageDTO) async throws -> String {
        do {
            return try await api.ai.answerAssist(with: QBAIAnswerAssistMessage(dto))
        } catch let nsError as NSError {
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
        
    }
    
    func translate(message dto: RemoteTranslateMessageDTO) async throws -> String {
        do {
            return try await api.ai.translate(with: QBAITranslateMessage(dto))
        } catch let nsError as NSError {
            throw try nsError.remoteException
        } catch {
            throw DataSourceException.unexpected(error.localizedDescription)
        }
    }
}

//MARK: AI Quickblox QBAIAnswerAssistant Library
import QBAIAnswerAssistant
extension RemoteDataSource {
    func answerAssist(with content: [RemoteMessageDTO],
                      settings: QBAIAnswerAssistant.AISettings) async throws -> String {
            return try await api.ai.answerAssist(with: content, settings: settings)
    }
}

//MARK: AI Quickblox QBAITranslate Library
import QBAITranslate
extension RemoteDataSource {
    func translate(with text: String,
                   content: [RemoteMessageDTO],
                   settings: QBAITranslate.AISettings) async throws -> String {
            return try await api.ai.translate(with: text, content: content, settings: settings)
    }
}
