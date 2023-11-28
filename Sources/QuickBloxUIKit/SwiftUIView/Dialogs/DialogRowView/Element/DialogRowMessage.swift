//
//  DialogRowdialog.lastMessage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import QuickBloxLog

public struct DialogRowMessage {
    let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.lastMessage
    let features = QuickBloxUIKit.feature
    
    public var dialog: any DialogEntity
    public var font: Font? = nil
    public var foregroundColor: Color? = nil
    public var isHidden: Bool
    
    @State public var fileTuple: (name: String, image: Image?, placeholder: Image)? = nil
}

extension DialogRowMessage: View {
    public var body: some View {
        if isHidden == true {
            EmptyView()
        } else {
            contentView()
                .task {
                    do { fileTuple = try await dialog.attachment(size: settings.size)} catch { prettyLog(error)}
                }
        }
    }
    
    @ViewBuilder
    func contentView() -> some View {
        
        if dialog.lastMessage.text.contains("[Attachment]") {
            HStack(alignment: .center) {
                if let image = fileTuple?.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: settings.size.width, height: settings.size.height)
                        .cornerRadius(settings.imageCornerRadius)
                } else {
                    ZStack {
                        settings.placeholderBackground
                            .frame(width: settings.size.width,
                                   height: settings.size.height)
                            .cornerRadius(settings.imageCornerRadius)
                        
                        attachmentPlaceholder(dialog.lastMessage.text)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(settings.placeholderForeground)
                            .scaledToFit()
                            .frame(width: settings.placeholderSize.width,
                                   height: settings.placeholderSize.height)
                    }
                }
                
                Text(fileTuple?.name ?? "file")
                    .foregroundColor(foregroundColor ?? settings.foregroundColor)
                    .font(font ?? settings.font)
            }
        } else {
            HStack() {
                Text(dialog.lastMessage.text != features.forward.forwardedMessageKey ? dialog.lastMessage.text : features.forward.forwardedMessage)
                    .foregroundColor(foregroundColor ?? settings.foregroundColor)
                    .font(font ?? settings.font)
            }.frame(height: settings.size.height, alignment: .top)
        }
    }
    
    private func attachmentPlaceholder(_ info: String) -> Image {
        let strArray: [String] = info.components(separatedBy: "|")
        guard let mimeType = strArray.last else { return settings.filePlaceholder }
        let type = FileExtension(mimeType: mimeType).type
        return type.attachmentPlaceholder
    }
}



extension FileType {
    var attachmentPlaceholder: Image {
        let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow.lastMessage
        
        switch self {
        case .audio: return settings.audioPlaceholder
        case .video: return settings.videoPlaceholder
        case .image: return settings.imagePlaceholder
        case .file: return settings.filePlaceholder
        }
    }
}

extension DialogRowView {
    func message(_ dialog: Dialog = Dialog(type: .group),
                 font: Font? = nil,
                 foregroundColor: Color? = nil,
                 isHidden: Bool = false) -> Self {
        var row = Self.init(self)
        row.messageView = DialogRowMessage(dialog: dialog,
                                           font: font,
                                           foregroundColor: foregroundColor,
                                           isHidden: isHidden)
        return row
    }
}

struct DialogRowMessage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DialogRowMessage(dialog: PreviewModel.groupDialog, isHidden: false, fileTuple: nil)
        }.previewLayout(.fixed(width: 375, height: 32))
    }
}
