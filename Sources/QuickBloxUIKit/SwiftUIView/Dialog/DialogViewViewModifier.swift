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
import QuickLook

struct DialogHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.dialogScreen.header
    
    var dialog: any DialogEntity
    var isForward: Bool = false
    var selectedCount: Int
    let onDismiss: () -> Void
    let onTapInfo: () -> Void
    let onTapCancel: () -> Void
    
    @State var avatar: Image? = nil
    
    public init(
        dialog: any DialogEntity,
        isForward: Bool,
        selectedCount: Int,
        onDismiss: @escaping () -> Void,
        onTapInfo: @escaping () -> Void,
        onTapCancel: @escaping () -> Void
    ) {
        self.dialog = dialog
        self.isForward = isForward
        self.selectedCount = selectedCount
        self.onDismiss = onDismiss
        self.onTapInfo = onTapInfo
        self.onTapCancel = onTapCancel
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if isForward == false {
                
                HStack(spacing: 0.0) {
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
            }
        }
        
        ToolbarItem(placement: .principal) {
            if isForward {
                Text("\(selectedCount)" + " " + settings.selectedMessages(selectedCount))
                    .font(settings.title.font)
                    .foregroundColor(settings.title.color)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                if isForward {
                    onTapCancel()
                } else {
                    onTapInfo()
                }
            } label: {
                if isForward {
                    Text(settings.cancelButton.title ?? "").foregroundColor(settings.rightButton.color)
                } else {
                    if let title = settings.rightButton.title {
                        Text(title).foregroundColor(settings.rightButton.color)
                    } else {
                        settings.rightButton.image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(settings.rightButton.scale)
                            .tint(settings.rightButton.color)
                            .padding(settings.rightButton.padding)
                    }
                }
            }.frame(width: 44, height: 44)
        }
    }
}

public struct DialogHeader: ViewModifier {
    private var settings = QuickBloxUIKit.settings.dialogScreen.header
    
    var dialog: any DialogEntity
    var isForward: Bool
    var selectedCount: Int
    let onDismiss: () -> Void
    let onTapInfo: () -> Void
    let onTapCancel: () -> Void
    
    public init(
        dialog: any DialogEntity,
        isForward: Bool,
        selectedCount: Int,
        onDismiss: @escaping () -> Void,
        onTapInfo: @escaping () -> Void,
        onTapCancel: @escaping () -> Void
    ) {
        self.dialog = dialog
        self.isForward = isForward
        self.selectedCount = selectedCount
        self.onDismiss = onDismiss
        self.onTapInfo = onTapInfo
        self.onTapCancel = onTapCancel
    }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            DialogHeaderToolbarContent(dialog: dialog,
                                       isForward: isForward,
                                       selectedCount: selectedCount,
                                       onDismiss: onDismiss,
                                       onTapInfo: onTapInfo,
                                       onTapCancel: onTapCancel)
        }
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)    }
}

public struct TypingView: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.typing
    var typing: String
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(typing)
                    .font(settings.font)
                    .foregroundColor(settings.color)
                    .lineLimit(1)
                
                Spacer()
            }.padding([.leading, .trailing], 8)
            
            Spacer()
        }
        .frame(height: settings.height)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 8)
    }
}

public struct MessagesScrollView<Content: View>: View {
    let settings = QuickBloxUIKit.settings.dialogScreen
    var content: Content
    
    init(@ViewBuilder builder: @escaping () -> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        List {
            content
                .flipContentVertical()
                .listRowSeparator(.hidden)
                .listRowSeparatorTint(.clear)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .flipContentVertical()
        .listStyle(.plain)
    }
}

public struct FlipContentVertical: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(180))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension View {
    func flipContentVertical() -> some View {
        self.modifier(FlipContentVertical())
    }
}

public struct BubbleCornerRadius: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct BubbleCornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius,
                                                        height: radius))
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
    var gesture = DragGesture().onChanged {_ in
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
    
    var link: URL? {
        let matches = checkMatches()
        for match in matches {
            guard let rangeURL = Range(match.range, in: self),
                  let url = URL(string: String(self[rangeURL])) else { continue }
            return url
        }
        return nil
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


struct FilePreviewController: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: context.coordinator,
            action: #selector(context.coordinator.dismiss)
        )
        
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
    
    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(previewController: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        let previewController: FilePreviewController
        
        init(previewController: FilePreviewController) {
            self.previewController = previewController
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            return previewController.url as NSURL
        }
        
        @objc func dismiss() {
            previewController.onDismiss()
        }
    }
}

open class StopWatchTimer: ObservableObject {
    @Published var counter: TimeInterval = 0
    
    var timer = Timer()
    
    func start() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                          repeats: true) { _ in
            self.counter += 1
        }
    }
    func stop() {
        self.timer.invalidate()
    }
    func reset() {
        self.counter = 0
        self.timer.invalidate()
    }
}

