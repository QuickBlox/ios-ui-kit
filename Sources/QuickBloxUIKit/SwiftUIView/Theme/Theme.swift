//
//  Theme.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 23.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public protocol ThemeProtocol: AnyObject {
    var color: ThemeColorProtocol { get set }
    var font: ThemeFontProtocol { get set }
    var image: ThemeImageProtocol { get set }
    var string: ThemeStringProtocol { get set }
}

public class Theme: ThemeProtocol {
    public var color: ThemeColorProtocol = ThemeColor()
    public var font: ThemeFontProtocol = ThemeFont()
    public var image: ThemeImageProtocol = ThemeImage()
    public var string: ThemeStringProtocol = ThemeString()
    
    public init() {}
}

//MARK: Theme Font
public protocol ThemeFontProtocol {
    var headline: Font { get set }
    var footnote: Font { get set }
    var caption: Font { get set }
    var caption2: Font { get set }
    var callout: Font { get set }
    var largeTitle: Font { get set }
    var title1: Font { get set }
    var title3: Font { get set }
}

public class ThemeFont: ThemeFontProtocol {
    public var headline: Font = .headline
    public var footnote: Font = .footnote.weight(.semibold)
    public var caption: Font = .caption
    public var caption2: Font = .caption2
    public var callout: Font = .callout
    public var largeTitle: Font = .largeTitle
    public var title1: Font = .title.weight(.semibold)
    public var title3: Font = .title3
    
    public init() {}
}

//MARK: Theme Color
public protocol ThemeColorProtocol {
    var mainElements: Color { get set }
    var secondaryElements: Color { get set }
    var tertiaryElements: Color { get set }
    var disabledElements: Color { get set }
    var mainText: Color { get set }
    var secondaryText: Color { get set }
    var caption: Color { get set }
    var mainBackground: Color { get set }
    var secondaryBackground: Color { get set }
    var tertiaryBackground: Color { get set }
    var incomingBackground: Color { get set }
    var outgoingBackground: Color { get set }
    var dropdownBackground: Color { get set }
    var inputBackground: Color { get set }
    var divider: Color { get set }
    var error: Color { get set }
    var success: Color { get set }
    var highLight: Color { get set }
    var system: Color { get set }
}

public class ThemeColor: ThemeColorProtocol {
    public var mainElements: Color = Color("MainElements", bundle: .module)
    public var secondaryElements: Color = Color("SecondaryElements", bundle: .module)
    public var tertiaryElements: Color = Color("TertiaryElements", bundle: .module)
    public var disabledElements: Color = Color("DisabledElements", bundle: .module)
    public var mainText: Color = Color("MainText", bundle: .module)
    public var secondaryText: Color = Color("SecondaryText", bundle: .module)
    public var caption: Color = Color("Caption", bundle: .module)
    public var mainBackground: Color = Color("MainBackground", bundle: .module)
    public var secondaryBackground: Color = Color("SecondaryBackground", bundle: .module)
    public var tertiaryBackground: Color = Color("TertiaryBackground", bundle: .module)
    public var incomingBackground: Color = Color("IncomingBackground", bundle: .module)
    public var outgoingBackground: Color = Color("OutgoingBackground", bundle: .module)
    public var dropdownBackground: Color = Color("DropdownBackground", bundle: .module)
    public var inputBackground: Color = Color("InputBackground", bundle: .module)
    public var divider: Color = Color("Divider", bundle: .module)
    public var error: Color = Color("Error", bundle: .module)
    public var success: Color = Color("Success", bundle: .module)
    public var highLight: Color = Color("HighLight", bundle: .module)
    public var system: Color = Color("System", bundle: .module)
    
    public init() {}
}

//MARK: Theme Image
public protocol ThemeImageProtocol {
    var avatarUser: Image { get set }
    var avatarGroup: Image { get set }
    var avatarPublic: Image { get set }
    var user: Image { get set }
    var groupChat: Image { get set }
    var publicChannel: Image { get set }
    var leave: Image { get set }
    var leavePNG: Image { get set }
    var newChat: Image { get set }
    var back: Image { get set }
    var close: Image { get set }
    var conference: Image { get set }
    var chat: Image { get set }
    var camera: Image { get set }
    var avatarCamera: Image { get set }
    var checkmark: Image { get set }
    var attachmentPlaceholder: Image { get set }
    var info: Image { get set }
    var bell: Image { get set }
    var magnifyingglass: Image { get set }
    var chevronForward: Image { get set }
    var trash: Image { get set }
    var plus: Image { get set }
    var mic: Image { get set }
    var smiley: Image { get set }
    var paperclip: Image { get set }
    var paperplane: Image { get set }
    var keyboard: Image { get set }
    var record: Image { get set }
    var wave: Image { get set }
    var play: Image { get set }
    var pause: Image { get set }
    var photo: Image { get set }
    var delivered: Image { get set }
    var read: Image { get set }
    var send: Image { get set }
    var doctext: Image { get set }
    var speakerwave: Image { get set }
    var message: Image { get set }
    var robot: Image { get set }
}

