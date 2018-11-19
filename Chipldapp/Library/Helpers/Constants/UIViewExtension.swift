//
//  UIViewExtension.swift
//  Chipldapp
//
//  Created by Mr.Б on 25/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

fileprivate let grayColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1) as CGColor
fileprivate let whiteColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) as CGColor

extension UIView {
    
    func addGradientLayer(rect: CGRect?, startColor: CGColor = grayColor, endColor: CGColor = whiteColor, startXY: CGPoint = CGPoint(x: 0, y: 0), endXY: CGPoint = CGPoint(x: 1, y: 1), atLevel level: UInt32 = 0) {
        let layerFrame = rect ?? self.bounds
        let layer = CAGradientLayer()
        layer.frame = layerFrame
        layer.colors = [startColor, endColor]
        layer.startPoint = startXY
        layer.endPoint = endXY
        self.layer.insertSublayer(layer, at: level)
    }
    
    func addShadow(color: CGColor = grayColor, radius: CGFloat = 4, opacity: Float = 0.9) {
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
    
    func removeSubviews() {
        self.subviews.forEach{ $0.removeFromSuperview() }
    }

    func fadeIn(_ duration: TimeInterval = 0.1, delay: TimeInterval = 0.2, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.1, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }

    func topY(byOwnCenterY ownCenterY: CGFloat) -> CGFloat {
        return ownCenterY - self.bounds.height / 2
    }
    
    func topY(byExternalHeight externalHeight: CGFloat) -> CGFloat {
        return externalHeight / 2 - self.bounds.height / 2
    }

    func leadingX(byOwnCenterX ownCenterX: CGFloat) -> CGFloat {
        return ownCenterX - self.bounds.width / 2
    }
    
    func leadingX(byExternalWidth externalWidth: CGFloat) -> CGFloat {
        return externalWidth / 2 - self.bounds.width / 2
    }
    
}
