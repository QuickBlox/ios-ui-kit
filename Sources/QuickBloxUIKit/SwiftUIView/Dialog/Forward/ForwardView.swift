//
//  ForwardView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 06.11.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import QuickBloxData

public struct ForwardView<ViewModel: ForwardViewModelProtocol>: View {
    @State public var settings
    = QuickBloxUIKit.settings.addMembersScreen
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject public var viewModel: ViewModel
    @State private var isForwardFailedPresented: Bool = false
    @State var isPresented: Bool = false
    
    let onForwardSuccess: () -> Void
    
    init(viewModel: ViewModel,
         onForwardSuccess: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onForwardSuccess = onForwardSuccess    }
    
    public var body: some View {
        container()
            .onAppear {
                viewModel.getDialogs()
            }
            .onDisappear {
                viewModel.unsync()
            }
    }
    
    @ViewBuilder
    private func container() -> some View {
        ZStack {
            VStack(spacing: 0) {
                SelectDialogsListView<ViewModel, ViewModel.DialogItem>(viewModel: viewModel)
                
                ForwardInputView()
                    .background(settings.backgroundColor)
                    .overlay(Divider(), alignment: .top)
            }
        }
        .modifier(ForwardHeader(onDismiss: {
            dismiss()
        }))
        
        .onChange(of: viewModel.forwardInfo.result, perform: { forwarResult in
            if forwarResult == .success {
                onForwardSuccess()
                dismiss()
            } else {
                isForwardFailedPresented = true
            }
        })
        
        .if(isForwardFailedPresented == true, transform: { view in
            view.forwardFailureAlert(isPresented: $isForwardFailedPresented)
        })
            
            .environmentObject(viewModel)
    }
}

struct ForwardHeaderToolbarContent: ToolbarContent {
    
    private var settings = QuickBloxUIKit.settings.addMembersScreen.header
    
    let onDismiss: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onDismiss()
            } label: {
                Text("Cancel")
                    .foregroundColor(settings.leftButton.color)
            }
        }
    }
}

public struct ForwardHeader: ViewModifier {
    private var settings = QuickBloxUIKit.settings.addMembersScreen.header
    
    let onDismiss: () -> Void
    
    public init(
        onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
    
    public func body(content: Content) -> some View {
        content.toolbar {
            ForwardHeaderToolbarContent(onDismiss: onDismiss)
        }
        .navigationTitle("Forward")
        .navigationBarTitleDisplayMode(settings.displayMode)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(settings.isHidden)
        .toolbarBackground(settings.backgroundColor,for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