public class ThemeImage: ThemeImageProtocol {
    public var avatarUser: Image = Image("AvatarUser", bundle: .module)
    public var avatarGroup: Image = Image("AvatarGroup", bundle: .module)
    public var avatarPublic: Image = Image("AvatarPublic", bundle: .module)
    public var user: Image = Image(systemName: "person")
    public var groupChat: Image = Image(systemName: "person.2")
    public var publicChannel: Image = Image(systemName: "megaphone")
    public var leave: Image = Image(systemName: "rectangle.portrait.and.arrow.forward")
    public var leavePNG: Image = Image("Leave", bundle: .module)
    public var newChat: Image = Image(systemName: "square.and.pencil")
    public var back: Image = Image(systemName: "chevron.backward")
    public var close: Image = Image(systemName: "xmark")
    public var conference: Image = Image(systemName: "person.3")
    public var chat: Image = Image(systemName: "message")
    public var camera: Image = Image(systemName: "camera")
    public var avatarCamera: Image = Image("AvatarCamera", bundle: .module)
    public var checkmark: Image = Image(systemName: "checkmark")
    public var attachmentPlaceholder: Image = Image("attachmentPlaceholder", bundle: .module)
    public var info: Image = Image(systemName: "info.circle")
    public var bell: Image = Image(systemName: "bell")
    public var magnifyingglass: Image = Image(systemName: "magnifyingglass")
    public var chevronForward: Image = Image(systemName: "chevron.forward")
    public var trash: Image = Image(systemName: "trash")
    public var plus: Image = Image(systemName: "plus.app")
    public var mic: Image = Image(systemName: "mic")
    public var smiley: Image = Image(systemName: "smiley")
    public var paperclip: Image = Image(systemName: "paperclip")
    public var paperplane: Image = Image(systemName: "paperplane.fill")
    public var keyboard: Image = Image(systemName: "keyboard")
    public var record: Image = Image(systemName: "record.circle")
    public var wave: Image = Image("wave", bundle: .module)
    public var play: Image = Image(systemName: "play.fill")
    public var pause: Image = Image(systemName: "pause.fill")
    public var photo: Image = Image(systemName: "photo")
    public var delivered: Image = Image("delivered", bundle: .module)
    public var read: Image = Image("delivered", bundle: .module)
    public var send: Image = Image("send", bundle: .module)
    public var doctext: Image = Image(systemName: "doc.text.fill")
    public var speakerwave: Image = Image(systemName: "speaker.wave.1.fill")
    public var message: Image = Image(systemName: "message")
    public var robot: Image = Image("Robot", bundle: .module)
    
    public init() {}
}

extension UIColor {
    convenience init?(hexRGB: String, alpha: CGFloat = 1) {
        var chars = Array(hexRGB.hasPrefix("#") ? hexRGB.dropFirst() : hexRGB[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }
        case 6: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                alpha: alpha)
    }
}


//MARK: Theme Strings
public protocol ThemeStringProtocol {
    var dialogsEmpty: String { get set }
    var usersEmpty: String { get set }
    var messegesEmpty: String { get set }
    
    var privateDialog: String { get set }
    var groupDialog: String { get set }
    var publicDialog: String { get set }
    
    var typingOne: String { get set }
    var typingTwo: String { get set }
    var typingFour: String { get set }
    
    var enterName: String { get set }
    var nameHint: String { get set }
    var create: String { get set }
    var next: String { get set }
    var search: String { get set }
    var edit: String { get set }
    var members: String { get set }
    var notification: String { get set }
    var searchInDialog: String { get set }
    var leaveDialog: String { get set }
    
    var you: String { get set }
    var admin: String { get set }
    var typeMessage: String { get set }
    
    var dialogs: String { get set }
    var dialog: String { get set }
    var dialogType: String { get set }
    var newDialog: String { get set }
    var createDialog: String { get set }
    var addMembers: String { get set }
    var dialogInformation: String { get set }
    
    var add: String { get set }
    var dialogName: String { get set }
    var changeImage: String { get set }
    var changeDialogName: String { get set }
    
    var photo: String { get set }
    var removePhoto: String { get set }
    var camera: String { get set }
    var gallery: String { get set }
    var file: String { get set }
    
    var remove: String { get set }
    var cancel: String { get set }
    var ok: String { get set }
    var removeUser: String { get set }
    var questionMark: String { get set }
    var errorValidation: String { get set }
    var addUser: String { get set }
    var toDialog: String { get set }
    var noResults: String { get set }
    var noMembers: String { get set }
    
