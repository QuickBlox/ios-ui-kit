//
//  MessageTextField.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 01.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct MessageTextField: View {
    var settings = QuickBloxUIKit.settings.dialogScreen.textField
    
    let onSend: () -> Void
    let onAttachment: () -> Void
    let onRecord: () -> Void
    let onStopRecord: () -> Void
    let onDeleteRecord: () -> Void
    
    @State var isRecordState: Bool = false
    @State var isRecording: Bool = false
    
    @State var isHasMessage: Bool = false
    
    @ObservedObject var timer = StopWatchTimer()
    
    @Binding var text: String
    
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
                } else if isRecording == false {
                    settings.leftButton.image.foregroundColor(settings.leftButton.color)
                }
            }.frame(width: settings.leftButton.width, height: settings.barHeight)
            
            ZStack {
                
                TextField(isRecordState ? "" : settings.placeholderText, text: $text)
                    .onChange(of: text, perform: { newValue in
                        isHasMessage = newValue.isEmpty == false
                    })
                    .padding(settings.padding)
                    .background(settings.backgroundColor)
                    .cornerRadius(settings.radius)
                    .frame(height: settings.height)
                    .textFieldStyle(.plain)
                    .font(settings.placeholderFont)
                    .disabled(isRecordState == true)
                    .if(isRecordState == true) { view in
                        view.overlay() {
                            HStack {
                                settings.timer.image.foregroundColor(settings.timer.imageColor)
                                Text(timer.counter.convertToString())
                                    .foregroundColor(settings.timer.foregroundColor)
                                    .font(settings.timer.font)
                                Spacer()
                            }.padding(.horizontal)
                        }
                    }
            }
            
            Button(action: {
                if text.isEmpty, isHasMessage == false {
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
                } else if isHasMessage == true {
                    isRecordState = false
                    isHasMessage = false
                    timer.reset()
                    onSend()
                }
            }) {
                if text.isEmpty, isHasMessage == false {
                    settings.rightButton.micImage.foregroundColor(isRecording ? settings.timer.imageColor : settings.rightButton.micColor)
                } else if isHasMessage == true {
                    settings.rightButton.image.foregroundColor(settings.rightButton.color)
                        .rotationEffect(Angle(degrees: settings.rightButton.degrees))
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
            MessageTextField(onSend: {
                
            }, onAttachment: {
                
            }, onRecord: {
                
            }, onStopRecord: {
                
            }, onDeleteRecord: {
                
            }, text: Binding.constant(""))
            
            MessageTextField(onSend: {
                
            }, onAttachment: {
                
            }, onRecord: {
                
            }, onStopRecord: {
                
            }, onDeleteRecord: {
                
            }, text: Binding.constant(""))
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

private extension TimeInterval {
    func convertToString() -> String {
        let hours = String(format: "%02d",  Int(self / 3600))
        let minutes = String(format: "%02d", Int(self / 60))
        let seconds = String(format: "%02d", Int(self) % 60)
        return hours + " : " + minutes + " : " + seconds
    }
}
