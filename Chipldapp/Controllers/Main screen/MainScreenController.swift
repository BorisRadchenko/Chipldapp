//
//  ViewController.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class MainScreenController: UIViewController {

    @IBOutlet weak var topView: UIView!
    var fancyHeader: FancyHeader?
    let titles = ["Рейкьявик",
        "Baby (One More Time)", // Обычное название трека
        "St Germain", // Нет исполнителя
        "Belly Bossanova",
        "A Way Too Long And Verbose Title", // Длинное название
        "The Distant and Mechanised Glow of Eastern European Dance Parties", // Слишком длинное название
        "6&5", // Очень короткое название
        "", // Нет названия
        "Obsessed By (Feat. M. Of iamthemorning)"]  // Название с очень длинными словами
    let artists = ["Маша и медведи",
                   "Britney Spears",
                   "",
                   "Frank Popp Ensemble",
                   "Some Indie Pop Band featuring Some Guest Singer",
                   "65daysofstatic",
                   "Vasudeva",
                   "Homer J. Simpson",
                   "IAmWaitingForYouLastSummer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paintBackgroundGradient()
    }

    func paintBackgroundGradient() {
        let bounds = view.bounds
        let topBounds = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height * 0.6)
        let bottomBounds = CGRect(x: bounds.minX, y: bounds.height * 0.7, width: bounds.width, height: bounds.maxY - bounds.height * 0.7)
        putGradientLayer(with: #colorLiteral(red: 1, green: 0.7450980392, blue: 0.4509803922, alpha: 1), and: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), from: CGPoint(x: 0.5, y: 0), and: CGPoint(x: 0.5, y: 0.6), to: view, at: 0, using: topBounds)
        putGradientLayer(with: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), and: #colorLiteral(red: 1, green: 0.7450980392, blue: 0.4509803922, alpha: 1), from: CGPoint(x: 0.5, y: 0.7), and: CGPoint(x: 0.5, y: 1), to: view, at: 1, using: bottomBounds)
    }

    @IBAction func actionButtonPressed(_ sender: UIButton) {
        removeAllSubviews(from: topView)
        let randomIndex = Int.random(in: 0..<titles.count-1)
        fancyHeader = FancyHeader(title: titles[randomIndex], artist: artists[randomIndex], placeholder: "Чипльдук", displayArea: topView)
        
        if fancyHeader!.hasEnoughDisplayAreaSize() {
            print("'fancyHeader' has enough display area size (\(topView.bounds.width) x \(topView.bounds.height))")
        }
        
//        fancyHeader!.showArtist()
//        fancyHeader!.showPlaceholder()
//        fancyHeader!.placeHeader()
        fancyHeader!.prepareTitleHeader()
    }
    
}

