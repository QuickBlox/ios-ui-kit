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

struct DialogTypeView: View {
    private var settings = QuickBloxUIKit.settings.dialogTypeScreen
    
    @State private var presentCreateDialog: Bool = false
    @State private var presentNewDialog: Bool = false
    
    @State private var selectedSegment: DialogType?
    var dialogTypeBar: DialogTypeBar?
    
    // Actions
    private var onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    public var body: some View {
        if isIphone {
            container()
        } else {
            NavigationStack {
                container()
            }.accentColor(settings.header.leftButton.color)
        }
    }
    
    @ViewBuilder
    private func container() -> some View {
        VStack {
            VStack {
                DialogTypeHeaderView(onClose: {
                    onClose()
                })
                
                dialogTypeBar ??
                DialogTypeBar(selectedSegment: $selectedSegment)
            }.background(settings.header.backgroundColor)
            
            Spacer().materialModifier()
            
                .if(isIphone == true) { view in
                    view.navigationDestination(isPresented: $presentCreateDialog) {
                        createDialogView()
                    }
                }
            
                .if((isIPad == true || isMac == true)) { view in
                    view.sheet(isPresented: $presentCreateDialog, content: {
                        createDialogView()
                            .onDisappear {
                                self.selectedSegment = nil
                            }
                    })
                }
            
        }
        .onChange(of: selectedSegment, perform: { selectedType in
            presentCreateDialog = selectedType != nil
        })
        .onAppear {
            selectedSegment = nil
        }
    }
    
    @ViewBuilder
    private func createDialogView() -> some View {
        Group {
            if selectedSegment == .private {
                let dialog = Dialog(type: .private)
                let model = CreateDialogViewModel(modeldDialog: dialog)
                CreateDialogView(viewModel: model, isPresented: $presentCreateDialog)
            } else if let selectedSegment {
                NewDialog(NewDialogViewModel(), type: selectedSegment, isPresented: $presentCreateDialog)
            } else {
                EmptyView()
            }
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
                        settings.header.rightButton.image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(settings.header.rightButton.scale)
                            .tint(settings.header.rightButton.color)
                            .padding(settings.header.rightButton.padding)
                    }
                }
                .padding(.trailing)
                .frame(width: settings.header.rightButton.frame?.width,
                       height: settings.header.rightButton.frame?.height)
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
