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
    // MARK: P R O P E R T I E S / public
    static let shared = ChiplRadioController()
    var soundQuality: SoundQuality {
        didSet { // Обработчик наблюдателя значения
            if oldValue != soundQuality { // Новое значение отличается от предыдущего
                UserDefaults.standard.set(soundQuality.rawValue, forKey: soundQualityKey) // Новое значение сохранено в UserDefaults
                if let handler = qualityDidChangeHandler { // Запуск обработчика смены качества
                    handler()
                }
            }
        }
    }
    var state: ChiplPlayerState = .idle {
        didSet {
            if oldValue != state {
                print("\(Date()) CHIPL PLAYER NEW STATE = \(state)")
                switch state {
                case .loading:
                    loadingCountdown = BackgroundTimer(timeInterval: 9)
                    guard let countdown = loadingCountdown else { return }
                    countdown.eventHandler = {
                        DispatchQueue.main.async {
                            self.state = .error // нельзя из background вызывать обновление UI!
                        }
                        self.loadingCountdown = nil
                    }
                    countdown.resume()
                case .error:
                    if let handler = errorDidHappenHandler {
                            handler()
                    }
                    loadingCountdown = nil
                    DispatchQueue.main.async {
                        self.stop()
                    }
                case .playing:
                    loadingCountdown = nil
                case .idle:
                    loadingCountdown = nil
                case .stopping:
                    loadingCountdown = nil
                }
                if let handler = playbackStateDidChangeHandler {
                    handler()
                }
            }
        }
    }
    var metadataDidChangeHandler: ((_ currentArtist: String?,_ currentTitle: String?) -> ())?
    var qualityDidChangeHandler: (()->())? 
    var errorDidHappenHandler: (()->())?
    var playbackStateDidChangeHandler: (()->())?
    
    // MARK: - P R O P E R T I E S / private
    private let radioPlayer = FRadioPlayer.shared
    private var defaultSoundQuality: SoundQuality
    private var soundQualityKey: String
    private var urlBySoundQuality: [SoundQuality:URL]
    private var loadingCountdown: BackgroundTimer?
    
    // MARK: - P R O P E R T I E S / private / outlets
    // MARK: M E T H O D S / public
    func play() {
        radioPlayer.radioURL = urlBySoundQuality[soundQuality]!
        state = .loading
        radioPlayer.play()
    }
    func stop() {
        state = .stopping
        radioPlayer.stop()
        state = .idle
    }
    @objc func doNothing(){ // Needed to disable buttons on Lock Screen
    }
    
    // MARK: - M E T H O D S / public / actions
    // MARK: M E T H O D S / private
    private override init() {
        // default values:
        urlBySoundQuality = [SoundQuality.low    : URL(string: "http://radio.4duk.ru/4duk40.mp3")!, // http://radio.4duk.ru:80/4duk40.mp3
                             SoundQuality.middle : URL(string: "http://radio.4duk.ru/4duk64.mp3")!, // http://radio.4duk.ru:80/4duk64.mp3
                             SoundQuality.high   : URL(string: "http://radio.4duk.ru/4duk128.mp3")!, // http://radio.4duk.ru:80/4duk128.mp3
                             SoundQuality.highest: URL(string: "http://radio.4duk.ru/4duk256.mp3")!]  // http://radio.4duk.ru:80/4duk256.mp3
        soundQualityKey = "soundQuality"
        defaultSoundQuality = SoundQuality.middle
        soundQuality = defaultSoundQuality
        // last saved values:
        if let lastSavedQualityRawValue = UserDefaults.standard.object(forKey: soundQualityKey) as? Int {
            if let lastSavedQuality = SoundQuality(rawValue: lastSavedQualityRawValue) {
                soundQuality = lastSavedQuality // Установлено значение из UserDefaults, didSet из init'а вызван не будет
            }
        }
        // super:
        super.init()
        // delegate:
        radioPlayer.delegate = self
    }
    private func updateLockScreen(artist: String?, title: String?) {
        var nowPlayingInfo = [String : Any]()
        if let artist = artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        if let title = title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        let center = MPRemoteCommandCenter.shared()
        [center.pauseCommand,
         center.togglePlayPauseCommand,
         center.nextTrackCommand,
         center.previousTrackCommand,
         center.changeRepeatModeCommand,
         center.changeShuffleModeCommand,
         center.changePlaybackRateCommand,
         center.seekBackwardCommand,
         center.seekForwardCommand,
         center.skipBackwardCommand,
         center.skipForwardCommand,
         center.changePlaybackPositionCommand,
         center.ratingCommand,
         center.likeCommand,
         center.dislikeCommand,
         center.playCommand,
         center.stopCommand,
         center.bookmarkCommand].forEach {
            $0.addTarget(self, action: #selector(doNothing))
            $0.isEnabled = false
        }
    }
}

// MARK: - E X T / ChiplTuner : FRadioPlayerDelegate
extension ChiplRadioController: FRadioPlayerDelegate {
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) { // print("~ \(Date()) ~ \(self.className) ~ Player state = '\(state.description)'")
        switch player.state {
        case .error:
            self.state = .error
        case .loading:
            self.state = .loading
        case.loadingFinished:
            self.state = .playing
        default:
            loadingCountdown = nil
        }
    }
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        // print("~ \(Date()) ~ Playback state = '\(state.description)'")
    }
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        print("~ \(Date()) ~ Stream metadata = '\(artistName ?? "-")', '\(trackName ?? "-")'.")
        guard self.state != .stopping, player.state == .loadingFinished, player.playbackState == .playing else {
            return
        }
        var metadata: String = ""
        var metadataParts: [String] = []
        var currentArtist: String = ""
        var currentTitle: String = ""
        if artistName != nil {
            metadata = artistName!
        }
        if metadata == "" && trackName != nil { // Если artistName пустой, пробуем получить данные из trackName
            metadata = trackName!
        }
        if metadata.count > 0 {
             metadataParts = metadata.components(separatedBy: "/")
            if metadataParts.count > 0 {
                currentArtist = metadataParts[0]
                if metadataParts.count > 1 {
                    currentTitle = metadataParts[1]
                }
            }
        } else {
            print("~ \(Date()) ~ Не удалось прочитать метаданные из аудиопотока.")
        }
        guard let handler = metadataDidChangeHandler else {
            print("~ \(Date()) ~ Отсутствует обработчик обновления метаданных.")
            return
        }
        handler(currentArtist, currentTitle)
        updateLockScreen(artist: currentArtist, title: currentTitle)
    }
}
// MARK: -
enum SoundQuality: Int {
    case low = 40
    case middle = 64
    case high = 128
    case highest = 256
}
enum ChiplPlayerState {
    case idle
    case loading
    case error
    case playing
    case stopping
}
