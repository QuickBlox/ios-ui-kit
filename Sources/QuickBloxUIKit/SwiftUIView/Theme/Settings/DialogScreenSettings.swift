//
//  DialogScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

private struct DialogScreenSettingsConstant {
    static let height: CGFloat = 56.0
    static let spacing: CGFloat = 16.0
    static let verticalPadding: CGFloat = 8.0
    static let checkboxHeight: CGFloat = 24.0
    static let lineWidth: CGFloat = 2.0
    static let spacer: CGFloat = 32.0
}

public class DialogScreenSettings {
    public var header: DialogHeaderSettings
    public var backgroundColor: Color
    public var contentBackgroundColor: Color
    public var messageRow: MessageRowSettings
    public var textField: MessageTextFieldSettings
    public var zoomedImage: ZoomedImageSettings
    public var typing: TypingSettings
    public var itemsIsEmpty: String
    public var blurRadius: CGFloat = 12.0
    public var maximumMB: Double = 10
    public var dividerToMB: Double = 1048576
    public var maxSize: String
    public var avatarSize: AvatarSizeSettings = AvatarSizeSettings()
    public var isHiddenFiles = false
    
    public init(_ theme: ThemeProtocol) {
        self.header = DialogHeaderSettings(theme)
        self.messageRow = MessageRowSettings(theme)
        self.textField = MessageTextFieldSettings(theme)
        self.zoomedImage = ZoomedImageSettings(theme)
        self.typing = TypingSettings(theme)
        self.backgroundColor = theme.color.mainBackground
        self.contentBackgroundColor = theme.color.secondaryBackground
        self.itemsIsEmpty = theme.string.messegesEmpty
        self.maxSize = theme.string.maxSize
    }
}

public struct AvatarSizeSettings {
    public var avatar1x: CGSize = CGSize(width: 32.0, height: 32.0)
    public var avatar2x: CGSize = CGSize(width: 56.0, height: 56.0)
    public var avatar3x: CGSize = CGSize(width: 80.0, height: 80.0)
}

public struct TypingSettings {
    public var typingOne: String
    public var typingTwo: String
    public var typingFour: String
    public var color: Color
    public var font: Font
    public var height: CGFloat = 31
    public var offset: CGFloat = 52.0
    public var enable: Bool = true
    
    public init(_ theme: ThemeProtocol) {
        self.font = theme.font.caption2
        self.color = theme.color.tertiaryElements
        self.typingOne = theme.string.typingOne
        self.typingTwo = theme.string.typingTwo
        self.typingFour = theme.string.typingFour
    }
}

public struct DialogHeaderSettings: HeaderSettingsProtocol {
    public var leftButton: ButtonSettingsProtocol
    public var title: HeaderTitleSettingsProtocol
    public var rightButton: ButtonSettingsProtocol
    public var displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    public var backgroundColor: Color
    public var opacity: CGFloat = 0.4
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogTitle(theme)
        self.rightButton = InfoButton(theme)
    }
    
    public struct InfoButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.info
            self.color = theme.color.mainElements
        }
    }
    
    public struct DialogTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 34.0
        public var isHiddenAvatar: Bool = false
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.dialog
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.mainElements
        }
    }
}

public struct ZoomedImageSettings {
    public var backgroundColor: Color
    public var leftButton: CancelButton
    public var title: ImageTitle
    public var rightButton: InfoButton
    public var height: CGFloat = 44
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = .black
        self.leftButton = CancelButton(theme)
        self.title = ImageTitle(theme)
        self.rightButton = InfoButton(theme)
    }
    
    public struct InfoButton: ButtonSettingsProtocol {
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        public var imageSize: CGSize? = CGSize(width: 18.0, height: 18.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.info
            self.color = theme.color.system
        }
    }
    
    public struct ImageTitle {
        public var color: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.system
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        public var imageSize: CGSize? = CGSize(width: 16.0, height: 18.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.back
            self.color = theme.color.system
        }
    }
}

