//
//  DialogListViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct DialogListToolbarContent: ToolbarContent {
    private var dialogListHeaderSettings = QuickBloxUIKit.settings.dialogsScreen.header
    
    let onDismiss: () -> Void
    let onTapDialogType: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void,
        onTapDialogType: @escaping () -> Void) {
            self.onDismiss = onDismiss
            self.onTapDialogType = onTapDialogType
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if dialogListHeaderSettings.leftButton.hidden == false {
                Button {
                    onDismiss()
                } label: {
                    if let title = dialogListHeaderSettings.leftButton.title {
                        Text(title).foregroundColor(dialogListHeaderSettings.leftButton.color)
                    } else {
                        dialogListHeaderSettings.leftButton.image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(dialogListHeaderSettings.leftButton.scale)
                            .tint(dialogListHeaderSettings.leftButton.color)
                            .padding(dialogListHeaderSettings.leftButton.padding)
                    }
                }.frame(width: 32, height: 44)
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(dialogListHeaderSettings.title.text)
                .font(dialogListHeaderSettings.title.font)
                .foregroundColor(dialogListHeaderSettings.title.color)
        }
        
        if dialogListHeaderSettings.rightButton.hidden == false {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onTapDialogType()
                } label: {
                    if let title = dialogListHeaderSettings.rightButton.title {
                        Text(title).foregroundColor(dialogListHeaderSettings.rightButton.color)
                    } else {
                        dialogListHeaderSettings.rightButton.image
                            .resizable()
                            .scaledToFit()
                            .tint(dialogListHeaderSettings.rightButton.color)
                    }
                }
            }
        }
    }
}

public struct DialogListHeader: ViewModifier {
    
    private var settings = QuickBloxUIKit.settings.dialogsScreen.header
    
    let onDismiss: () -> Void
    let onTapDialogType: () -> Void
    
    public init(onDismiss: @escaping () -> Void,
                onTapDialogType: @escaping () -> Void
    ) {
        self.onDismiss = onDismiss
        self.onTapDialogType = onTapDialogType
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogListToolbarContent(onDismiss: onDismiss,
                                                 onTapDialogType: onTapDialogType)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarRole(.editor)
    }
}

public extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

public var isIphone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}

public var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

public struct DeleteDialogAlert: ViewModifier {
    public var settings = QuickBloxUIKit.settings.membersScreen.removeUser
    
    @Binding var isPresented: Bool
    var name: String
    let onCancel: () -> Void
    let onTap: () -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .alert(settings.alertTitle(name), isPresented: $isPresented) {
                    Button(settings.cancel, role: .cancel, action: {
                        onCancel()
                        isPresented = false
                    })
                    Button(settings.remove, role: .destructive, action: {
                        onTap()
                        isPresented = false
                    })
                } message: {
                    Text(settings.removeItem + name + " dialog?")
                }
        }
    }
}

extension View {
    func deleteDialogAlert(
        isPresented: Binding<Bool>,
        name: String,
        onCancel: @escaping () -> Void,
        onTap: @escaping () -> Void
    ) -> some View {
        self.modifier(RemoveUserAlert(isPresented: isPresented,
                                      name: name,
                                      onCancel: onCancel,
                                      onTap: onTap))
    }
}

struct CustomProgressView: View {
    let progressBar = QuickBloxUIKit.settings.dialogsScreen.progressBar
    
    var body: some View {
        ZStack {
            Color.black.frame(width: 100, height: 100)
                .cornerRadius(12)
                .opacity(0.6)
            
            SegmentedCircularBar(settings: progressBar)
        }
    }
}

struct Separator: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen.dialogRow
    
    var isLastRow: Bool
    var body: some View {
        VStack {
            Spacer()
            HStack() {
                Spacer(minLength: isLastRow == false ? settings.separatorInset: 0.0)
                Rectangle()
                    .fill(settings.dividerColor.opacity(0.4))
                    .frame(height: 1.0, alignment: .trailing)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct EmptyDialogsView: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen
    
    var body: some View {
        Spacer()
        VStack(spacing: 16.0) {
            settings.messageImage
                .resizable()
                .scaledToFit()
                .foregroundColor(settings.messageImageColor)
                .frame(width: 60, height: 60)
            Text(settings.itemsIsEmpty)
                .font(settings.itemsIsEmptyFont)
                .foregroundColor(settings.itemsIsEmptyColor)
            
        }
        Spacer()
    }
}

struct EmptyDialogView: View {
    let settings = QuickBloxUIKit.settings.dialogsScreen
    let dialogSettings = QuickBloxUIKit.settings.dialogScreen
    
    var body: some View {
        ZStack {
            dialogSettings.contentBackgroundColor.ignoresSafeArea()
            if dialogSettings.backgroundImage != nil {
                dialogSettings.backgroundImage?
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(dialogSettings.backgroundImageColor)
                    .opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
            }
            
            Text(settings.selectDialog)
                .font(settings.itemsIsEmptyFont)
                .foregroundColor(settings.itemsIsEmptyColor)
        }
    }
}

public extension View {
    func addKeyboardVisibilityToEnvironment() -> some View {
        modifier(KeyboardVisibility())
    }
}

private struct KeyboardShowingEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var keyboardShowing: Bool {
        get { self[KeyboardShowingEnvironmentKey.self] }
        set { self[KeyboardShowingEnvironmentKey.self] = newValue }
    }
}

import Combine
private struct KeyboardVisibility:ViewModifier {
    
    @State var isKeyboardShowing:Bool = false
    
    private var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    fileprivate func body(content: Content) -> some View {
        content
            .environment(\.keyboardShowing, isKeyboardShowing)
            .onReceive(keyboardPublisher) { value in
                isKeyboardShowing = value
            }
    }
    
}
