//
//  AudioPlayer.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 17.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//
//

import SwiftUI
import AVFoundation
import Combine

open class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    public let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    
    var isPlaying = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var audioPlayer: AVAudioPlayer!
    
    func play(audio: Data) {
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed error = \(error)")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audio, fileTypeHint: AVFileType.mp3.rawValue)
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
        } catch {
            print("Playing failed error = \(error)")
        }
    }
    
    func stop() {
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        isPlaying = false
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
    
    private func temporaryUrl(_ data: Data) -> URL {
        let localURL = URL(fileURLWithPath:NSTemporaryDirectory())
            .appendingPathComponent("Audio_\(Date())")
        let _ = (try? data.write(to: localURL, options: [.atomic])) != nil
        return localURL
    }
}
