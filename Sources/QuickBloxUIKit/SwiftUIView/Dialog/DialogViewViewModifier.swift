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
    
    var dialog: any DialogEntity
    let onDismiss: () -> Void
    let onTapInfo: () -> Void
    
    @State var avatar: Image? = nil
    
    public init(
        dialog: any DialogEntity,
        onDismiss: @escaping () -> Void,
        onTapInfo: @escaping () -> Void
        ) {
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
                    settings.leftButton.image
                        .resizable()
                        .scaleEffect(settings.leftButton.scale)
                        .tint(settings.leftButton.color)
                        .padding(settings.leftButton.padding)
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            HStack(spacing: 8.0) {
                AvatarView(image: avatar ?? dialog.placeholder,
                           height: settings.title.avatarHeight,
                           isHidden: settings.title.isHiddenAvatar)
                .task {
                    do { avatar = try await dialog.avatar } catch { prettyLog(error) }
                }
                
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
                    settings.rightButton.image
                        .resizable()
                        .scaleEffect(settings.rightButton.scale)
                        .tint(settings.rightButton.color)
                        .padding(settings.rightButton.padding)
                }
            }
        }
    }
}

public struct DialogHeader: ViewModifier {
    private var settings = QuickBloxUIKit.settings.dialogScreen.header
    
    var dialog: any DialogEntity
    let onDismiss: () -> Void
    let onTapInfo: () -> Void
    
    public init(
        dialog: any DialogEntity,
        onDismiss: @escaping () -> Void,
        onTapInfo: @escaping () -> Void
        ) {
            self.dialog = dialog
            self.onDismiss = onDismiss
            self.onTapInfo = onTapInfo
        }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogHeaderToolbarContent(dialog: dialog,
                                       onDismiss: onDismiss,
                                       onTapInfo: onTapInfo)
        }
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
    }
}

public struct TypingView: View {
    let settings = QuickBloxUIKit.settings.dialogScreen
    var typing: String
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(typing)
                    .font(settings.typing.font)
                    .foregroundColor(settings.typing.color)
                    .lineLimit(1)
                
                Spacer()
            }.padding([.leading, .trailing], 8)
            
            Spacer()
        }
        .frame(height: settings.typing.height)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 8)
    }
}

public struct MessagesScrollView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder builder: @escaping ()-> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                    content
                }
                .frame(minWidth: proxy.size.width)
                .frame(minHeight: proxy.size.height)
            }
        }
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
    
    func makeAttributedString(_ color: Color,
                              linkColor: Color,
                              linkFont: Font,
                              underline: Bool) -> AttributedString {
        var attributedString = AttributedString(self)
        attributedString.foregroundColor = color
        let matches = checkMatches()
        
        for match in matches {
            guard let rangeURL = Range(match.range, in: self),
                  let range = Range(match.range, in: attributedString),
                  let url = URL(string: String(self[rangeURL])) else { continue }
            attributedString[range].link = url.corrected
            attributedString[range].foregroundColor = linkColor
            attributedString[range].font = linkFont
            if underline == true {
                attributedString[range].underlineStyle = Text.LineStyle(
                    pattern: .solid, color: linkColor)
            }
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

struct ActivityViewController: UIViewControllerRepresentable {
var activityItems: [Any]
var applicationActivities: [UIActivity]? = nil

func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
    let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    return controller
}

func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