public struct MessageRowSettings {
    public var avatar: MessageAvatarSettings
    public var name: MessageNameSettings
    public var time: MessageTimeSettings
    public var message: MessageSettings
    public var progressBar: ProgressBarSettings
    public var inboundForeground: Color
    public var inboundBackground: Color
    public var inboundFont: Font
    public var outboundForeground: Color
    public var outboundBackground: Color
    public var inboundCorners: UIRectCorner = [.topLeft, .topRight, .bottomRight]
    public var outboundCorners: UIRectCorner = [.bottomLeft, .topLeft , .topRight]
    public var inboundGroupCorners: UIRectCorner = [.topRight, .bottomRight]
    public var outboundGroupCorners: UIRectCorner = [.bottomLeft, .topLeft]
    public var outboundFont: Font
    public var waveImage: Image
    public var deliveredImage: Image
    public var readImage: Image
    public var sendImage: Image
    public var deliveredForeground: Color
    public var readForeground: Color
    public var sendForeground: Color
    public var play: Image
    public var pause: Image
    public var playForeground: Color
    public var outboundPlayForeground: Color
    public var videoPlayForeground: Color
    public var videoPlayBackground: Color
    public var file: Image
    public var fileTitle: String
    public var inboundFileForeground: Color
    public var inboundFileBackground: Color
    public var outboundFileForeground: Color
    public var outboundFileBackground: Color
    public var dateForeground: Color
    public var dateBackground: Color
    public var dateFont: Font
    public var infoForeground: Color
    public var infoFont: Font
    public var gifTitle: String
    public var gifFont: Font
    public var gifFontPlay: Font
    public var bubbleRadius: CGFloat = 22.0
    public var dateRadius: CGFloat = 10.0
    public var attachmentRadius: CGFloat = 8.0
    public var isHiddenAvatar: Bool = false
    public var isHiddenName: Bool = false
    public var isHiddenTime: Bool = false
    public var isHiddenStatus: Bool = false
    public var attachmentSize: CGSize = CGSize(width: 240.0, height: 160.0)
    public var imageSize: CGSize = CGSize(width: 336.0, height: 224.0)
    public var audioImageSize: CGSize = CGSize(width: 168.0, height: 12.0)
    public var audioPlaySize: CGSize = CGSize(width: 20.0, height: 20.0)
    public var imageIconSize: CGSize = CGSize(width: 44.0, height: 44.0)
    public var fileSize: CGSize = CGSize(width: 32.0, height: 32.0)
    public var fileIconSize: CGSize = CGSize(width: 15.0, height: 15.0)
    public var audioBubbleHeight: CGFloat = 44.0
    public var fileBubbleHeight: CGFloat = 48.0
    public var imageIcon: Image
    public var outboundImageIconForeground: Color
    public var inboundImageIconForeground: Color
    public var linkFont: Font
    public var linkUnderline: Bool = true
    public var outboundLinkForeground: Color
    public var inboundLinkForeground: Color
    public var inboundSpacer: CGFloat = DialogScreenSettingsConstant.spacer
    public var outboundSpacer: CGFloat = DialogScreenSettingsConstant.spacer
    public var spacing: CGFloat = 16.0
    public var messagePadding: EdgeInsets = EdgeInsets(top: 12,
                                                       leading: 16,
                                                       bottom: 12,
                                                       trailing: 16)
    
    public var audioPadding: EdgeInsets = EdgeInsets(top: 0,
                                                     leading: 20,
                                                     bottom: 0,
                                                     trailing: 16)
    
    public var datePadding: EdgeInsets = EdgeInsets(top: 2,
                                                    leading: 8,
                                                    bottom: 2,
                                                    trailing: 8)
    
    public var filePadding: EdgeInsets = EdgeInsets(top: 8,
                                                    leading: 16,
                                                    bottom: 8,
                                                    trailing: 16)
    
    public var inboundNamePadding: EdgeInsets = EdgeInsets(top: 18.0,
                                                           leading: 16.0,
                                                           bottom: 0.0,
                                                           trailing: 16.0)
    
    public func inboundPadding(showName: Bool) -> EdgeInsets {
        return EdgeInsets(top: showName == false ? 0.0 : 18,
                          leading: 0.0,
                          bottom: 0.0,
                          trailing: 0.0)
    }
    