extension TimeInterval {
    func hours() -> String {
        return String(format: "%02d",  Int(self / 3600))
    }
    func minutes() -> String {
        return String(format: "%02d", Int(self / 60))
    }
    func seconds() -> String {
        return String(format: "%02d", Int(self) % 60)
    }
    func toString() -> String {
        return hours() + " : " + minutes() + " : " + seconds()
    }
    func audioString() -> String {
        if hours() != "00" {
            return hours() + " : " + minutes() + " : " + seconds()
        }
        return minutes() + " : " + seconds()
    }
}

extension View {
    func contentSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ContentSizePreferenceKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(ContentSizePreferenceKey.self, perform: onChange)
    }
}

struct ContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func customContextMenu<Preview: View> (
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [CustomContextMenuAction] = { [] }
    ) -> some View {
        modifier(
            PreviewContextViewModifier<Preview> (
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }}

struct PreviewContextViewModifier<Preview: View>: ViewModifier {
    
    @State private var isActive: Bool = false
    private let previewContent: Preview?
    private let preferredContentSize: CGSize?
    private let actions: [UIAction]
    
    init(        preview: Preview,
                 preferredContentSize: CGSize? = nil,
                 presentAsSheet: Bool = false,
                 @ButtonBuilder actions: () -> [CustomContextMenuAction] = { [] }
    ) {
        self.previewContent = preview
        self.preferredContentSize = preferredContentSize
        self.actions = actions().map(\.uiAction)
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        ZStack {
            content
                .overlay(
                    CustomPreviewContextMenuView(
                        preview: preview,
                        preferredContentSize: preferredContentSize,
                        actions: actions,
                        isActive: $isActive
                    )
                    .opacity(0.05)
                )
        }
    }
    
    @ViewBuilder
    private var preview: some View {
        if let preview = previewContent {
            preview
        }
    }
}

extension View {
    
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ conditional: Bool,
        @ViewBuilder if ifContent: (Self) -> TrueContent,
        @ViewBuilder else elseContent: (Self) -> FalseContent
    ) -> some View {
        if conditional {
            ifContent(self)
        } else {
            elseContent(self)
        }
    }
    
    @ViewBuilder
    func ifLet<Value, Content: View>(
        _ value: Value?,
        @ViewBuilder content: (Self, Value) -> Content
    ) -> some View {
        if let value = value {
            content(self, value)
        } else {
            self
        }
    }
}

struct CustomPreviewContextMenuView<Preview: View>: UIViewRepresentable {
    let preview: Preview?
    let preferredContentSize: CGSize?
    let actions: [UIAction]
    @Binding var isActive: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.addInteraction(
            UIContextMenuInteraction(
                delegate: context.coordinator
            )
        )
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
        
        private let view: CustomPreviewContextMenuView<Preview>
        
        init(_ view: CustomPreviewContextMenuView<Preview>) {
            self.view = view        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            configurationForMenuAtLocation location: CGPoint
        ) -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(
                identifier: nil,
                previewProvider: {
                    let hostingController = UIHostingController(rootView: self.view.preview)
                    if let preferredContentSize = self.view.preferredContentSize {
                        hostingController.preferredContentSize = preferredContentSize
                    }
                    return hostingController
                }, actionProvider: { _ in
                    UIMenu(title: "", children: self.view.actions)
                }
            )
        }
        
        func contextMenuInteraction(
            _ interaction: UIContextMenuInteraction,
            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
            animator: UIContextMenuInteractionCommitAnimating
        ) {
            view.isActive = true
        }
    }
}

struct CustomContextMenuAction {
    
    private let image: String?
    private let systemImage: String?
    private let attributes: UIMenuElement.Attributes
    private let action: (() -> ())?
    private let title: String
    
    init(
        title: String,
        attributes: UIMenuElement.Attributes?,
        action: @escaping () -> ()
    ) {
        self.init(title: title, image: nil, systemImage: nil, attributes: attributes ?? [], action: action)
    }
    
    init(
        title: String,
        systemImage: String,
        attributes: UIMenuElement.Attributes?,
        action: @escaping () -> ()
    ) {
        self.init(title: title, image: nil, systemImage: systemImage, attributes: attributes ?? [], action: action)
    }
    
    init(
        title: String,
        image: String,
        attributes: UIMenuElement.Attributes?,
        action: @escaping () -> ()
    ) {
        self.init(title: title, image: image, systemImage: nil, attributes: attributes ?? [], action: action)
    }
    
    private init(
        title: String,
        image: String?,
        systemImage: String?,
        attributes: UIMenuElement.Attributes,
        action: (() -> ())?
    ) {
        self.title = title
        self.image = image
        self.systemImage = systemImage
        self.attributes = attributes
        self.action = action
    }
    
    private var uiImage: UIImage? {
        if let image = image {
            return UIImage(named: image)
        } else if let systemImage = systemImage {
            return UIImage(systemName: systemImage)
        } else {
            return nil
        }
    }
    
    fileprivate var uiAction: UIAction {
        UIAction(
            title: title,
            image: uiImage,
            attributes: attributes) { _ in
                action?()
            }
    }
}

@resultBuilder
struct ButtonBuilder {
    public static func buildBlock(_ buttons: CustomContextMenuAction...) -> [CustomContextMenuAction] {
        buttons
    }
}
