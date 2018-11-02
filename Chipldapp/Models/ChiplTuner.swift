//
//  ChiplTuner.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import Foundation
import FRadioPlayer

class ChiplTuner {
    static let shared = ChiplTuner()
    private let tunerEngine = FRadioPlayer.shared
    private var streamURL: URL? = nil
    
    var streamQuality: StreamQuality {
        didSet {
            let qualityLevelURL = [StreamQuality.low    : URL(string: "http://radio.4duk.ru:80/4duk40.mp3")!,
                                   StreamQuality.middle : URL(string: "http://radio.4duk.ru:80/4duk64.mp3")!,
                                   StreamQuality.high   : URL(string: "http://radio.4duk.ru:80/4duk128.mp3")!,
                                   StreamQuality.highest: URL(string: "http://radio.4duk.ru:80/4duk256.mp3")!]
            // tunerEngine.radioURL = qualityLevelURL[streamQuality]
            streamURL = qualityLevelURL[streamQuality]
            print(streamURL)
        }
    }
    
    private init() {
        self.streamQuality = .low
        self.tunerEngine.delegate = self
    }
    
    func play() {
        if let streamURL = streamURL {
            tunerEngine.radioURL = streamURL
            print(streamURL)
            tunerEngine.play()
        } else {
            print("No URL!")
        }
    }
    
    func stop() {
        tunerEngine.stop()
    }

}

// MARK: - FRadioPlayerDelegate
extension ChiplTuner: FRadioPlayerDelegate {
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print(state.description)
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print(player.isPlaying)
    }
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        print("\(artistName ?? "")")
    }
}

enum StreamQuality {
    case low
    case middle
    case high
    case highest
}
