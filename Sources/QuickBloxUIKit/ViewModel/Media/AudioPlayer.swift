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
    
    public var currentTime: TimeInterval = 0 {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    public var duration: CMTime = .zero {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    public var isPlaying = false {
        didSet {
            objectWillChange.send(self)
            if isPlaying == false {
                invalidPlayer()
            }
        }
    }
    
    private var audioPlayer: AVPlayer!
    private var playerItem: AVPlayerItem!
    
    private func addObservers() {
        audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0,
                                                                 preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                             queue: .main) { [weak self] time in
            guard let self = self, let audioPlayer else { return }
            self.currentTime = time.seconds.rounded()
            self.isPlaying = audioPlayer.currentItem?.currentTime() != audioPlayer.currentItem?.duration
        }
    }
    
    public func play(audioURL: URL) {
        invalidPlayer()
        
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed error = \(error)")
        }
        
        let asset = AVAsset(url: audioURL)
        asset.loadValuesAsynchronously(forKeys: ["duration"], completionHandler: {
            debugPrint(asset.duration)
            self.duration = asset.duration
        })
        
        let playerItem = AVPlayerItem(asset: asset)
        audioPlayer = AVPlayer(playerItem:playerItem)
        audioPlayer.rate = 1.0;
        addObservers()
        audioPlayer.play()
        currentTime = 0.0
        isPlaying = true
    }
    
    public func stop() {
        isPlaying = false
    }
    
    private func invalidPlayer() {
        if audioPlayer != nil {
            audioPlayer.pause()
            playerItem = nil
            audioPlayer = nil
        }
        currentTime = 0.0
    }
}
