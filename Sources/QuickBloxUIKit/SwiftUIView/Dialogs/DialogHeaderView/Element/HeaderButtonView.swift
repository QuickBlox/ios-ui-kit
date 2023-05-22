//
//  ButtonView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 30.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

public struct BackButton: View {
    
    let header = QuickBloxUIKit.settings.dialogsScreen.header
    
    public var onAction: () -> Void
    
    public init(onAction: @escaping () -> Void) {
        self.onAction = onAction
    }
    
    public var body: some View {
        Button {
            onAction()
        } label: {
            if let title = header.leftButton.title {
                Text(title).foregroundColor(header.leftButton.color)
            } else {
                header.leftButton.image.tint(header.leftButton.color)
            }
        }
    }
}

public struct CreateButton: View {
    
    let header = QuickBloxUIKit.settings.dialogsScreen.header
    
    public var onAction: () -> Void
    
    public init(onAction: @escaping () -> Void) {
        self.onAction = onAction
    }
    
    public var body: some View {
        Button {
            onAction()
        } label: {
            if let title = header.rightButton.title {
                Text(title).foregroundColor(header.rightButton.color)
            } else {
                header.rightButton.image.tint(header.rightButton.color)
            }
        }
    }
}


struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BackButton(onAction: {
                print("Back Button Tapped!!!")
            }).previewSettings(name: "Back Button")
            
            BackButton(onAction: {
                print("Back Button Tapped!!!")
            }).previewSettings(scheme: .dark, name: "Back Button Dark")
            
            CreateButton(onAction: {
                print("Back Button Tapped!!!")
            }).previewSettings(name: "Create Button")
            
            CreateButton(onAction: {
                print("Back Button Tapped!!!")
            }).previewSettings(scheme: .dark, name: "Create Button Dark")
        }
    }
}
