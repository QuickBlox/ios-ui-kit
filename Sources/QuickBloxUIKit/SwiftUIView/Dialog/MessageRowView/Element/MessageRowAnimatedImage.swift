//
//  MessageRowAnimatedImage.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 24.01.2025.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct MessageRowAnimatedImage: UIViewRepresentable {
    let image: UIImage?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = image
    }
}
