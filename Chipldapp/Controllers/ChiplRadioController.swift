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
    var soundQuality: SoundQuality? = nil {
        didSet {
            guard let soundQuality = self.soundQuality else {
                print("~ \(Date()) ~ \(self.className) ~ Установлено качество: 'nil'. Обработчик смены качества не будет вызван, новое значение не будет сохранено.")
                return
            }
            print("~ \(Date()) ~ \(self.className) ~ Установлено качество: \(soundQuality). Соответствующий URL: \(String(describing: self.streamURL)).")
            if let handler = qualityDidChangeHandler {
                print("~ \(Date()) ~ \(self.className) ~ Запуск обработчика смены качества...")
                handler()
                print("~ \(Date()) ~ \(self.className) ~ ...обработчик выполнен.")
            }
            if oldValue != nil {
                let userDefaults = UserDefaults.standard
                userDefaults.set(soundQuality.rawValue, forKey: soundQualityKey)
                print("~ \(Date()) ~ \(self.className) ~ Новое значение качества сохранено в UserDefaults.")
            }
        }
    }
    var isPlaying: Bool {
        return radioPlayer.isPlaying
    }
    var metadataDidChangeHandler: ((_ currentArtist: String?,_ currentTitle: String?) -> ())? {
        didSet {
            guard let handler = metadataDidChangeHandler else {
                print("~ \(Date()) ~ \(self.className) ~ Не удалось назначить обработчик обновления метаданных.")
                return
            }
            print("~ \(Date()) ~ \(self.className) ~ Назначен обработчик обновления метаданных. Первый вызов обработчика...")
            handler(nil, nil)
            print("~ \(Date()) ~ \(self.className) ~ ...обработчик обновления метаданных выполнен.")
        }
    }
    var qualityDidChangeHandler: (()->())? {
        didSet {
            guard let handler = qualityDidChangeHandler else {
                return
            }
            print("~ \(Date()) ~ \(self.className) ~ Назначен обработчик изменения качества звука. Первый вызов обработчика...")
            handler()
            print("~ \(Date()) ~ \(self.className) ~ ...обработчик изменения качества звука выполнен.")
        }
    }
    
    // MARK: - P R O P E R T I E S / private
    private let radioPlayer = FRadioPlayer.shared
    private let defaultSoundQuality = SoundQuality.middle
    private let soundQualityKey = "soundQuality"
    private let urlBySoundQuality = [SoundQuality.low    : URL(string: "http://radio.4duk.ru:80/4duk40.mp3")!,
                                     SoundQuality.middle : URL(string: "http://radio.4duk.ru:80/4duk64.mp3")!,
                                     SoundQuality.high   : URL(string: "http://radio.4duk.ru:80/4duk128.mp3")!,
                                     SoundQuality.highest: URL(string: "http://radio.4duk.ru:80/4duk256.mp3")!]
    private var streamURL: URL? {
        let soundQuality = self.soundQuality ?? self.defaultSoundQuality
        return urlBySoundQuality[soundQuality]
    }
    
    // MARK: - P R O P E R T I E S / private / outlets
    // MARK: M E T H O D S / public
    func play() {
        guard let streamURL = streamURL else {
            print("~ \(Date()) ~ \(self.className) ~ Воспроизведение аудиопотока невозможно, отсутствует URL потока.")
            return
        }
        radioPlayer.radioURL = streamURL
        print("~ \(Date()) ~ \(self.className) ~ Воспроизводится аудиопоток '\(streamURL)'.")
        radioPlayer.play()
    }
    func stop() {
        print("~ \(Date()) ~ \(self.className) ~ Прекращение воспроизведения аудиопотока.")
        radioPlayer.stop()
    }
    @objc func doNothing(){
    }
    
    // MARK: - M E T H O D S / public / actions
    // MARK: M E T H O D S / private
    private override init() {
        super.init()
        loadStateFromUserDefaults()
        radioPlayer.delegate = self

        print("~ \(Date()) ~ \(self.className) ~ Завершение инициализации.")
    }
    private func loadStateFromUserDefaults() {
        print("~ \(Date()) ~ \(self.className) ~ Загрузка состояния приложения на момент его прошлого использования.")
        let userDefaults = UserDefaults.standard
        guard let lastSavedQualityRawValue = userDefaults.object(forKey: soundQualityKey) as? Int else {
            print("~ \(Date()) ~ \(self.className) ~ Не удалось загрузить последний сохранённый уровень качества. Будет использовано значение по умолчанию: '\(self.defaultSoundQuality)'.")
            self.soundQuality = self.defaultSoundQuality
            return
        }
        guard let lastSavedQuality = SoundQuality(rawValue: lastSavedQualityRawValue) else {
            print("~ \(Date()) ~ \(self.className) ~ Прочитано неккоректное значение уровня качества. Будет использовано значение по умолчанию: '\(self.defaultSoundQuality)'.")
            self.soundQuality = self.defaultSoundQuality
            return
        }
        print("~ \(Date()) ~ \(self.className) ~ Загружен последний сохранённый уровень качества: '\(lastSavedQuality)'.")
        self.soundQuality = lastSavedQuality
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
         center.bookmarkCommand,
         center.playCommand,
         center.stopCommand].forEach {
            $0.addTarget(self, action: #selector(doNothing))
            $0.isEnabled = false
        }
    }
}

// MARK: - E X T / ChiplTuner : FRadioPlayerDelegate
extension ChiplRadioController: FRadioPlayerDelegate {
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print("~ \(Date()) ~ \(self.className) ~ '\(state.description)'")
    }
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print("~ \(Date()) ~ \(self.className) ~ '\(state.description)'")
    }
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
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
            print("~ \(Date()) ~ \(self.className) ~ В эфире: '\(metadata)'.")
            metadataParts = metadata.components(separatedBy: "/")
            if metadataParts.count > 0 {
                currentArtist = metadata.components(separatedBy: "/")[0]
                if metadataParts.count > 1 {
                    currentTitle = metadata.components(separatedBy: "/")[1]
                }
            }
        } else {
            print("~ \(Date()) ~ \(self.className) ~ Не удалось прочитать метаданные из аудиопотока.")
        }
        guard let handler = metadataDidChangeHandler else {
            print("~ \(Date()) ~ \(self.className) ~ Отсутствует обработчик обновления метаданных.")
            return
        }
        handler(currentArtist, currentTitle) // FIXME: При включении радио до загрузки метаданных успевает вызваться обработчик и обновить заглушку. Это лишнее действие.
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
