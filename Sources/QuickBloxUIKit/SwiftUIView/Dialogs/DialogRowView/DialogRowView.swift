//
//  DialogRowView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData
import QuickBloxLog

public protocol DialogRowView: View {
    var settings: DialogRowSettings { get set }
    
    var dialog: any DialogEntity { get set }
    
    var avatar: Image { get set }
    
    var nameView: DialogRowName? { get set }
    var badgeView: DialogRowBadge? { get set }
    var avatarView: AvatarView? { get set }
    var timeView: DialogRowTime? { get set }
    var messageView: DialogRowMessage? { get set }
    
    init(_ dialog: any DialogEntity)
}

extension DialogRowView {
    public init(_ dialog: any DialogEntity,
                settings: DialogRowSettings =
                QuickBloxUIKit.settings.dialogsScreen.dialogRow,
                nameView: DialogRowName? = nil,
                badgeView: DialogRowBadge? = nil,
                avatarView: AvatarView? = nil,
                timeView: DialogRowTime? = nil,
                messageView: DialogRowMessage? = nil) {
        self.init(dialog)
        
        self.nameView = nameView
        self.badgeView = badgeView
        self.avatarView = avatarView
        self.timeView = timeView
        self.messageView = messageView
        
        self.settings = settings
        switch dialog.type {
        case .public:
            self.avatar = settings.avatar.publicAvatar
        case .group:
            self.avatar = settings.avatar.groupAvatar
        case .private:
            self.avatar = settings.avatar.privateAvatar
        case .unknown:
            self.avatar = settings.avatar.privateAvatar
        }
    }
    
    public init(_ row: any DialogRowView) {
        self.init(row.dialog)
        
        self.settings = row.settings
        self.nameView = row.nameView
        self.badgeView = row.badgeView
        self.avatarView = row.avatarView
        self.timeView = row.timeView
        self.messageView = row.messageView
    }
}

extension DialogRowView {
    @ViewBuilder
    public var contentView: some View {
        HStack(spacing: settings.spacing) {
            (avatarView ?? AvatarView(image: avatar,
                                      height: settings.contentHeight,
                                      isHidden: settings.isHiddenAvatar))
            VStack(spacing: settings.infoSpacing) {
                HStack {
                    nameView ?? DialogRowName(text: dialog.validName)
                    settings.infoSpacer
                    timeView ?? DialogRowTime(time: dialog.time,
                                              isHidden: settings.isHiddenTime)
                }
                
                HStack {
                    if dialog.lastMessage.id.isEmpty == false {
                        messageView ?? DialogRowMessage(dialog: dialog,
                                                        isHidden: settings.isHiddenLastMessage)
                    }
                    
                    settings.infoSpacer
                    badgeView ?? DialogRowBadge(count: dialog.unreadMessagesCount)
                }
            }
            .padding([.bottom, .top], settings.infoSpacing)
        }
        .padding(settings.padding)
        .frame(height: settings.height)
        .id(dialog.id)
    }
}

public struct PrivateDialogRowView: DialogRowView  {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogsScreen.dialogRow.avatar.privateAvatar
    
    public var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    public var dialog: any DialogEntity
    
    public var badgeView: DialogRowBadge?
    public var nameView: DialogRowName?
    public var avatarView: AvatarView?
    public var timeView: DialogRowTime?
    public var messageView: DialogRowMessage?
    
    public init(_ dialog: any DialogEntity) {
        self.dialog = dialog
    }
    
    public var body: some View {
        contentView.task {
            do { avatar = try await dialog.avatar(scale: .avatar3x) } catch { prettyLog(error) }
        }
    }
}

public struct GroupDialogRowView: DialogRowView  {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogsScreen.dialogRow.avatar.groupAvatar
    
    public var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    public var dialog: any DialogEntity
    
    public var badgeView: DialogRowBadge?
    public var nameView: DialogRowName?
    public var avatarView: AvatarView?
    public var timeView: DialogRowTime?
    public var messageView: DialogRowMessage?
    
    public init(_ dialog: any DialogEntity) {
        self.dialog = dialog
    }
    
    public var body: some View {
        contentView.task {
            do { avatar = try await dialog.avatar(scale: .avatar3x) } catch { prettyLog(error) }
        }
    }
}

public struct PublicDialogRowView: DialogRowView  {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogsScreen.dialogRow.avatar.publicAvatar
    
    public var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    public var dialog: any DialogEntity
    
    public var badgeView: DialogRowBadge?
    public var nameView: DialogRowName?
    public var avatarView: AvatarView?
    public var timeView: DialogRowTime?
    public var messageView: DialogRowMessage?
    
    public init(_ dialog: any DialogEntity) {
        self.dialog = dialog
    }
    
