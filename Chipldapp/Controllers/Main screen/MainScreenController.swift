//
//  ViewController.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class MainScreenController: UIViewController {

    @IBOutlet weak var onOffButton: UIButton!
    @IBOutlet var qualityButtons: [UIButton]!
    @IBOutlet weak var topView: UIView!
    let tuner: ChiplTuner = ChiplTuner.shared
    var isOn: Bool = false
    
    var fancyHeader: FancyHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillBackground()
        onOffButton.addShadow(color: shadowColor, radius: 3, opacity: 0.7)
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
        qualityButtons.filter{ $0 != sender }.forEach{ markAsUnselected($0) }
        markAsSelected(sender)
    }
    
    @IBAction func onOffButtonPressed(_ sender: UIButton) {
        if isOn {
            tuner.stop()
            sender.setImage(UIImage(named: "playButton"), for: .normal)
        } else {
            tuner.streamQuality = .highest
            tuner.play()
            sender.setImage(UIImage(named: "stopButton"), for: .normal)
        }
        isOn = !isOn
        showFakeHeader()
    }
    
    func showFakeHeader(){
        topView.removeSubviews()
        
        let randomIndex = Int.random(in: 0..<titles.count-1)
        fancyHeader = FancyHeader(title: titles[randomIndex], artist: artists[randomIndex], placeholder: "Чипльдук", displayArea: topView)
        fancyHeader!.showHeader()
    }
    
}
