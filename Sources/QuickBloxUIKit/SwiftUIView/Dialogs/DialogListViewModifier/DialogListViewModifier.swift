//
//  DialogListViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 13.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct DialogListViewModifierToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogsScreen.header
    
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
            if settings.leftButton.hidden == false {
                Button {
                    onDismiss()
                } label: {
                    if let title = settings.leftButton.title {
                        Text(title).foregroundColor(settings.leftButton.color)
                    } else {
                        settings.leftButton.image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(settings.leftButton.scale)
                            .tint(settings.leftButton.color)
                            .padding(settings.leftButton.padding)
                    }
                }.frame(width: 32, height: 44)
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(settings.title.text)
                .font(settings.title.font)
                .foregroundColor(settings.title.color)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapDialogType()
            } label: {
                if let title = settings.rightButton.title {
                    Text(title).foregroundColor(settings.rightButton.color)
                } else {
                    settings.rightButton.image
                        .resizable()
                        .scaledToFit()
                        .tint(settings.rightButton.color)
                }
            }
        }
    }
}

public struct DialogListViewModifier: ViewModifier {
    
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
            DialogListViewModifierToolbarContent(onDismiss: onDismiss,
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

public struct TabIndex: Hashable {
    public var title: String
    public var systemIcon: String
    
    public init(title: String, systemIcon: String) {
        self.title = title
        self.systemIcon = systemIcon
    }
}

public extension TabIndex {
    static let dialogs = TabIndex(title: "Dialogs",
                                  systemIcon: "message.fill")
    static let settings = TabIndex(title: "Settings",
                                   systemIcon: "gearshape.fill")
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
