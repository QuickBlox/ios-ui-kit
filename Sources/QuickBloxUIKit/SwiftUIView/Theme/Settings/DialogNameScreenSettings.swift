//
//  DialogNameScreenSettings.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

public class DialogNameScreenSettings {
    public var header: DialogNameHeaderSettings
    public var backgroundColor: Color
    public var avatarCamera: Image
    public var blurRadius: CGFloat = 12.0
    public var dividerColor: Color
    public var height: CGFloat = 56.0
    public var spacing: CGFloat = 16.0
    public var hint: HintSettings
    public var textfieldPrompt: String
    public var mediaAlert: MediaAlert
    public var avatarSize: CGSize = CGSize(width: 80.0, height: 80.0)
    public var isHiddenFiles: Bool = true
    public var maximumMB: Double = 10
    
    public init(_ theme: ThemeProtocol) {
        self.header = DialogNameHeaderSettings(theme)
        self.mediaAlert = MediaAlert(theme)
        self.backgroundColor = theme.color.mainBackground
        self.avatarCamera = theme.image.avatarCamera
        self.dividerColor = theme.color.divider
        self.hint = HintSettings(theme)
        self.textfieldPrompt = theme.string.enterName
    }
}

public struct HintSettings {
    public var text: String
    public var color: Color
    public var font: Font
    
    init(_ theme: ThemeProtocol) {
        self.font = theme.font.caption
        self.color = theme.color.secondaryElements.opacity(0.4)
        self.text = theme.string.nameHint
    }
}

public struct MediaAlert {
    public var title: String
    public var removePhoto: String
    public var camera: String
    public var gallery: String
    public var cancel: String
    public var file: String
    public var changeImage: String
    public var changeDialogName: String
    public var galleryMediaTypes: [String] = [UTType.movie.identifier, UTType.image.identifier]
    public var fileMediaTypes: [UTType] = [.jpeg, .png, .heic, .heif, .gif, .webP, .mpeg4Movie, .mpeg4Audio, .aiff, .wav, .webArchive, .mp3, .pdf, .image, .video, .movie, .audio, .data, .diskImage, .zip]
    public var blurRadius:CGFloat = 12.0
    
    public var iPadBackgroundColor: Color
    public var iPadForegroundColor: Color
    public var iPadImageColor: Color
    public var shadowColor: Color
    public var buttonSize: CGSize = CGSize(width: 260, height: 56)
    public var cornerRadius: CGFloat = 14.0
    public var removePhotoColor: Color
    
    public var imageClose: Image
    public var imageCamera: Image
    public var imageGallery: Image
    public var imageFile: Image
    
    public init(_ theme: ThemeProtocol) {
        self.title = theme.string.photo
        self.removePhoto = theme.string.removePhoto
        self.camera = theme.string.camera
        self.gallery = theme.string.gallery
        self.file = theme.string.file
        self.cancel = theme.string.cancel
        self.changeImage = theme.string.changeImage
        self.changeDialogName = theme.string.changeDialogName
        self.iPadBackgroundColor = theme.color.secondaryBackground
        self.iPadForegroundColor = theme.color.mainText
        self.iPadImageColor = theme.color.mainElements
        self.imageClose = theme.image.close
        self.imageCamera = theme.image.camera
        self.imageGallery = theme.image.photo
        self.imageFile = theme.image.doctext
        self.removePhotoColor = theme.color.error
        self.shadowColor = Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(theme.color.secondaryBackground)
            : UIColor(theme.color.disabledElements)
        }).opacity(0.6)
    }
}

public struct DialogNameHeaderSettings: HeaderSettingsProtocol {
    public var leftButton: ButtonSettingsProtocol
    public var title: HeaderTitleSettingsProtocol
    public var rightButton: ButtonSettingsProtocol
    
    public var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    public var backgroundColor: Color
    public var opacity: CGFloat = 0.4
    public var isHidden: Bool = false
    
    public init(_ theme: ThemeProtocol) {
        self.backgroundColor = theme.color.mainBackground
        self.leftButton = CancelButton(theme)
        self.title = DialogsTitle(theme)
        self.rightButton = CreateButton(theme)
    }
    
    public struct CreateButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String?
        public var image: Image
        public var color: Color
        public var scale: Double = 1.0
        public var padding: EdgeInsets = EdgeInsets(top: 0.0,
                                                    leading: 0.0,
                                                    bottom: 0.0,
                                                    trailing: 0.0)
        
        public init(_ theme: ThemeProtocol) {
            self.image = theme.image.newChat
            self.color = theme.color.mainElements
            self.title = theme.string.next
        }
    }
    
    public struct DialogsTitle: HeaderTitleSettingsProtocol {
        public var text: String
        public var color: Color
        public var font: Font
        public var avatarHeight: CGFloat = 0.0
        public var isHiddenAvatar: Bool = true
        
        public init(_ theme: ThemeProtocol) {
            self.font = theme.font.headline
            self.color = theme.color.mainText
            self.text = theme.string.newDialog
        }
    }
    
    public struct CancelButton: ButtonSettingsProtocol {
        public var imageSize: CGSize?
        public var frame: CGSize?
        
        public var title: String?
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
            self.title = theme.string.cancel
        }
    }
}
