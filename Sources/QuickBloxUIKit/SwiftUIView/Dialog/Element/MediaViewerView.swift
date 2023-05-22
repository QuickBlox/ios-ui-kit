//
//  MediaViewerView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 08.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import AVKit

public struct MediaViewerView: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogScreen.zoomedImage
    
    @Binding var isImagePresented: Bool
    var image: Image?
    var url: URL?
    @State private var scale: CGFloat = 1
    let onSave: () -> Void
    let onDismiss: () -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .fullScreenCover(isPresented: $isImagePresented) {
                    ZStack {
                        settings.backgroundColor.ignoresSafeArea(.all)
                        VStack {
                            MediaViewerHeaderView(title: "") {
                                isImagePresented = false
                                onDismiss()
                            } onSave: {
                                onSave()
                            }
                            
                            Spacer()
                            
                            if let url {
                                VideoPlayer(player: AVPlayer(url: url)) {
                                    VStack {
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                            } else if let image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .zooming(scale: $scale)
                            }
                            
                            Spacer()
                        }
                    }
                }
            
        }
    }
}

extension View {
    func mediaViewerView(
        isImagePresented: Binding<Bool>,
        image: Image?,
        url: URL?,
        onSave: @escaping () -> Void,
        onDismiss: @escaping () -> Void) -> some View {
            self.modifier(MediaViewerView(isImagePresented: isImagePresented,
                                          image: image,
                                          url: url,
                                          onSave: onSave,
                                          onDismiss: onDismiss))
        }
}

public struct MediaViewerHeaderView: View {
    public var settings = QuickBloxUIKit.settings.dialogScreen.zoomedImage
    
    let title: String
    let onDismiss: () -> Void
    let onSave: () -> Void
    
    public var body: some View {
        ZStack {
            HStack {
                Button {
                    onDismiss()
                } label: {
                    if let title = settings.leftButton.title {
                        Text(title).foregroundColor(settings.leftButton.color)
                    } else {
                        settings.leftButton.image.tint(settings.leftButton.color)
                    }
                }.padding(.leading)
                
                Spacer()
                
                Text(title)
                    .font(settings.title.font)
                    .foregroundColor(settings.title.color)
                
                Spacer()
                
                Button {
                    onSave()
                } label: {
                    if let title = settings.rightButton.title {
                        Text(title).foregroundColor(settings.rightButton.color)
                    } else {
                        settings.rightButton.image.tint(settings.rightButton.color)
                    }
                }.padding(.trailing)
            }
        }
        .frame(height: settings.height)
        .background(settings.backgroundColor)
    }
}

class ZoomImageView: UIView {
    let min: CGFloat
    let max: CGFloat
    let offsetUpdate: (CGSize) -> Void
    let anchorUpdate: (UnitPoint) -> Void
    let scaleUpdate: (CGFloat) -> Void
    
    
    private var scale: CGFloat = 1 {
        didSet {
            scaleUpdate(scale)
        }
    }
    private var anchor: UnitPoint = .center {
        didSet {
            anchorUpdate(anchor)
        }
    }
    private var offset: CGSize = .zero {
        didSet {
            offsetUpdate(offset)
        }
    }
    
    private var pinching: Bool = false
    private var start: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0
    
    private var prev: CGFloat = 0
    
    init(min: CGFloat,
         max: CGFloat,
         offsetUpdate: @escaping (CGSize) -> Void,
         anchorUpdate: @escaping (UnitPoint) -> Void,
         scaleUpdate: @escaping (CGFloat) -> Void
         ) {
        self.min = min
        self.max = max
        self.offsetUpdate = offsetUpdate
        self.anchorUpdate = anchorUpdate
        self.scaleUpdate = scaleUpdate
      
        super.init(frame: .zero)
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gestureRecognizer:)))
        pinchGestureRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(pinchGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pinch(gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            pinching = true
            start = gestureRecognizer.location(in: self)
            anchor = UnitPoint(x: start.x / bounds.width, y: start.y / bounds.height)
            numberOfTouches = gestureRecognizer.numberOfTouches
            prev = scale
        case .changed:
            if gestureRecognizer.numberOfTouches != numberOfTouches {
                let new = gestureRecognizer.location(in: self)
                let diff = CGSize(width: new.x - location.x, height: new.y - location.y)
                start = CGPoint(x: start.x + diff.width, y: start.y + diff.height)
                numberOfTouches = gestureRecognizer.numberOfTouches
            }
            scale = clamping(prev * gestureRecognizer.scale, min, max)
            location = gestureRecognizer.location(in: self)
            offset = CGSize(width: location.x - start.x, height: location.y - start.y)
        case .possible, .cancelled, .failed:
            pinching = false
            scale = 1.0
            anchor = .center
            offset = .zero
        case .ended:
            pinching = false
        @unknown default:
            break
        }
    }
}

struct ZoomImageOverlay: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    @Binding var offset: CGSize
    let min: CGFloat
    let max: CGFloat
    
    func makeUIView(context: Context) -> ZoomImageView {
        let uiView = ZoomImageView(min: min,
                                   max: max,
                                   offsetUpdate: { offset = $0 },
                                   anchorUpdate: { anchor = $0 },
                                   scaleUpdate: { scale = $0 })
        return uiView
    }
    
    func updateUIView(_ uiView: ZoomImageView, context: Context) { }
}

struct ZoomImage: ViewModifier {
    @Binding var scale: CGFloat
    @State private var anchor: UnitPoint = .center
    @State private var offset: CGSize = .zero
    let min: CGFloat
    let max: CGFloat
    
    init(scale: Binding<CGFloat>,
         min: CGFloat,
         max: CGFloat) {
        _scale = scale
        self.min = min
        self.max = max
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .animation(.spring(), value: 1) // looks more natural
            .overlay(ZoomImageOverlay(scale: $scale,
                                     anchor: $anchor,
                                     offset: $offset,
                                     min: min,
                                     max: max))
            .gesture(TapGesture(count: 2).onEnded {
                if scale != 1 { // reset the scale
                    scale = clamping(1, min, max)
                    anchor = .center
                    offset = .zero
                } else { // quick zoom
                    scale = clamping(2, min, max)
                }
            })
    }
}

extension View {
    func zooming(scale: Binding<CGFloat>,
                  min: CGFloat = 0.5,
                  max: CGFloat = 2) -> some View {
        modifier(ZoomImage(scale: scale, min: min, max: max))
    }
}

func clamping(_ value: CGFloat, _ minValue: CGFloat, _ maxValue: CGFloat) -> CGFloat {
    min(maxValue, max(minValue, value))
}
