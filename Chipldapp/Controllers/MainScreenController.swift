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
    private let tunerController: ChiplRadioController = ChiplRadioController.shared
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
        switchOnOffButton.addShadow(color: .shadowColor, radius: 3, opacity: 0.7)
        setupVolumeSlider()
        tunerController.qualityDidChangeHandler = displayCurrentQuality
        tunerController.metadataDidChangeHandler = showHeader
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    // MARK: - M E T H O D S / public / actions
    @IBAction func switchOnOffPressed(_ sender: UIButton) {
        if tunerController.isPlaying {
            tunerController.stop()
            sender.setImage(UIImage(named: "playButton"), for: .normal)
            showHeader() // FIXME: Разве при остановке воспроизведения автоматом не запускается обработчик смены метаданных?
        } else {
            tunerController.play()
            sender.setImage(UIImage(named: "stopButton"), for: .normal)
        }
    }
    @IBAction func switchQualityPressed(_ sender: UIButton) {
        // 1) Узнать выбранное качество исходя из нажатой кнопки
        guard let selectedQuality = qualityByButton[sender] else {
            print("~ \(Date()) ~ \(self.className) ~ Невозможно определить уровень качества звука по нажатой кнопке.")
            return
        }
        guard selectedQuality != tunerController.soundQuality else {
        // 2) Если выбранное качество совпадает с текущим - покинуть метод
            print("~ \(Date()) ~ \(self.className) ~ Выбранный уровень качества звука не отличается от текущего.")
            return
        }
        // 3) Установить новое значение качества
        tunerController.soundQuality = selectedQuality
        // 4) Перезапустить приёмник
        if tunerController.isPlaying {
            tunerController.stop()
            tunerController.play()
        }
    }
    // MARK: - M E T H O D S / private
    private func displayCurrentQuality() {
        // 1) Зная tuner.streamQuality, получить соответствующую кнопку
        let foundButton = qualityByButton.filter{ $0.value == tunerController.soundQuality }.keys.first
        guard let currentQualityButton = foundButton else {
            print("~ \(Date()) ~ \(self.className) ~ Не удалось обнаружить кнопку, соответствующую заданному уровню качества (\(tunerController.soundQuality)).")
            return
        }
        // 2) эту кнопку пометить как выбранную, остальные - сбросить
        qualityButtons.filter{ $0 != currentQualityButton }.forEach{ markAsUnselected($0) }
        print("~ \(Date()) ~ \(self.className) ~ Снято выделение остальных кнопок качества.")
        markAsSelected(currentQualityButton)
        print("~ \(Date()) ~ \(self.className) ~ Выделена кнопка, соответствующая текущему уровню качества.")
    }
    private func showHeader(currentArtist: String? = nil, currentTitle: String? = nil) {
        let placeholder = "Чипльдук"
        topView.fadeOut(completion: {
            (finished: Bool) -> () in
            self.topView.removeSubviews()
            self.fancyHeader = FancyHeader(title: currentTitle, artist: currentArtist, placeholder: placeholder, displayArea: self.topView)
            self.fancyHeader!.show()
            self.topView.fadeIn()
        })
    }
    private func markAsSelected(_ button: UIButton) {
        button.backgroundColor = .highlitedButtonColor
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
        view.addGradientLayer(rect: topBounds, startColor: .gradientEdgeColor, endColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), startXY: CGPoint(x: 0, y: 0), endXY: CGPoint(x: 0, y: 0.6), atLevel: 0)
        view.addGradientLayer(rect: bottomBounds, startColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), endColor: .gradientEdgeColor, startXY: CGPoint(x: 0, y: 0.62), endXY: CGPoint(x: 0, y: 1), atLevel: 1)
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
    // MARK: - T E S T:
    var mockIndex = 0
    @IBAction func mockHeadersButtonPushed(_ sender: UIButton) {
        let placeholder = "Чипльдук"
        topView.fadeOut(completion: {
            (finished: Bool) -> () in
            self.topView.removeSubviews()
            self.fancyHeader = FancyHeader(title: titles[self.mockIndex],
                                      artist: artists[self.mockIndex],
                                      placeholder: placeholder,
                                      displayArea: self.topView)
            self.fancyHeader!.show()
            self.topView.fadeIn()
            self.mockIndex = self.mockIndex == titles.count - 1 ? 0 : self.mockIndex + 1
        })
    }
}