    public func videoIconSize(isImage: Bool) -> CGSize {
        return isImage ? CGSize(width: 20.0, height: 20.0) : CGSize(width: 26.0, height: 26.0)
    }
    
    public var outboundPadding: EdgeInsets = EdgeInsets(top: 18.0,
                                                        leading: 0,
                                                        bottom: 0.0,
                                                        trailing: 16.0)
    public var outboundAudioPadding: EdgeInsets = EdgeInsets(top: 18.0,
                                                             leading: 0,
                                                             bottom: 0.0,
                                                             trailing: 16.0)
    
    public var infoSpacer = Spacer(minLength: 8.0)
    public var infoSpacing: CGFloat = 2.0
    
    public func progressBarBackground() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [Color(hex: 0x7D7D7A),
                                        Color(hex: 0xB3B6B5),
                                        Color(hex: 0x8E8D8D)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    public var robot: Image
    public var robotForeground: Color
    public var robotSize: CGSize = CGSize(width: 44.0, height: 36.0)
    
    public init(_ theme: ThemeProtocol) {
        self.avatar = MessageAvatarSettings(theme)
        self.name = MessageNameSettings(theme)
        self.time = MessageTimeSettings(theme)
        self.message = MessageSettings(theme)
        self.progressBar = ProgressBarSettings(theme)
        self.inboundBackground = theme.color.incomingBackground
        self.outboundBackground = theme.color.outgoingBackground
        self.inboundForeground = theme.color.mainText
        self.outboundForeground = theme.color.mainText
        self.dateForeground = theme.color.secondaryElements
        self.dateBackground = theme.color.inputBackground
        self.inboundFont = theme.font.callout
        self.outboundFont = theme.font.callout
        self.dateFont = theme.font.caption
        self.infoForeground = theme.color.tertiaryElements
        self.infoFont = theme.font.caption
        self.gifFont = theme.font.title1
        self.gifFontPlay = theme.font.headline
        self.waveImage = theme.image.wave
        self.play = theme.image.play
        self.pause = theme.image.pause
        self.playForeground = theme.color.mainElements
        self.videoPlayForeground = theme.color.system
        self.videoPlayBackground = theme.color.tertiaryBackground
        self.imageIcon = theme.image.photo
        self.outboundImageIconForeground = theme.color.secondaryElements
        self.inboundImageIconForeground = theme.color.tertiaryElements
        self.outboundPlayForeground = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.system)
            : UIColor(theme.color.mainElements)
        })
        self.deliveredImage = theme.image.delivered
        self.readImage = theme.image.delivered
        self.sendImage = theme.image.send
        self.deliveredForeground = theme.color.tertiaryElements
        self.readForeground = theme.color.mainElements
        self.sendForeground = theme.color.tertiaryElements
        self.fileTitle = theme.string.fileTitle
        self.file = theme.image.doctext
        self.gifTitle = theme.string.gif
        self.inboundFileForeground = theme.color.system
        self.inboundFileBackground = theme.color.tertiaryElements
        self.outboundFileForeground = theme.color.system
        self.outboundFileBackground = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.mainElements)
            : UIColor(theme.color.tertiaryElements)
        })
        self.linkFont = theme.font.callout
        self.inboundLinkForeground = theme.color.mainText
        self.outboundLinkForeground = theme.color.mainText
        
        self.robot = theme.image.robot
        self.robotForeground = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hexRGB: "#E7EFFF") ?? UIColor.white
            : UIColor(hexRGB: "#3978FC") ?? UIColor.blue
        })
    }
    
    public struct ProgressBarSettings {
        public var segments: Int = 8
        public var segmentColor: Color
        public var progressSegmentColor: Color
        public var lineWidth: CGFloat = 2.0
        public var rotationEffect: Angle = Angle(degrees: -90)
        public var emptySpaceAngle: Angle = Angle(degrees: 10)
        public var size: CGSize = CGSize(width: 40.0, height: 40.0)
        
        public init(_ theme: ThemeProtocol) {
            self.segmentColor = theme.color.system
            self.progressSegmentColor = theme.color.mainElements
        }
    }
    
    public struct MessageAvatarSettings {
        public var placeholder: Image
        public var height: CGFloat = 44.0
        
        public init(_ theme: ThemeProtocol) {
            self.placeholder = theme.image.avatarUser
        }
    }
    
    public struct MessageSettings {
        public var inboundForeground: Color
        public var outboundForeground: Color
        public var font: Font
        public var attachmentPlaceholder: Image
        public var size: CGSize = CGSize(width: 32.0, height: 32.0)
        public var imageCornerRadius = 8.0
        
        public init(_ theme: ThemeProtocol) {
            self.inboundForeground = theme.color.secondaryText
            self.outboundForeground = Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor(hexRGB: "#9CBCFE") ?? UIColor.white
                : UIColor(theme.color.secondaryText)
            })
            self.font = theme.font.callout
            self.attachmentPlaceholder = theme.image.attachmentPlaceholder
        }
    }
    
    public struct MessageTimeSettings {
        public var foregroundColor: Color
        public var font: Font
        public var format: String = ""
        public var bottom: CGFloat = 2.0
        public var formatter: Formatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm"
            return formatter
        }()
        
        public init(_ theme: ThemeProtocol) {
            self.foregroundColor = theme.color.secondaryText
            self.font = theme.font.caption2
        }
    }
    
    public struct MessageNameSettings {
        public var foregroundColor: Color
        public var font: Font
        
        public init(_ theme: ThemeProtocol) {
            self.foregroundColor = theme.color.tertiaryElements
            self.font = theme.font.caption
        }
    }
}

