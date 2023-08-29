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

struct InputView: View  {
    let textFieldSettings = QuickBloxUIKit.settings.dialogScreen.textField
    let typingSettings = QuickBloxUIKit.settings.dialogScreen.typing
    let aiFeatures = QuickBloxUIKit.feature.aiFeature
    
    @EnvironmentObject var viewModel: DialogViewModel
    
    let onAttachment: () -> Void
    let onApplyTone: (_ type: String, _ content: String, _ needToUpdate: Bool) -> Void
    
    @State private var text: String = ""
    
    @State var isRecordState: Bool = false
    @State var isRecording: Bool = false
    @FocusState var isFocused: Bool
    
    @State var isHasMessage: Bool = false
    @State private var isUpdatedContent: Bool = false
    @State private var isUpdatedByAIAnswer: Bool = false
    
    private var isWaitingAnswer: Bool {
        return viewModel.waitingAnswer == true && viewModel.aiAnswer.isEmpty == true
    }
    
    @StateObject var timer = StopWatchTimer()
    
    var body: some View {
        
        VStack(spacing: 8) {
            if aiFeatures.rephrase.enable == true, isFocused == true {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(aiFeatures.rephrase.tones, id:\.self) { tone in
                            AIToneView(tone: tone, onApplyTone: {
                                if text.isEmpty == false {
                                    onApplyTone(tone.type, text, isUpdatedContent)
                                    isUpdatedContent = false
                                } else {
                                    print("")
                                }
                            })
                        }
                    }
                }.padding(.top, 8)
            }
            
            HStack(spacing: 0) {
                
                VStack {
                    Spacer()
                    Button(action: {
                        if isRecordState == true, isRecording == false {
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
                        .padding(.bottom, 8)
                }
                
                TextFieldView(isRecordState: $isRecordState, text: viewModel.aiAnswer.isEmpty == false ? $viewModel.aiAnswer : (isWaitingAnswer == true ? Binding.constant("Processing...") : $text))
                    .focused($isFocused)
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
                            
                            if typingSettings.enable == true {
                                viewModel.sendTyping()
                            }
                            isHasMessage = true
                        } else {
                            if typingSettings.enable == true {
                                viewModel.sendStopTyping()
                            }
                            isHasMessage = false
                        }
                    })
                
                    .if(isRecordState == true) { view in
                        view.overlay() {
                            HStack {
                                textFieldSettings.timer.image.foregroundColor(textFieldSettings.timer.imageColor)
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
                    
                    if isWaitingAnswer == true {
                        ProgressView()
                            .frame(width: 40, height: 44)
                            .padding(.bottom, 8)
                    } else {
                        Button(action: {
                            if isHasMessage == true || viewModel.aiAnswer.isEmpty == false {
                                isRecordState = false
                                isHasMessage = false
                                timer.reset()
                                viewModel.sendMessage(viewModel.aiAnswer.isEmpty == false ? viewModel.aiAnswer : text)
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
                            if isHasMessage == true || viewModel.aiAnswer.isEmpty == false {
                                textFieldSettings.rightButton.image.foregroundColor(textFieldSettings.rightButton.color)
                                    .rotationEffect(Angle(degrees: textFieldSettings.rightButton.degrees))
                            } else if text.isEmpty, isHasMessage == false {
                                textFieldSettings.rightButton.micImage.foregroundColor(isRecording ? textFieldSettings.timer.imageColor : textFieldSettings.rightButton.micColor)
                            }
                        }
                        .frame(width: textFieldSettings.rightButton.width, height: 40)
                        .padding(.bottom, 8)
                    }
                }
                
            }.background(textFieldSettings.backgroundColor)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(textFieldSettings.contentBackgroundColor)
    }
}

struct AIToneView: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var tone: AITone
    let onApplyTone: () -> Void
    
    var body: some View {
        
        Button {
            onApplyTone()
        } label: {
            HStack(spacing: 4) {
                Text(tone.icon)
                    .font(settings.dateFont)
                Text(tone.name)
                    .foregroundColor(settings.outboundForeground)
                    .font(settings.outboundFont)
            }
            .padding(6)
            .background(settings.outboundBackground)
            .frame(height: 25)
            .cornerRadius(12.5)
        }
    }
}

struct TextFieldView: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.textField
    var aiFeatures = QuickBloxUIKit.feature.aiFeature
    
    @Binding var isRecordState: Bool
    @Binding var text: String
    
    var body: some View {
        if #available(iOS 16.0, *) {
            TextField(isRecordState ? "" : settings.placeholderText, text: $text, axis: .vertical)
                .lineLimit(1...settings.lineLimit)
                .font(settings.placeholderFont)
                .padding(settings.padding)
                .background(settings.placeholderBackgroundColor)
                .cornerRadius(settings.radius)
                .padding(.vertical, 8)
                .textFieldStyle(.plain)
                .disabled(isRecordState == true)
        } else {
            TextField(isRecordState ? "" : settings.placeholderText, text: $text)
                .font(settings.placeholderFont)
                .padding(settings.padding)
                .background(settings.placeholderBackgroundColor)
                .cornerRadius(settings.radius)
                .frame(height: settings.height)
                .textFieldStyle(.plain)
                .disabled(isRecordState == true)
        }
    }
}

struct MessageTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InputView(onAttachment: {
                
            }, onApplyTone: {_,_,_ in }
            )
            
            InputView(onAttachment: {
                
            }, onApplyTone: {_,_,_ in }
            )
            .previewSettings(scheme: .dark, name: "Dark mode")
            
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
