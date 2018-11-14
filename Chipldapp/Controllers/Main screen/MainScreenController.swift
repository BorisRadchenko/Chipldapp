//
//  ViewController.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

// MARK - P R O P E R T I E S / public
// MARK - P R O P E R T I E S / private
// MARK - P R O P E R T I E S / private / outlets
// MARK - M E T H O D S / public
// MARK - M E T H O D S / public / actions
// MARK - M E T H O D S / private

import UIKit
import MediaPlayer

class MainScreenController: UIViewController {
    // MARK: - P R O P E R T I E S / public
    // MARK: P R O P E R T I E S / private
    private let tuner: ChiplRadioController = ChiplRadioController.shared
    private var isOn: Bool = false // FIXME: Перенести в ChiplTuner в форме дженерика
    private var qualityByButton: [UIButton:SoundQuality] = [:]
    private var fancyHeader: FancyHeader?
    private var mpVolumeSlider: UISlider?
    
    // MARK: - P R O P E R T I E S / private / outlets
    @IBOutlet private weak var switchOnOffButton: UIButton!
    @IBOutlet private var qualityButtons: [UIButton]!
    @IBOutlet private weak var middleQualityButton: UIButton!
    @IBOutlet private weak var highQualityButton: UIButton!
    @IBOutlet private weak var highestQualityButton: UIButton!
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var volumeParentView: UIView!
    
    // MARK: - M E T H O D S / public
    override func viewDidLoad() {
        super.viewDidLoad()
        qualityByButton = [middleQualityButton  : SoundQuality.middle,
                           highQualityButton    : SoundQuality.high,
                           highestQualityButton : SoundQuality.highest]
        fillBackground()
        switchOnOffButton.addShadow(color: shadowColor, radius: 3, opacity: 0.7)
        setupVolumeSlider()
        tuner.qualityDidChangeHandler = displayCurrentQuality
        tuner.metadataDidChangeHandler = showHeader
        // showHeader()
    }
    // MARK: - M E T H O D S / public / actions
    @IBAction func switchOnOffPressed(_ sender: UIButton) { // FIXME: Заменить на player.togglePlaying()
        // if isOn {
        if tuner.isPlaying { // FIXME: 1
            tuner.stop()
            sender.setImage(UIImage(named: "playButton"), for: .normal)
            showHeader()
        } else {
            tuner.play()
            sender.setImage(UIImage(named: "stopButton"), for: .normal)
        }
        isOn = !isOn
    }
    @IBAction func switchQualityPressed(_ sender: UIButton) {
        // 1) Узнать выбранное качество исходя из нажатой кнопки
        guard let selectedQuality = qualityByButton[sender] else {
            print(" = = = [\(self.className)] Невозможно определить уровень качества звука по нажатой кнопке.")
            return
        }
        guard selectedQuality != tuner.soundQuality else {
        // 2) Если выбранное качество совпадает с текущим - покинуть метод
            print(" = = = [\(self.className)] Выбранный уровень качества звука не отличается от текущего.")
            return
        }
        // 3) Установить новое значение качества
        tuner.soundQuality = selectedQuality
        // 4) Перезапустить приёмник
        if isOn {
            tuner.stop()
            tuner.play()
        }
    }
    // MARK: - M E T H O D S / private
    private func displayCurrentQuality() {
        // 1) Зная tuner.streamQuality, получить соответствующую кнопку
        let foundButton = qualityByButton.filter{ $0.value == tuner.soundQuality }.keys.first
        guard let currentQualityButton = foundButton else {
            print(" = = = [\(self.className)] Не удалось обнаружить кнопку, соответствующую заданному уровню качества (\(tuner.soundQuality)).")
            return
        }
        // 2) эту кнопку пометить как выбранную, остальные - сбросить
        qualityButtons.filter{ $0 != currentQualityButton }.forEach{ markAsUnselected($0) }
        print(" = = = [\(self.className)] Снято выделение остальных кнопок качества.")
        markAsSelected(currentQualityButton)
        print(" = = = [\(self.className)] Выделена кнопка, соответствующая текущему уровню качества.")
    }
    private func showHeader(currentArtist: String? = nil, currentTitle: String? = nil) { // FIXME: Перенести сюда плейсхолдер
        topView.removeSubviews()
        fancyHeader = FancyHeader(title: currentTitle, artist: currentArtist, placeholder: "Чипльдук", displayArea: topView)
        fancyHeader!.show()
    }
    private func markAsSelected(_ button: UIButton) {
        button.backgroundColor = highlitedButtonColor
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            button.setAttributedTitle(attributes, for: .normal)
        }
    }
    private func markAsUnselected(_ button: UIButton) {
        button.backgroundColor = button.backgroundColor!.withAlphaComponent(0)
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            button.setAttributedTitle(attributes, for: .normal)
        }
    }
    private func fillBackground() {
        let bounds = view.bounds
        let topBounds = CGRect(x: bounds.minX,
                               y: bounds.minY,
                               width: bounds.width,
                               height: bounds.height * 0.6)
        let bottomBounds = CGRect(x: bounds.minX,
                                  y: bounds.height * 0.7,
                                  width: bounds.width,
                                  height: bounds.maxY - bounds.height * 0.7)
        view.addGradientLayer(rect: topBounds, startColor: gradientEdgeColor, endColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), startXY: CGPoint(x: 0, y: 0), endXY: CGPoint(x: 0, y: 0.6), atLevel: 0)
        view.addGradientLayer(rect: bottomBounds, startColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), endColor: gradientEdgeColor, startXY: CGPoint(x: 0, y: 0.62), endXY: CGPoint(x: 0, y: 1), atLevel: 1)
    }
    private func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        for subview in MPVolumeView().subviews {
            guard let volumeSlider = subview as? UISlider else { continue }
            mpVolumeSlider = volumeSlider
        }
        guard let mpVolumeSlider = mpVolumeSlider else { return }
        volumeParentView.addSubview(mpVolumeSlider)
        mpVolumeSlider.translatesAutoresizingMaskIntoConstraints = false
        mpVolumeSlider.leftAnchor.constraint(equalTo: volumeParentView.leftAnchor).isActive = true
        mpVolumeSlider.rightAnchor.constraint(equalTo: volumeParentView.rightAnchor).isActive = true
        mpVolumeSlider.centerYAnchor.constraint(equalTo: volumeParentView.centerYAnchor).isActive = true
        mpVolumeSlider.setThumbImage(#imageLiteral(resourceName: "speakerSign"), for: .normal)
        mpVolumeSlider.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