    var maxSize: String { get set }
    var maxSizeHint: String { get set }
    var fileTitle: String { get set }
    var gif: String { get set }
}

public class ThemeString: ThemeStringProtocol {
    public var dialogsEmpty: String = String(localized: "dialog.items.empty", bundle: .module)
    public var usersEmpty: String = String(localized: "dialog.members.empty", bundle: .module)
    public var messegesEmpty: String = String(localized: "dialog.messages.empty", bundle: .module)
    
    public var privateDialog: String = String(localized: "dialog.type.private", bundle: .module)
    public var groupDialog: String = String(localized: "dialog.type.group", bundle: .module)
    public var publicDialog: String = String(localized: "dialog.type.group", bundle: .module)
    
    public var typingOne: String = String(localized: "dialog.typing.one", bundle: .module)
    public var typingTwo: String = String(localized: "dialog.typing.two", bundle: .module)
    public var typingFour: String = String(localized: "dialog.typing.four", bundle: .module)
    
    public var enterName: String = String(localized: "alert.actions.enterName", bundle: .module)
    public var nameHint: String = String(localized: "dialog.name.hint", bundle: .module)
    public var create: String = String(localized: "dialog.name.create", bundle: .module)
    public var next: String = String(localized: "dialog.name.next", bundle: .module)
    public var search: String = String(localized: "dialog.name.search", bundle: .module)
    public var edit: String = String(localized: "dialog.info.edit", bundle: .module)
    public var members: String = String(localized: "dialog.info.members", bundle: .module)
    public var notification: String = String(localized: "dialog.info.notification", bundle: .module)
    public var searchInDialog: String = String(localized: "dialog.info.searchInDialog", bundle: .module)
    public var leaveDialog: String = String(localized: "dialog.info.leaveDialog", bundle: .module)
    
    public var you: String = String(localized: "dialog.info.you", bundle: .module)
    public var admin: String = String(localized: "dialog.info.admin", bundle: .module)
    public var typeMessage: String = String(localized: "dialog.action.typeMessage", bundle: .module)
    
    public var dialogs: String = String(localized: "screen.title.dialogs", bundle: .module)
    public var dialog: String = String(localized: "screen.title.dialog", bundle: .module)
    public var dialogType: String = String(localized: "screen.title.dialogType", bundle: .module)
    public var newDialog: String = String(localized: "screen.title.newDialog", bundle: .module)
    public var createDialog: String = String(localized: "screen.title.createDialog", bundle: .module)
    public var addMembers: String = String(localized: "screen.title.addMembers", bundle: .module)
    public var dialogInformation: String = String(localized: "screen.title.dialogInformation", bundle: .module)
    
    public var add: String = String(localized: "alert.actions.add", bundle: .module)
    public var dialogName: String = String(localized: "alert.actions.dialogName", bundle: .module)
    public var changeImage: String = String(localized: "alert.actions.changeImage", bundle: .module)
    public var changeDialogName: String = String(localized: "alert.actions.changeDialogName", bundle: .module)
    
    public var photo: String = String(localized: "alert.actions.photo", bundle: .module)
    public var removePhoto: String = String(localized: "alert.actions.removePhoto", bundle: .module)
    public var camera: String = String(localized: "alert.actions.camera", bundle: .module)
    public var gallery: String = String(localized: "alert.actions.gallery", bundle: .module)
    public var file: String = String(localized: "alert.actions.file", bundle: .module)
    
    public var remove: String = String(localized: "alert.actions.remove", bundle: .module)
    public var cancel: String = String(localized: "alert.actions.cancel", bundle: .module)
    public var ok: String = String(localized: "alert.actions.ok", bundle: .module)
    public var removeUser: String = String(localized: "alert.message.removeUser", bundle: .module)
    public var questionMark: String = String(localized: "alert.message.questionMark", bundle: .module)
    public var errorValidation: String = String(localized: "alert.message.errorValidation", bundle: .module)
    public var addUser: String = String(localized: "alert.message.addUser", bundle: .module)
    public var toDialog: String = String(localized: "alert.message.toDialog", bundle: .module)
    public var noResults: String = String(localized: "alert.message.noResults", bundle: .module)
    public var noMembers: String = String(localized: "alert.message.noMembers", bundle: .module)
    
    public var maxSize: String = String(localized: "attachment.maxSize.title", bundle: .module)
    public var maxSizeHint: String = String(localized: "attachment.maxSize.hint", bundle: .module)
    public var fileTitle: String  = String(localized: "attachment.title.file", bundle: .module)
    public var gif: String = String(localized: "attachment.title.gif", bundle: .module)
    
    public init() {}
}