    public var body: some View {
        contentView.task {
            do { avatar = try await dialog.avatar(scale: .avatar3x) } catch { prettyLog(error) }
        }
    }
}

public struct SelectDialogRowView: View {
    @State public var avatar: Image =
    QuickBloxUIKit.settings.dialogsScreen.dialogRow.avatar.privateAvatar
    
    public var settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    public var dialog: any DialogEntity
    
    public var badgeView: DialogRowBadge?
    public var nameView: DialogRowName?
    public var avatarView: AvatarView?
    
    private var isSelected = false
    public var onTap: (_ itemId: String) -> Void
    
    public init(_ dialog: any DialogEntity,
                isSelected: Bool,
                onTap: @escaping (_ itemId: String) -> Void) {
        self.dialog = dialog
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        HStack(spacing: settings.spacing) {
            avatarView ?? AvatarView(image: avatar,
                                     height: settings.selectAvatarSize.height,
                                     isHidden: settings.isHiddenAvatar )
            
            UserRowName(text: dialog.validName)
            Spacer()
            
            Checkbox(isSelected: isSelected) {
                onTap(dialog.id)
            }
        }
        .frame(height: settings.selectHeight)
        .padding(settings.selectPadding)
        .background(settings.backgroundColor)
        .task {
            do { avatar = try await dialog.avatar(scale: .avatar3x) } catch { prettyLog(error) }
        }
    }
}

//TODO: Developer must have an ability to set his own implementations for each type of dialog, also he can disable  specific dialog type. https://quickblox.atlassian.net/wiki/spaces/CLNT/pages/3676045315/UIKit+v0.1.0+SRS#Dialog-cell

public struct DialogsRowBuilder<DialogItem: DialogEntity> {
    @ViewBuilder
    public static func defaultRow(_ dialog: DialogItem) -> some View {
        switch dialog.type {
        case .private: PrivateDialogRowView(dialog)
        case .group: GroupDialogRowView(dialog)
        case .public: PublicDialogRowView(dialog)
        case .unknown: EmptyView()
        }
    }
}

extension DialogEntity {
    public var time: String {
        let stringUtils = QuickBloxUIKit.settings.dialogScreen.stringUtils
        
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date) == true {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDateInYesterday(date) == true {
            return stringUtils.yesterday
        } else if Calendar.autoupdatingCurrent.component(.year, from: date) ==
                  Calendar.autoupdatingCurrent.component(.year, from: Date()) {
            // is current year
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateStyle = .short
        }
        return formatter.string(from: date)
    }
    
    public var validName: String {
        let settings = QuickBloxUIKit.settings.dialogScreen.messageRow.name
        let regex = QuickBloxUIKit.feature.regex
        
        if type == .private && regex.userName.isEmpty == false {
            return name.isValid(regexes: [regex.userName]) == true ? name : settings.unknown
        }
        return name
    }
}

import QuickBloxData

struct PrivateDialogRowView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
//            DialogsRowBuilder.defaultRow(PreviewModel.privateDialog)

//            DialogsRowBuilder.defaultRow(PreviewModel.groupDialog)
//                .preferredColorScheme(.dark)

//            GroupDialogRowView(PreviewModel.longNameGroupDialog)
//                .previewSettings(scheme: .dark, name: "Long name")
//
//
//            PublicDialogRowView(PreviewModel.publicDialog)
//                .previewSettings(name: "Public")
//
//            PreviewRow(PreviewModel.publicDialog)
//                .name(foregroundColor: .red)
//                .badge(backgroundColor: .green)
//                .avatar(image: Image("attachmentPlaceholder", bundle: .module),
//                        height: 56.0,
//                        isHidden: true)
//                .time("last Year")
//                .previewSettings(name: "Custom")
//
//            PublicDialogRowView(PreviewModel.oldMessagePublicDialog)
//                .previewSettings(name: "Old Message")
//
//            PublicDialogRowView(PreviewModel.oldMessagePublicDialog)
//                .time(isHidden: false)
//                .previewSettings(name: "Without time")
//
//            PublicDialogRowView(PreviewModel.oldMessagePublicDialog)
//                .message(isHidden: false)
//                .previewSettings(name: "Without message")
//
//            PreviewRow(PreviewModel.publicDialog)
//                .name(foregroundColor: .red)
//                .badge(backgroundColor: .green)
//                .time(nil)
//                .avatar(image: Image("attachmentPlaceholder", bundle: .module),
//                        height: 56.0,
//                        isHidden: false)
//                .message(LastMessage())
//                .previewSettings(name: "Without optional")

        }.previewLayout(.fixed(width: 375, height: 76))
    }
}
