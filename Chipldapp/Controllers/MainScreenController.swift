//
//  ViewController.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit
import MediaPlayer

final class MainScreenController: UIViewController {
    
    // MARK: - Properties / public
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let tunerController: ChiplRadioController = ChiplRadioController.shared
    
    // MARK: - Properties / private
    
    private var qualityByButton: [UIButton:SoundQuality] = [:]
    
    private var mpVolumeSlider: UISlider?
    
    // MARK: - Properties / private / outlets
    
    @IBOutlet private weak var switchOnOffButton: UIButton!
    
    @IBOutlet private var qualityButtons: [UIButton]!
    
    @IBOutlet private weak var middleQualityButton: UIButton!
    
    @IBOutlet private weak var highQualityButton: UIButton!
    
    @IBOutlet private weak var highestQualityButton: UIButton!
    
    @IBOutlet private weak var topView: UIView!
    
    @IBOutlet private weak var volumeParentView: UIView!
    
    // MARK: - Methods / public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        switch tunerController.state {
        case .idle:
            showPlaceholder()
        case .playing:
            let artist = tunerController.currentArtist ?? ""
            let title = tunerController.currentTitle ?? "Неизвестно, что играет :-("
            showHeader(title: title, artist: artist)
        default:
            break
        }
    }
    
    // MARK: - Methods / public / actions
    
    @IBAction private func switchOnOffPressed(_ sender: UIButton) {
        switch tunerController.state {
        case .idle:
            tunerController.play()
        case .loading:
            tunerController.stop()
        case .error:
            tunerController.play()
        case .playing:
            tunerController.stop()
        case .stopping:
            tunerController.play()
        }
    }
    
    @IBAction func switchQualityPressed(_ sender: UIButton) {
        guard let selectedQuality = qualityByButton[sender] else { return }
        guard selectedQuality != tunerController.soundQuality else { return }
        tunerController.soundQuality = selectedQuality
    }
    
    // MARK: - Methods / private
    
    private func setup() {
        qualityByButton = [middleQualityButton  : SoundQuality.middle,
                           highQualityButton    : SoundQuality.high,
                           highestQualityButton : SoundQuality.highest]
        fillBackground()
        setupVolumeSlider()
        decorateControls()
        displayCurrentQuality()
        showPlaceholder()
        tunerController.qualityDidChangeHandler = displayCurrentQuality
        tunerController.playbackStateDidChangeHandler = displayCurrentPlaybackState
        tunerController.metadataDidChangeHandler = displayCurrentMetadata
        LockScreen.setup()
    }
    
    private func decorateControls() {
        volumeParentView.backgroundColor = .noColor
        middleQualityButton.superview?.backgroundColor = .noColor
        middleQualityButton.backgroundColor = .noColor
        highQualityButton.backgroundColor = .noColor
        highestQualityButton.backgroundColor = .noColor
        switchOnOffButton.backgroundColor = .noColor
        switchOnOffButton.addShadow(color: .shadowColor, radius: 3, opacity: 0.7)
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
        // Note: This slider implementation uses a MPVolumeView. The volume slider only works in devices, not the simulator.
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
        mpVolumeSlider.tintColor = .blackColor
    }
    
    private func displayCurrentQuality() {
//        print("🔔 Displaying current quality...")
        let currentQuality = tunerController.soundQuality
        let foundButton = qualityByButton.filter{ $0.value == currentQuality }.keys.first
        guard let currentQualityButton = foundButton else { return }
        qualityButtons.filter{ $0 != currentQualityButton }.forEach{ markAsUnselected($0) }
        markAsSelected(currentQualityButton)
    }
    
    private func markAsUnselected(_ button: UIButton) {
        button.backgroundColor = button.backgroundColor!.withAlphaComponent(0)
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            button.setAttributedTitle(attributes, for: .normal)
            button.titleLabel?.lineBreakMode = .byClipping
        }
    }
    
    private func markAsSelected(_ button: UIButton) {
        button.backgroundColor = .highlitedButtonColor
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            button.setAttributedTitle(attributes, for: .normal)
            button.titleLabel?.lineBreakMode = .byClipping
        }
    }
    
    private func displayCurrentPlaybackState() {
        switch tunerController.state {
        case .idle:
            switchOnOffButton.setImage(UIImage(named: "playButton"), for: .normal)
            showPlaceholder()
            LockScreen.clear()
            dismiss(animated: true, completion: nil)
        case .loading:
            switchOnOffButton.setImage(UIImage(named: "stopButton"), for: .normal)
        case .error:
            switchOnOffButton.setImage(UIImage(named: "playButton"), for: .normal)
            LockScreen.clear()
            performSegue(withIdentifier: "errorSegue", sender: self)
            showPlaceholder()
        case .playing:
            switchOnOffButton.setImage(UIImage(named: "stopButton"), for: .normal)
            dismiss(animated: true, completion: nil)
        case .stopping:
            switchOnOffButton.setImage(UIImage(named: "playButton"), for: .normal)
        }
    }
    
    private func displayCurrentMetadata() {
        let artist = tunerController.currentArtist ?? ""
        let title = tunerController.currentTitle ?? "Неизвестно, что играет :-("
        showHeader(title: title, artist: artist)
        LockScreen.updateNowPlayingInfo(artist: artist, title: title)
    }
    
    private func showHeader(title: String, artist: String) {
        let placeholder = "Чипльдук"
        topView.fadeOut(completion: {
            (finished: Bool) -> () in
            self.topView.removeSubviews()
            let fancyHeader = FancyHeader(title: title, artist: artist, placeholderText: placeholder, parentView: self.topView)
            fancyHeader.showTitleAndArtist()
            self.topView.fadeIn()
        })
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
    
        
    // MARK: - TEST:
    
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
//        showError()
    }
    
}
