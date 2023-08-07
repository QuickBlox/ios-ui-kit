//
//  InputView.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct InputView: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.textField
    let assistAnswer = QuickBloxUIKit.feature.ai.assistAnswer
    
    let onSend: (_ text: String) -> Void
    let onAttachment: () -> Void
    let onRecord: () -> Void
    let onStopRecord: () -> Void
    let onDeleteRecord: () -> Void
    let onTyping: () -> Void
    let onStopTyping: () -> Void
    
    @State private var text: String = ""
    @Binding var waitingAnswer: Bool
    @Binding var aiAnswer: String
    
    @State var isRecordState: Bool = false
    @State var isRecording: Bool = false
    
    @State var isHasMessage: Bool = false
    
    @ObservedObject var timer = StopWatchTimer()
    
    var body: some View {
        
        HStack(spacing: 0) {
            Button(action: {
                if isRecordState == true, isRecording == false {
                    onStopRecord()
                    onDeleteRecord()
                    isRecordState = false
                    isHasMessage = false
                    timer.reset()
                } else {
                    onAttachment()
                }
            }) {
                if isRecordState == true, isRecording == false {
                    settings.leftButton.stopImage.foregroundColor(settings.leftButton.stopColor)
                } else if isRecording == false || aiAnswer.isEmpty == false {
                    settings.leftButton.image.foregroundColor(settings.leftButton.color)
                }
            }.frame(width: settings.leftButton.width, height: settings.barHeight)
            
            ZStack {
                
                TextField(isRecordState || waitingAnswer ? "" : settings.placeholderText, text: aiAnswer.isEmpty == false ? $aiAnswer : $text)
                    .onChange(of: aiAnswer, perform: { newValue in
                        if newValue.isEmpty == false {
                            text = ""
                            onTyping()
                            isHasMessage = true
                        } else {
                            onStopTyping()
                            isHasMessage = false
                        }
                    })
                    .onChange(of: text, perform: { newValue in
                        if newValue.isEmpty == false {
                            onTyping()
                            isHasMessage = true
                        } else {
                            onStopTyping()
                            isHasMessage = false
                        }
                    })
                    .onChange(of: waitingAnswer, perform: { newValue in
                        if newValue == true {
                            text = ""
                            aiAnswer = ""
                        }
                    })
                    .padding(settings.padding)
                    .background(settings.backgroundColor)
                    .cornerRadius(settings.radius)
                    .frame(height: settings.height)
                    .textFieldStyle(.plain)
                    .font(settings.placeholderFont)
                    .disabled(isRecordState == true)
                    .if(waitingAnswer == true && aiAnswer.isEmpty == true) { view in
                        view.overlay() {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Waiting...")
                                Spacer()
                            }
                            .padding(.horizontal)
                            .background(settings.backgroundColor)
                            .cornerRadius(settings.radius)
                        }
                    }
                    .if(isRecordState == true) { view in
                        view.overlay() {
                            HStack {
                                settings.timer.image.foregroundColor(settings.timer.imageColor)
                                Text(timer.counter.toString())
                                    .foregroundColor(settings.timer.foregroundColor)
                                    .font(settings.timer.font)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .background(settings.backgroundColor)
                            .cornerRadius(settings.radius)
                        }
                    }
            }
            
            Button(action: {
                if isHasMessage == true || aiAnswer.isEmpty == false {
                    isRecordState = false
                    isHasMessage = false
                    timer.reset()
                    onSend(aiAnswer.isEmpty == false ? aiAnswer : text)
                    text = ""
                    aiAnswer = ""
                    onStopTyping()
                
                } else  if text.isEmpty, isHasMessage == false {
                    if isRecordState == false, isRecording == false {
                        onRecord()
                        isRecordState = true
                        isRecording = true
                        timer.start()
                    } else if isRecordState == true, isRecording == true {
                        isHasMessage = true
                        isRecording = false
                        onStopRecord()
                        timer.stop()
                    }
                }
                
            }) {
                if isHasMessage == true || aiAnswer.isEmpty == false {
                    settings.rightButton.image.foregroundColor(settings.rightButton.color)
                        .rotationEffect(Angle(degrees: settings.rightButton.degrees))
                } else if text.isEmpty, isHasMessage == false {
                    settings.rightButton.micImage.foregroundColor(isRecording ? settings.timer.imageColor : settings.rightButton.micColor)
                }
            }
            .frame(width: settings.rightButton.width, height: settings.barHeight)
            
        }
        .frame(height: settings.barHeight)
    }
    }


struct MessageTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            InputView(onSend: { _ in
                
            }, onAttachment: {
                
            }, onRecord: {
                
            }, onStopRecord: {
                
            }, onDeleteRecord: {
                
            }, onTyping: {
                
            }, onStopTyping: {
                
            }, waitingAnswer: Binding.constant(false),
                      aiAnswer: Binding.constant(""))
            
            InputView(onSend: { _ in
                
            }, onAttachment: {
                
            }, onRecord: {
                
            }, onStopRecord: {
                
            }, onDeleteRecord: {
                
            }, onTyping: {
                
            }, onStopTyping: {
                
            }, waitingAnswer: Binding.constant(false),
                      aiAnswer: Binding.constant(""))
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
