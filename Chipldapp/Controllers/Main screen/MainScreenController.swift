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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillBackground()
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

    @IBAction func actionButtonPressed(_ sender: UIButton) {
        topView.removeSubviews()
        
        let randomIndex = Int.random(in: 0..<titles.count-1)
        fancyHeader = FancyHeader(title: titles[randomIndex], artist: artists[randomIndex], placeholder: "Чипльдук", displayArea: topView)
        fancyHeader!.showHeader()
    }
    
}

