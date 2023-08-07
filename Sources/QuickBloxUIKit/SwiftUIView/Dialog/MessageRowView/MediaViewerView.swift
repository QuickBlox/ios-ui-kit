//
//  MediaViewerView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 08.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import AVKit
import UIKit

public struct MediaViewerView: ViewModifier {
    public var settings = QuickBloxUIKit.settings.dialogScreen.zoomedImage
    
    @Binding var isImagePresented: Bool
    var image: UIImage?
    var url: URL?
    @State private var scale: CGFloat = 1
    let onDismiss: () -> Void
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .fullScreenCover(isPresented: $isImagePresented) {
                    ZStack {
                        settings.backgroundColor.ignoresSafeArea(.all)
                        VStack {
                            MediaViewerHeaderView(title: "", onDismiss: {
                                isImagePresented = false
                                onDismiss()
                            }, image: image, url: url)
                            
                            Spacer()
                            
                            if let url {
                                VideoPlayer(player: AVPlayer(url: url)) {
                                    VStack {
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                            } else if let image {
                                Image(uiImage: image)
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
        image: UIImage?,
        url: URL?,
        onDismiss: @escaping () -> Void) -> some View {
            self.modifier(MediaViewerView(isImagePresented: isImagePresented,
                                          image: image,
                                          url: url,
                                          onDismiss: onDismiss))
        }
}

import Combine

public struct MediaViewerHeaderView: View {
    public var settings = QuickBloxUIKit.settings.dialogScreen.zoomedImage
    
    let title: String
    let onDismiss: () -> Void
    let image: UIImage?
    let url: URL?
    
    @State private var isInfoAlertPresented = false
    @State private var isSavedAlertPresented = false
    
    @StateObject private var saver = MediaSaverProvider()
    
    public var body: some View {
        ZStack {
            HStack {
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
                            .frame(width: settings.leftButton.imageSize?.width,
                                   height: settings.leftButton.imageSize?.height)
                    }
                }.padding(.leading)
                
                Spacer()
                
                Text(title)
                    .font(settings.title.font)
                    .foregroundColor(settings.title.color)
                
                Spacer()
                
                Button {
                    isInfoAlertPresented = true
                } label: {
                    if let title = settings.rightButton.title {
                        Text(title).foregroundColor(settings.rightButton.color)
                    } else {
                        settings.rightButton.image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(settings.rightButton.scale)
                            .tint(settings.rightButton.color)
                            .padding(settings.rightButton.padding)
                            .frame(width: settings.rightButton.imageSize?.width,
                                   height: settings.rightButton.imageSize?.height)
                    }
                }.padding(.trailing)
            }
        }
        .frame(height: settings.height)
        .background(settings.backgroundColor)
        
        .alert("", isPresented: $isInfoAlertPresented) {
            Button("Cancel", action: {
                isInfoAlertPresented = false
            })
            Button("Save", action: {
                if let image {
                    saver.write(image: image)
                } else if let url {
                    saver.write(video: url)
                }
            })
        } message: {
            if image != nil {
                Text( "Are you sure you want to save that image on your phone?")
            } else if url != nil {
                Text( "Are you sure you want to save that video on your phone?")
            }
            
        }
        
        .alert("", isPresented: $isSavedAlertPresented) {
            Button("Ok", action: {
                isSavedAlertPresented = false
            })
        } message: {
            Text(saver.completedMessage)
        }
        
        .onChange(of: saver.completedMessage, perform: { newValue in
            if newValue.isEmpty == false {
                isSavedAlertPresented = true
            }
        })
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
    
    func updateUIView(_ uiView: ZoomImageView, context: Context) {}
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

class MediaSaverProvider: NSObject, ObservableObject {
    
    @Published public var completedMessage = ""
    
    func write(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageCompleted), nil)
    }
    
    @objc func saveImageCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            completedMessage = error.localizedDescription
            return
        }
        
        completedMessage = "Save finished!"
    }
    
    func write(video: URL) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(video.relativePath) == true {
            UISaveVideoAtPathToSavedPhotosAlbum(video.relativePath, self, #selector(saveVideoCompleted), nil)
        }
    }
    
    @objc func saveVideoCompleted(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            completedMessage = error.localizedDescription
            return
        }
        
        completedMessage = "Save finished!"
    }
}
