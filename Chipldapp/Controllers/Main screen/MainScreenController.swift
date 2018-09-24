//
//  ViewController.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class MainScreenController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = view.bounds
        let topBounds = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height * 0.6)
        let bottomBounds = CGRect(x: bounds.minX, y: bounds.height * 0.7, width: bounds.width, height: bounds.maxY - bounds.height * 0.7)
        putGradientLayer(with: #colorLiteral(red: 1, green: 0.7450980392, blue: 0.4509803922, alpha: 1), and: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), from: CGPoint(x: 0.5, y: 0), and: CGPoint(x: 0.5, y: 0.6), to: view, at: 0, using: topBounds)
        putGradientLayer(with: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), and: #colorLiteral(red: 1, green: 0.7450980392, blue: 0.4509803922, alpha: 1), from: CGPoint(x: 0.5, y: 0.7), and: CGPoint(x: 0.5, y: 1), to: view, at: 1, using: bottomBounds)
    }


    
}

