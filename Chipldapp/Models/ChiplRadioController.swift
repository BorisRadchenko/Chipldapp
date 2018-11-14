//
//  ChiplTuner.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import Foundation
import FRadioPlayer

class ChiplRadioController: NSObject {
    // MARK: P R O P E R T I E S / public
    static let shared = ChiplRadioController()
    var soundQuality: SoundQuality? = nil {
        didSet {
            guard let soundQuality = self.soundQuality else {
                print(" = = = [\(self.className)] Установлено качество: 'nil'. Обработчик смены качества не будет вызван, новое значение не будет сохранено.")
                return
            }
            print(" = = = [\(self.className)] Установлено качество: \(soundQuality). Соответствующий URL: \(String(describing: self.streamURL)).")
            if let handler = qualityDidChangeHandler {
                print(" = = = [\(self.className)] Запуск обработчика смены качества...")
                handler()
                print(" = = = [\(self.className)] ...обработчик выполнен.")
            }
            if oldValue != nil {
                let userDefaults = UserDefaults.standard
                userDefaults.set(soundQuality.rawValue, forKey: soundQualityKey)
                print(" = = = [\(self.className)] Новое значение качества сохранено в UserDefaults.")
            }
        }
    }
    var isPlaying: Bool {
        return radioPlayer.isPlaying
    }
    var metadataDidChangeHandler: ((_ currentArtist: String?,_ currentTitle: String?) -> ())? {
        didSet {
            guard let handler = metadataDidChangeHandler else {
                print(" = = = [\(self.className)] Не удалось назначить обработчик обновления метаданных.")
                return
            }
            print(" = = = [\(self.className)] Назначен обработчик обновления метаданных. Первый вызов обработчика...")
            handler(nil, nil)
            print(" = = = [\(self.className)] ...обработчик обновления метаданных выполнен.")
        }
    }
    var qualityDidChangeHandler: (()->())? {
        didSet {
            guard let handler = qualityDidChangeHandler else {
                return
            }
            print(" = = = [\(self.className)] Назначен обработчик изменения качества звука. Первый вызов обработчика...")
            handler()
            print(" = = = [\(self.className)] ...обработчик изменения качества звука выполнен.")
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
            print(" = = = [\(self.className)] Воспроизведение аудиопотока невозможно, отсутствует URL потока.")
            return
        }
        radioPlayer.radioURL = streamURL
        print(" = = = [\(self.className)] Воспроизводится аудиопоток '\(streamURL)'.")
        radioPlayer.play()
    }
    func stop() {
        print(" = = = [\(self.className)] Прекращение воспроизведения аудиопотока.")
        radioPlayer.stop()
    }
    
    // MARK: - M E T H O D S / public / actions
    // MARK: M E T H O D S / private
    private override init() {
        super.init()
        loadStateFromUserDefaults()
        radioPlayer.delegate = self
        print(" = = = [\(self.className)] Завершение инициализации.")
    }
    private func loadStateFromUserDefaults() {
        print(" = = = [\(self.className)] Загрузка состояния приложения на момент его прошлого использования.")
        let userDefaults = UserDefaults.standard
        guard let lastSavedQualityRawValue = userDefaults.object(forKey: soundQualityKey) as? Int else {
            print(" = = = [\(self.className)] Не удалось загрузить последний сохранённый уровень качества. Будет использовано значение по умолчанию: '\(self.defaultSoundQuality)'.")
            self.soundQuality = self.defaultSoundQuality
            return
        }
        guard let lastSavedQuality = SoundQuality(rawValue: lastSavedQualityRawValue) else {
            print(" = = = [\(self.className)] Прочитано неккоректное значение уровня качества. Будет использовано значение по умолчанию: '\(self.defaultSoundQuality)'.")
            self.soundQuality = self.defaultSoundQuality
            return
        }
        print(" = = = [\(self.className)] Загружен последний сохранённый уровень качества: '\(lastSavedQuality)'.")
        self.soundQuality = lastSavedQuality
    }
}

// MARK: - E X T / ChiplTuner : FRadioPlayerDelegate
extension ChiplRadioController: FRadioPlayerDelegate {
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        print(" = = = [\(self.className)] '\(state.description)'")
    }
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        print(" = = = [\(self.className)] '\(state.description)'")
    }
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        guard let metadata = artistName else { // FIXME: Неплохо бы подстраховаться: если artistName пустой, попробовать получить данные из trackName
            print(" = = = [\(self.className)] Не удалось прочитать метаданные из аудиопотока.")
            return
        }
        guard metadata.count > 0 else {
            print(" = = = [\(self.className)] Метаданные отсутствуют.")
            return
        }
        print(" = = = [\(self.className)] В эфире: '\(metadata)'.")
        let currentArtist = metadata.components(separatedBy: "/")[0] // FIXME: Нужна защита от пустых / отсутствующих значений
        let currentTitle = metadata.components(separatedBy: "/")[1]
        guard let handler = metadataDidChangeHandler else {
            print(" = = = [\(self.className)] Отсутствует обработчик обновления метаданных.")
            return
        }
        handler(currentArtist, currentTitle)
        }
    }
// MARK: -
enum SoundQuality: Int {
    case low = 40
    case middle = 64
    case high = 128
    case highest = 256
}