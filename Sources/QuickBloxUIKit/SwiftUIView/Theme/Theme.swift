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
}

public class Theme: ThemeProtocol {
    public var color: ThemeColorProtocol = ThemeColor()
    public var font: ThemeFontProtocol = ThemeFont()
    public var image: ThemeImageProtocol = ThemeImage()
    
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
}

public class ThemeFont: ThemeFontProtocol {
    public var headline: Font = .headline
    public var footnote: Font = .footnote.weight(.semibold)
    public var caption: Font = .caption
    public var caption2: Font = .caption2
    public var callout: Font = .callout
    public var largeTitle: Font = .largeTitle
    public var title1: Font = .title.weight(.semibold)
    
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
    
    public init() {}
}
