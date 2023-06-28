//
//  DialogViewViewModifier.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 20.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxLog
import QuickBloxData
import QuickBloxDomain

struct DialogHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogScreen.header
    
    var avatar: Image?
    var dialog: any DialogEntity
    let onDismiss: () -> Void
    let onTapInfo: () -> Void
    
    public init(
        avatar: Image?,
        dialog: any DialogEntity,
        onDismiss: @escaping () -> Void,
        onTapInfo: @escaping () -> Void
        ) {
            self.avatar = avatar
            self.dialog = dialog
            self.onDismiss = onDismiss
            self.onTapInfo = onTapInfo
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onDismiss()
            } label: {
                if let title = settings.leftButton.title {
                    Text(title).foregroundColor(settings.leftButton.color)
                } else {
                    settings.leftButton.image.tint(settings.leftButton.color)
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            HStack(spacing: 8.0) {
                AvatarView(image: avatar ?? dialog.placeholder,
                           height: settings.title.avatarHeight,
                           isShow: settings.title.isShowAvatar)
                
                Text(dialog.name)
                    .font(settings.title.font)
                    .foregroundColor(settings.title.color)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onTapInfo()
            } label: {
                if let title = settings.rightButton.title {
                    Text(title).foregroundColor(settings.rightButton.color)
                } else {
                    settings.rightButton.image.tint(settings.rightButton.color)
                }
            }
        }
    }
}

public struct DialogHeader: ViewModifier {
    private var settings = QuickBloxUIKit.settings.createDialogScreen.header
    
    var dialog: any DialogEntity
    @Binding var avatar: Image?
    let onDismiss: () -> Void
    let onTapInfo: () -> Void
    
    public init(
        avatar: Binding<Image?>,
        dialog: any DialogEntity,
        onDismiss: @escaping () -> Void,
        onTapInfo: @escaping () -> Void
        ) {
            _avatar = avatar
            self.dialog = dialog
            self.onDismiss = onDismiss
            self.onTapInfo = onTapInfo
        }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogHeaderToolbarContent(avatar: avatar,
                                       dialog: dialog,
                                       onDismiss: onDismiss,
                                       onTapInfo: onTapInfo)
        }
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
    }
}


public struct BubbleCornerRadius: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct BubbleCornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    public func body(content: Content) -> some View {
        content
            .clipShape(BubbleCornerRadiusShape(radius: radius, corners: corners))
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: BubbleCornerRadius(radius: radius, corners: corners))
    }
}

public extension UIApplication {
    func endEditing(_ force: Bool) {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.first?.endEditing(force)
    }
}

public struct ResignKeyboardOnGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    public func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

public extension View {
    func resignKeyboardOnGesture() -> some View {
        return modifier(ResignKeyboardOnGesture())
    }
}

public extension String {
    var containtsLink: Bool {
        let matches = checkMatches()
        
        for match in matches {
            guard Range(match.range, in: self) != nil else { continue }
            return true
        }
        return false
    }
    
    func makeAttributedString(_ color: Color, linkColor: Color) -> AttributedString {
        var attributedString = AttributedString(self)
        attributedString.foregroundColor = color
        let matches = checkMatches()
        
        for match in matches {
            guard let rangeURL = Range(match.range, in: self),
                  let range = Range(match.range, in: attributedString),
                  let url = URL(string: String(self[rangeURL])) else { continue }
            attributedString[range].link = url.corrected
            attributedString[range].foregroundColor = linkColor
            attributedString[range].underlineStyle = Text.LineStyle(
                pattern: .solid, color: linkColor)
        }
        return attributedString
    }
    
    func checkMatches() -> [NSTextCheckingResult] {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        return detector.matches(in: self,
                                       options: [],
                                       range: NSRange(location: 0, length: self.utf16.count))
    }
}

public extension URL {
  var corrected: URL {
    if var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
      if components.scheme == nil {
        components.scheme = "http"
      }
      return components.url ?? self
    }
    return self
  }
}
