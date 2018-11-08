//
//  ViewController.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit
import MediaPlayer

class MainScreenController: UIViewController {

    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet var qualityButtons: [UIButton]!
    @IBOutlet weak var middleQualityButton: UIButton!
    @IBOutlet weak var highQualityButton: UIButton!
    @IBOutlet weak var highestQualityButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var volumeParentView: UIView!
    
    let tuner: ChiplTuner = ChiplTuner.shared
    var buttonsQuality: [UIButton:StreamQuality]?
    var isOn: Bool = false
    
    var fancyHeader: FancyHeader?

    var mpVolumeSlider: UISlider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tuner.showTitleHandler = showHeader
        fillBackground()
        onOffButton.addShadow(color: shadowColor, radius: 3, opacity: 0.7)
        buttonsQuality = [middleQualityButton  : StreamQuality.middle,
                          highQualityButton    : StreamQuality.high,
                          highestQualityButton : StreamQuality.highest]
        setupVolumeSlider()
        showHeader()
    }

    func fillBackground() {
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

    func markAsSelected(_ button: UIButton) {
        button.backgroundColor = highlitedButtonColor
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            button.setAttributedTitle(attributes, for: .normal)
        }
    }
    
    func markAsUnselected(_ button: UIButton) {
        button.backgroundColor = button.backgroundColor!.withAlphaComponent(0)
        if let text = button.titleLabel!.text {
            let attributes = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            button.setAttributedTitle(attributes, for: .normal)
        }
    }
    
    @IBAction func setChosenQualityAction(_ sender: UIButton) {
        guard tuner.streamQuality != buttonsQuality![sender]! else {
            return
        }
        qualityButtons.filter{ $0 != sender }.forEach{ markAsUnselected($0) }
        markAsSelected(sender)
        tuner.streamQuality = buttonsQuality![sender]!
        if isOn {
            tuner.stop()
            tuner.play()
        }
    }
    
    @IBAction func onOffButtonPressed(_ sender: UIButton) {
        if isOn {
            tuner.stop()
            sender.setImage(UIImage(named: "playButton"), for: .normal)
            tuner.title = ""
            tuner.artist = ""
            showHeader()
        } else {
            tuner.play()
            sender.setImage(UIImage(named: "stopButton"), for: .normal)
        }
        isOn = !isOn
        // showFakeHeader()
    }
    
    func showFakeHeader(){
        topView.removeSubviews()
        
        let randomIndex = Int.random(in: 0..<titles.count-1)
        fancyHeader = FancyHeader(title: titles[randomIndex], artist: artists[randomIndex], placeholder: "Чипльдук", displayArea: topView)
        fancyHeader!.showHeader()
    }
    
    func showHeader() {
        topView.removeSubviews()
        fancyHeader = FancyHeader(title: tuner.title, artist: tuner.artist, placeholder: "Чипльдук", displayArea: topView)
        fancyHeader!.showHeader()
    }
    
    func setupVolumeSlider() {
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

