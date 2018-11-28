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
    override var prefersStatusBarHidden: Bool {
        return true
    }
    // MARK: P R O P E R T I E S / private
    private let tunerController: ChiplRadioController = ChiplRadioController.shared
    private var qualityByButton: [UIButton:SoundQuality] = [:]
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
        setup()
    }

    // MARK: - M E T H O D S / public / actions
    @IBAction func switchOnOffPressed(_ sender: UIButton) {
        switch tunerController.state {
        case .idle:
            tunerController.play()
        case .loading:
            tunerController.stop()
            showPlaceholder()
        case .error:
            tunerController.play()
        case .playing:
            tunerController.stop()
            showPlaceholder()
        case .stopping:
            tunerController.play()
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
        if tunerController.state == .playing { // FIXME: Предусмотреть и другие состояния
            tunerController.stop()
            tunerController.play()
        }
    }
    
    // MARK: - M E T H O D S / private
    private func setup() {
        volumeParentView.backgroundColor = .noColor
        middleQualityButton.superview?.backgroundColor = .noColor
        middleQualityButton.backgroundColor = .noColor
        highQualityButton.backgroundColor = .noColor
        highestQualityButton.backgroundColor = .noColor
        switchOnOffButton.backgroundColor = .noColor
        
        qualityByButton = [middleQualityButton  : SoundQuality.middle,
                           highQualityButton    : SoundQuality.high,
                           highestQualityButton : SoundQuality.highest]
        fillBackground()
        switchOnOffButton.addShadow(color: .shadowColor, radius: 3, opacity: 0.7)
        setupVolumeSlider()
        tunerController.qualityDidChangeHandler = displayCurrentQuality
        displayCurrentQuality() // Показать исходный уровень качества
        tunerController.metadataDidChangeHandler = showHeader // TODO: [ 1 ]
        showPlaceholder() // Показать заглушку, пока ещё нет данных о песне и исполнителе
        tunerController.errorDidHappenHandler = showError
        tunerController.playbackStateDidChangeHandler = displayCurrentPlaybackState
    }
    private func displayCurrentPlaybackState() {
        print("ОБРАБОТЧИК НОВОГО СОСТОЯНИЯ: \(tunerController.state)")
        switch tunerController.state {
        case .idle:
            switchOnOffButton.setImage(UIImage(named: "playButton"), for: .normal)
        case .loading:
            switchOnOffButton.setImage(UIImage(named: "stopButton"), for: .normal)
        case .error:
            switchOnOffButton.setImage(UIImage(named: "playButton"), for: .normal)
        case .playing:
            switchOnOffButton.setImage(UIImage(named: "stopButton"), for: .normal)
        case .stopping:
            switchOnOffButton.setImage(UIImage(named: "playButton"), for: .normal)
        }
    }
    private func displayCurrentQuality() {
        let foundButton = qualityByButton.filter{ $0.value == tunerController.soundQuality }.keys.first // По tunerController.soundQuality получить соответствующую кнопку
        guard let currentQualityButton = foundButton else { // Не удалось обнаружить кнопку, соответствующую заданному уровню качества
            return
        }
        qualityButtons.filter{ $0 != currentQualityButton }.forEach{ markAsUnselected($0) } // Снято выделение остальных кнопок качества
        markAsSelected(currentQualityButton) // Выделена кнопка, соответствующая текущему уровню качества
    }
    private func showPlaceholder() {
        let placeholder = "Чипльдук"
        topView.fadeOut(completion: {
            (finished: Bool) -> () in
            self.topView.removeSubviews()
            let fancyHeader = FancyHeader(placeholderText: placeholder, parentView: self.topView)
            fancyHeader.showPlaceholder()
            self.topView.fadeIn()
        })
    }
    private func showHeader(currentArtist: String? = nil, currentTitle: String? = nil) {
        let placeholder = "Чипльдук"
        topView.fadeOut(completion: {
            (finished: Bool) -> () in
            self.topView.removeSubviews()
            let fancyHeader = FancyHeader(title: currentTitle, artist: currentArtist, placeholderText: placeholder, parentView: self.topView)
            fancyHeader.showTitleAndArtist()
            self.topView.fadeIn()
        })
    }
    private func markAsSelected(_ button: UIButton) {
        button.backgroundColor = .highlitedButtonColor
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            button.setAttributedTitle(attributes, for: .normal)
            button.titleLabel?.lineBreakMode = .byClipping
        }
    }
    private func markAsUnselected(_ button: UIButton) {
        button.backgroundColor = button.backgroundColor!.withAlphaComponent(0)
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            button.setAttributedTitle(attributes, for: .normal)
            button.titleLabel?.lineBreakMode = .byClipping
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
        view.addGradientLayer(rect: topBounds, startColor: .gradientEdgeColor, endColor: .whiteColor, startXY: CGPoint(x: 0, y: 0), endXY: CGPoint(x: 0, y: 0.6), atLevel: 0)
        view.addGradientLayer(rect: bottomBounds, startColor: .whiteColor, endColor: .gradientEdgeColor, startXY: CGPoint(x: 0, y: 0.62), endXY: CGPoint(x: 0, y: 1), atLevel: 1)
    }
    private func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        for subview in MPVolumeView().subviews {
            guard let volumeSlider = subview as? UISlider else { continue }
            mpVolumeSlider = volumeSlider // FIXME: Кажется, это здесь лишнее
        }
        guard let mpVolumeSlider = mpVolumeSlider else { return }
        volumeParentView.addSubview(mpVolumeSlider)
        mpVolumeSlider.translatesAutoresizingMaskIntoConstraints = false
        mpVolumeSlider.leftAnchor.constraint(equalTo: volumeParentView.leftAnchor).isActive = true
        mpVolumeSlider.rightAnchor.constraint(equalTo: volumeParentView.rightAnchor).isActive = true
        mpVolumeSlider.centerYAnchor.constraint(equalTo: volumeParentView.centerYAnchor).isActive = true
        mpVolumeSlider.setThumbImage(#imageLiteral(resourceName: "speakerSign"), for: .normal)
        mpVolumeSlider.tintColor = .blackColor
    }
    // MARK: - T E S T:
    var mockIndex = 0
    @IBAction func mockHeadersButtonPushed(_ sender: UIButton) {
        let placeholder = "Чипльдук"
        topView.fadeOut(completion: {
            (finished: Bool) -> () in
            self.topView.removeSubviews()
            let fancyHeader = FancyHeader(title: titles[self.mockIndex],
                                          artist: artists[self.mockIndex],
                                          placeholderText: placeholder,
                                          parentView: self.topView)
            fancyHeader.showTitleAndArtist()
            self.topView.fadeIn()
            self.mockIndex = self.mockIndex == titles.count - 1 ? 0 : self.mockIndex + 1
        })
    }
    @IBAction func crashButtonPressed(_ sender: UIButton) {
        showError()
    }
    private func showError() {
        performSegue(withIdentifier: "errorSegue", sender: self)
        showPlaceholder()
    }
    
}
