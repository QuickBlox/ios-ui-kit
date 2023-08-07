//
//  AudioRecorder.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//
//

import SwiftUI
import AVFoundation
import Combine

struct AudioRecording {
    let audioURL: URL
    let createdAt: Date
}

open class AudioRecorder: NSObject, ObservableObject {
    public let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var audioRecorder: AVAudioRecorder!
    var audioRecording: AudioRecording?
    var audioFilename:URL? = nil
    
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func start() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY 'at' HH:mm:ss")).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            self.audioFilename = audioFilename
            
            recording = true
        } catch {
            recording = false
            print("Error start recording")
        }
    }
    
    func stop() {
        guard let audioRecorder else { return }
        audioRecorder.stop()
        recording = false
        
        fetch()
    }
    
    func fetch() {
        guard let audioFilename = audioFilename else {
            return
        }
        let createdAt = getFileDate(for: audioFilename)
        audioRecording = AudioRecording(audioURL: audioFilename,
                                        createdAt: createdAt)
        objectWillChange.send(self)
    }
    
    func delete() {
        guard let fileURL = audioRecording?.audioURL else { return }
        
        print(fileURL)
        do {
            try FileManager.default.removeItem(at: fileURL)
            audioRecording = nil
        } catch {
            print("File could not be deleted!")
        }
    }
    
    func getFileDate(for file: URL) -> Date {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
           let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            return creationDate
        } else {
            return Date()
        }
    }
}
