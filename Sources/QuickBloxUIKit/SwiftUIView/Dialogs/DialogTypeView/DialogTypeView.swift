//
//  DialogTypeView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 30.03.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData

public struct DialogTypeView: View {
    private var settings = QuickBloxUIKit.settings.dialogTypeScreen
    
    @State private var selectedSegment: DialogType?
    var dialogTypeBar: DialogTypeBar?
    
    // Actions
    private var onClose: () -> Void
    
    public init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack {
            VStack {
                DialogTypeHeaderView(onClose: onClose)
                
                dialogTypeBar ??
                DialogTypeBar(selectedSegment: $selectedSegment)
            }.background(settings.header.backgroundColor)
            
            Spacer().materialModifier()
            
            if let selectedSegment {
                NavigationLink (
                    tag: selectedSegment,
                    selection: $selectedSegment
                ) {
                    if selectedSegment == .private {
                        CreateDialogView(viewModel: CreateDialogViewModel(modeldDialog: Dialog(type: .private)),
                                     content: {
                            viewModel in
                            
                            UserListView(viewModel: viewModel,
                                         content: { item, isSelected, onTap in
                                UserRow(item, isSelected: isSelected, onTap: onTap)
                            })})
                    } else {
                        NewDialog(NewDialogViewModel(), type: selectedSegment)
                    }
                } label: {
                    EmptyView()
                }
            }
        }
        .onChange(of: selectedSegment, perform: { selectedType in
            selectedSegment = selectedType
        })
        .onAppear {
            selectedSegment = nil
        }
    }
}

public struct DialogTypeHeaderView: View {
    public var settings = QuickBloxUIKit.settings.dialogTypeScreen
    
    public var onClose: () -> Void
    
    public var body: some View {
        ZStack {
            HStack {
                Text(settings.header.title.text)
                    .font(settings.header.title.font)
                    .foregroundColor(settings.header.title.color)
            }
            HStack {
                Spacer()
                Button {
                    onClose()
                } label: {
                    if let title = settings.header.rightButton.title {
                        Text(title).foregroundColor(settings.header.rightButton.color)
                    } else {
                        settings.header.rightButton.image.tint(settings.header.rightButton.color)
                    }
                }.padding(.trailing)
            }
            VStack {
                Spacer()
                Separator(isLastRow: true)
            }
        }
        .frame(height: settings.header.height)
        .background(settings.header.backgroundColor)
    }
}

private struct DialogTypeConstant {
    static let height: CGFloat = 44.0 + 1.0 // navBarHeight + dividerHeight
}

//struct DialogTypeView_Previews: PreviewProvider {
//    @State var isModalPresented: Bool = true
//    static var previews: some View {
//        DialogTypeView<Dialog, User, UserListView<User, UserRow>, UserRow>(onClose: {
//            
//        })
//        DialogTypeView<Dialog, User, UserListView<User, UserRow>, UserRow>(onClose: {
//            
//        })
//        .previewDisplayName("Segmented Control Dark")
//        . preferredColorScheme(.dark)
//    }
//}
