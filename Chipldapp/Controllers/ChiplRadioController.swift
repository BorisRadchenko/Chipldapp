//
//  ChiplTuner.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import Foundation
import FRadioPlayer
import MediaPlayer

class ChiplRadioController: NSObject {
    
    // MARK: - Properties / public
    
    static let shared = ChiplRadioController()
    
    var currentArtist: String? = nil
    
    var currentTitle: String? = nil
    
    var soundQuality: SoundQuality {
        didSet {
            guard oldValue != soundQuality else { return }
            UserDefaults.standard.set(soundQuality.rawValue, forKey: soundQualityKey)
            switch state {
            case .idle: break
            case .loading: restart()
            case .error: break
            case .playing: restart()
            case .stopping: break
            }
            if let reactToChanges = qualityDidChangeHandler { reactToChanges() }
        }
    }
    
    public private(set) var state: ChiplPlayerState {
        didSet {
            guard oldValue != state  else { return }
            printNicely(" → → → Player state changed to '\(state)'.")
            switch state {
            case .loading:
                let timeoutLimit: TimeInterval = 9
                printNicely("Trying to load media (timeout limit = '\(timeoutLimit)'s)...")
                loadingCountdown = BackgroundTimer(timeInterval: timeoutLimit)
                guard let countdown = loadingCountdown else { return }
                countdown.eventHandler = {
                    DispatchQueue.main.sync {
                        printNicely("Loading failed! Time limit is out!")
                        self.state = .error
                        self.radioPlayer.stop()
                    }
                }
                countdown.resume()
            default:
                loadingCountdown = nil
            }
            if let reactToPlaybackDidChange = playbackStateDidChangeHandler {
                reactToPlaybackDidChange()
            }
        }
    }

    var metadataDidChangeHandler: (() -> ())?
    
    var qualityDidChangeHandler: (()->())?
        
    var playbackStateDidChangeHandler: (()->())?
    
    // MARK: - Properties / private
    
    private let radioPlayer = FRadioPlayer.shared
    
    private var loadingCountdown: BackgroundTimer?

    private let defaultSoundQuality = SoundQuality.middle
    
    private let soundQualityKey = "soundQuality"

    
    // MARK: - Methods / public
    
    func play() {
        radioPlayer.radioURL = soundQuality.url
        state = .loading
        radioPlayer.isAutoPlay = true
        radioPlayer.play()
    }
    
    func stop() {
        state = .stopping
        radioPlayer.isAutoPlay = false
        radioPlayer.stop()
        clearCurrentTrackInfo()
        state = .idle
    }
    
    // MARK: - Methods / private
    
    private override init() {
        soundQuality = defaultSoundQuality
        if let lastSavedQualityRawValue = UserDefaults.standard.object(forKey: soundQualityKey) as? Int {
            if let lastSavedQuality = SoundQuality(rawValue: lastSavedQualityRawValue) {
                soundQuality = lastSavedQuality // Начальное значение soundQuality; didSet на init не срабатывает
            }
        }
        state = .idle
        super.init()
        radioPlayer.delegate = self
        radioPlayer.enableArtwork = false // Enable fetching albums artwork from the iTunes API. (default == true)
    }
    
    private func restart() {
        stop()
        play()
    }
    
    private func clearCurrentTrackInfo() {
        currentArtist = nil
        currentTitle = nil
    }

}

// MARK: - EXT / FRadioPlayerDelegate

extension ChiplRadioController: FRadioPlayerDelegate {
    
    // Called when player changes state
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        //printNicely("⚙️ PLAYER state = '\(state.description)'")
        switch player.state {
        case .loading:
            self.state = .loading
        case.loadingFinished:
            // Исключаем случаи, когда данные загружаются при выключенном воспроизведении
            guard player.isPlaying else { return }
            self.state = .playing
        default:
            return
        }
    }
    
    // Called when the player changes the playing state
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        //printNicely("▶️ PLAYBACK state = '\(state.description)'")
    }
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) { 
        guard self.state == .playing else { return }
        printNicely("Received new metadata (artist = '\(artistName ?? "")', track = '\(trackName ?? "")').")
        guard let metadata = artistName ?? trackName else { return }
        var metadataParts: [String] = []
        if metadata.count > 0 {
            metadataParts = metadata.components(separatedBy: "/")
            currentArtist = metadataParts[0]
            if metadataParts.count > 1 { currentTitle = metadataParts[1] }
        } else {
            printNicely("Could not parse metadata")
            currentArtist = nil
            currentTitle = nil
        }
        guard let reactToMetadataDidChange = metadataDidChangeHandler else { return }
        reactToMetadataDidChange()
    }
    
}

// MARK: - SoundQuality

enum SoundQuality: Int {
    case low = 40
    case middle = 64
    case high = 128
    case highest = 256
    var url: URL {
        switch self {
        case .low:
            return URL(string: "http://radio.4duk.ru/4duk40.mp3")! // альтернативный вариант: http://radio.4duk.ru:80/4duk40.mp3
        case .middle:
            return URL(string: "http://radio.4duk.ru/4duk64.mp3")! // альтернативный вариант: http://radio.4duk.ru:80/4duk64.mp3
        case .high:
            return URL(string: "http://radio.4duk.ru/4duk128.mp3")! // альтернативный вариант: http://radio.4duk.ru:80/4duk128.mp3
        case .highest:
            return URL(string: "http://radio.4duk.ru/4duk256.mp3")!  // альтернативный вариант: http://radio.4duk.ru:80/4duk256.mp3
        }
    }
}

// MARK: - ChiplPlayerState

enum ChiplPlayerState {
    case idle
    case loading
    case error
    case playing
    case stopping
}
