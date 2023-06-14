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
            print("Playing failed.")
        }
        
        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer = try AVAudioPlayer(data: audio, fileTypeHint: AVFileType.mp3.rawValue)
        
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
        } catch {
            print("Play Audio failed.")
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
}