public struct MessageTextFieldSettings {
    public var placeholderText: String
    public var placeholderFont: Font
    public var placeholderColor: Color
    public var backgroundColor: Color
    public var leftButton: AttachmentButton
    public var rightButton: SendButton
    public var emojiButton: EmojiButton
    public var timer: RecordTimer
    public var barHeight: CGFloat = 56.0
    public var barColor: Color
    public var height: CGFloat = 36.0
    public var radius: CGFloat = 20.0
    public var padding: EdgeInsets = EdgeInsets(top: 7,
                                                leading: 16,
                                                bottom: 7,
                                                trailing: 16)
    
    public init(_ theme: ThemeProtocol) {
        self.placeholderText = theme.string.typeMessage
        self.placeholderColor = theme.color.secondaryText
        self.placeholderFont = theme.font.callout
        self.backgroundColor = theme.color.inputBackground
        self.leftButton = AttachmentButton(theme)
        self.rightButton = SendButton(theme)
        self.emojiButton = EmojiButton(theme)
        self.timer = RecordTimer(theme)
        self.barColor = theme.color.mainBackground
    }
    
    public struct RecordTimer {
        public var foregroundColor: Color
        public var font: Font
        public var image: Image
        public var imageColor: Color
        
        public init(_ theme: ThemeProtocol) {
            self.foregroundColor = theme.color.mainText
            self.font = theme.font.callout
            self.image = theme.image.record
            self.imageColor = theme.color.error
        }
    }
    
    public struct AttachmentButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        public var stopImage: Image
        public var stopColor: Color
        public var width: CGFloat = 44.0
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.paperclip
            self.color = theme.color.secondaryElements
            self.stopImage = theme.image.close
            self.stopColor = theme.color.secondaryElements
        }
    }
    
    public struct SendButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        public var micImage: Image
        public var micColor: Color
        public var width: CGFloat = 44.0
        public var degrees: Double = 45.0
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.paperplane
            self.color = theme.color.mainElements
            self.micImage = theme.image.mic
            self.micColor = theme.color.secondaryElements
        }
    }
    
    public struct EmojiButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String? = nil
        public var image: Image
        public var keyboardImage: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.smiley
            self.keyboardImage = theme.image.keyboard
            self.color = theme.color.secondaryElements
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init( .sRGB,
                   red: Double((hex >> 16) & 0xff) / 255,
                   green: Double((hex >> 08) & 0xff) / 255,
                   blue: Double((hex >> 00) & 0xff) / 255,
                   opacity: alpha )
    }
}
