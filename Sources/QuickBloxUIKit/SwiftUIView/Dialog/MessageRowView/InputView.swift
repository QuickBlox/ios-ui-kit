//
//  InputView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI
import QuickBloxDomain
import AVFoundation
import QBAIRephrase
import QuickBloxLog

struct InputView: View  {
    let textFieldSettings = QuickBloxUIKit.settings.dialogScreen.textField
    let typingSettings = QuickBloxUIKit.settings.dialogScreen.typing
    let features = QuickBloxUIKit.feature
    
    @EnvironmentObject var viewModel: DialogViewModel
    
    let onAttachment: () -> Void
    let onApplyTone: (_ type: QBAIRephrase.AITone, _ content: String, _ needToUpdate: Bool) -> Void
    
    @State private var text: String = ""
    
    @State var isRecordState: Bool = false
    @State var isRecording: Bool = false
    @FocusState var isFocused: Bool
    
    @State var isHasMessage: Bool = false
    @State private var isUpdatedContent: Bool = false
    @State private var isUpdatedByAIAnswer: Bool = false
    
    @State private var originSenderName: String = ""
    
    private var isWaitingAnswer: Bool {
        return viewModel.waitingAnswer.waiting == true && viewModel.aiAnswer.isEmpty == true
    }
    
    @StateObject var timer = StopWatchTimer()
    
    var body: some View {
        
        VStack {
            if features.ai.rephrase.enable == true,
               isFocused == true,
               text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.tones, id:\.self) { tone in
                            AIToneView(tone: tone, onApplyTone: {
                                if text.isEmpty == false {
                                    onApplyTone(tone, text, isUpdatedContent)
                                    isUpdatedContent = false
                                } else {
                                    print("")
                                }
                            }, isWaitingAnswer: isWaitingAnswer)
                        }
                    }
                }
            }
            
            if features.reply.enable == true,
               let message = viewModel.selectedMessages.first,
               viewModel.messagesActionState == .reply {
                MessageActionBanner(
                    userName: $originSenderName,
                    message: message,
                    messageAction: .reply, onCancelReply: {
                        if viewModel.isProcessing { return }
                        viewModel.cancelMessageAction()
                    }, forMessage: false, count: viewModel.selectedMessages.count)
            }
            
            HStack(spacing: 0) {
                
                VStack {
                    Spacer()
                    Button(action: {
                        if isRecordState == true, isRecording == false, viewModel.syncState == .synced {
                            viewModel.stopRecording()
                            viewModel.deleteRecording()
                            isRecordState = false
                            isHasMessage = false
                            timer.reset()
                        } else {
                            onAttachment()
                        }
                    }) {
                        if isRecordState == true, isRecording == false {
                            textFieldSettings.leftButton.stopImage.foregroundColor(textFieldSettings.leftButton.stopColor)
                        } else if isRecording == false || viewModel.aiAnswer.isEmpty == false {
                            textFieldSettings.leftButton.image.foregroundColor(textFieldSettings.leftButton.color)
                        }
                    }.frame(width: textFieldSettings.leftButton.width, height: 40)
                        .padding(.bottom, 5)
                }
                
                TextFieldView(isDisabled: isRecordState,
                              text: viewModel.aiAnswer.isEmpty == false ?
                              $viewModel.aiAnswer : $text,
                              typing: {
                    if typingSettings.enable == true, isFocused == true, isHasMessage == true {
                        viewModel.sendTyping()
                    }
                })
                .focused($isFocused)
                .onChange(of: isFocused, perform: { newValue in
                    if newValue == false {
                        viewModel.sendStopTyping()
                    }
                })
                .onChange(of: viewModel.aiAnswer, perform: { newValue in
                    if newValue.isEmpty == false {
                        isUpdatedByAIAnswer = true
                        text = viewModel.aiAnswer
                        viewModel.aiAnswer = ""
                        if typingSettings.enable == true {
                            viewModel.sendTyping()
                        }
                        isHasMessage = true
                    }
                })
                .onChange(of: text, perform: { newValue in
                    if newValue.isEmpty == false {
                        
                        if isFocused == true, isUpdatedContent == false, isUpdatedByAIAnswer == false {
                            isUpdatedContent = true
                        }
                        
                        isUpdatedByAIAnswer = false
                        isHasMessage = true
                    } else {
                        isHasMessage = false
                    }
                })
                
                .if(isRecordState == true) { view in
                    view.overlay() {
                        HStack {
                            textFieldSettings.timer.image
                                .foregroundColor(textFieldSettings.timer.imageColor)
                            Text(timer.counter.toString())
                                .foregroundColor(textFieldSettings.timer.foregroundColor)
                                .font(textFieldSettings.timer.font)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .background(textFieldSettings.placeholderBackgroundColor)
                        .cornerRadius(textFieldSettings.radius)
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        if isWaitingAnswer == true { return }
                        
                        if (isHasMessage == true || viewModel.aiAnswer.isEmpty == false) && viewModel.syncState == .synced {
                            isRecordState = false
                            isHasMessage = false
                            timer.reset()
                            viewModel.sendMessage(viewModel.aiAnswer.isEmpty == false ?
                                                  viewModel.aiAnswer : text)
                            text = ""
                            viewModel.aiAnswer = ""
                            if typingSettings.enable == true {
                                viewModel.sendStopTyping()
                            }
                            
                        } else  if text.isEmpty, isHasMessage == false {
                            
                            viewModel.requestPermission(.audio) { granted in
                                if granted {
                                    if isRecordState == false, isRecording == false {
                                        viewModel.startRecording()
                                        isRecordState = true
                                        isRecording = true
                                        timer.start()
                                    } else if isRecordState == true, isRecording == true {
                                        isHasMessage = true
                                        isRecording = false
                                        viewModel.stopRecording()
                                        timer.stop()
                                    }
                                }
                            }
                        }
                    }) {
                        
                        if isWaitingAnswer == true {
                            SegmentedCircularBar(settings: textFieldSettings.progressBar)
                        } else {
                            
                            if isHasMessage == true || viewModel.aiAnswer.isEmpty == false {
                                textFieldSettings.rightButton.image.foregroundColor(textFieldSettings.rightButton.color)
                                    .rotationEffect(Angle(degrees: textFieldSettings.rightButton.degrees))
                            } else if text.isEmpty, isHasMessage == false {
                                textFieldSettings.rightButton.micImage
                                    .foregroundColor(isRecording ?
                                                     textFieldSettings.timer.imageColor : textFieldSettings.rightButton.micColor)
                            }
                        }
                    }
                    .frame(width: textFieldSettings.rightButton.frame?.width,
                           height: textFieldSettings.rightButton.frame?.height)
                    .padding(.bottom, 5)
                }
            }.overlay(Divider(), alignment: .top)
        }
        .disabled(viewModel.isProcessing == true)
        .fixedSize(horizontal: false, vertical: true)
        .background(textFieldSettings.backgroundColor)
        .if(viewModel.messagesActionState == .reply) { view in
            view.overlay(Divider(), alignment: .top)
        }
    }
}

