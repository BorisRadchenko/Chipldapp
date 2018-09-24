//
//  Shadow.swift
//  Chipldapp
//
//  Created by Mr.Б on 24/09/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

func addShadow(on view: UIView, using color: CGColor, and opacity: Float) {
    view.layer.shadowColor = color
    view.layer.shadowOffset = CGSize(width: 0, height: 0)
    view.layer.shadowOpacity = opacity
    
    view.clipsToBounds = false
    view.layer.masksToBounds = false
}
