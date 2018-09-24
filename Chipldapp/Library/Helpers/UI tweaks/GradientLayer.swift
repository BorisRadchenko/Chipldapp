//
//  GradientLayer.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

func putGradientLayer(with startColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), and endColor: CGColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), from startPoint: CGPoint = CGPoint(x: 0, y: 0), and endPoint: CGPoint = CGPoint(x: 1, y: 1), to view: UIView, at level: UInt32 = 0, using bounds: CGRect) {
    let layer = CAGradientLayer()
    layer.frame = bounds
    layer.colors = [startColor, endColor]
    layer.startPoint = startPoint
    layer.endPoint = endPoint
    view.layer.insertSublayer(layer, at: level)
}
