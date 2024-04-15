//
//  PrivateDialogInfoView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 26.04.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxData
import QuickBloxDomain

public struct PrivateDialogInfoView<ViewModel: DialogInfoProtocol>: View {
    let settings = QuickBloxUIKit.settings.dialogInfoScreen
    
    @StateObject private var viewModel: ViewModel

    @State private var searchPresented: Bool = false
    @State private var errorPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    
    init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        if isIphone {
            container()
        } else if isIPad {
            NavigationStack {
                container()
            }.accentColor(settings.header.leftButton.color)
        }
    }
    
    @ViewBuilder
    private func container() -> some View {
            ZStack {
                settings.backgroundColor.ignoresSafeArea()
                VStack {
                    
                    InfoDialogAvatar()
                    
                    ForEach(settings.privateActionSegments, id:\.self) { action in
                        InfoSegment(dialog: viewModel.dialog, action: action) { action in
                            switch action {
                            case .members: break
                            case .searchInDialog: searchPresented.toggle()
                            case .leaveDialog: isDeleteAlertPresented = true
                            case .notification: break
                            }
                        }
                    }
                    
                    SegmentDivider()
                }
                
                .onChange(of: viewModel.error, perform: { error in
                    if error.isEmpty { return }
                    errorPresented.toggle()
                })
                
                .errorAlert($viewModel.error, isPresented: $errorPresented)
                
                .deleteDialogAlert(isPresented: $isDeleteAlertPresented,
                                   name: viewModel.dialog.name,
                                   onCancel: {
                    isDeleteAlertPresented = false
                }, onTap: {
                    viewModel.deleteDialog()
                })
                
                .disabled(viewModel.isProcessing == true)
                .if(viewModel.isProcessing == true) { view in
                    view.overlay() {
                        CustomProgressView()
                    }
                }
                .modifier(PrivateDialogInfoHeader())
                
                .environmentObject(viewModel)
            }
            .onAppear {
                viewModel.sync()
            }
    }
}