struct AIToneView: View {
    var settings = QuickBloxUIKit.feature.ai.ui.rephrase
    
    var tone: QBAIRephrase.AITone
    let onApplyTone: () -> Void
    var isWaitingAnswer: Bool = false
    
    var body: some View {
        Button {
            onApplyTone()
        } label: {
            HStack(spacing: settings.contentSpacing) {
                if let toneIcon = tone.icon {
                    Text(toneIcon)
                        .font(settings.iconFont)
                }
                Text(tone == .original ? tone.name : tone.name + " Tone")
                    .foregroundColor(settings.nameForeground)
                    .font(settings.nameFont)
            }
            .padding(settings.bubblePadding)
            .background(Capsule().fill(settings.bubbleBackground))
            .padding(settings.contentPadding)
        }
        .frame(height: settings.buttonHeight)
    }
}

import Combine
struct TextFieldView: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.textField
    var aiFeatures = QuickBloxUIKit.feature.ai
    
    @State var typingPublisher = PassthroughSubject<Void, Never>()
    
    var isDisabled: Bool
    @Binding var text: String
    let typing: (() -> Void)?
    
    var body: some View {
        TextField(isDisabled ? "" : settings.placeholderText, text: $text, axis: .vertical)
            .lineLimit(1...settings.lineLimit)
            .font(settings.placeholderFont)
            .padding(settings.padding)
            .background(settings.placeholderBackgroundColor)
            .cornerRadius(settings.radius)
            .textFieldStyle(.plain)
            .disabled(isDisabled)
            .onChange(of: text) { text in
                if text.isEmpty == false {
                    typingPublisher.send()
                }
            }
            .onReceive(
                typingPublisher.throttle(
                    for: 2.5,
                    scheduler: DispatchQueue.main,
                    latest: true
                )
            ) {
                if let typing = typing {
                    typing()
                }
            }
    }
}
