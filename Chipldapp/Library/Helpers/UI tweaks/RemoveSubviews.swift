//
//  RemoveSubviews.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

func removeAllSubviews(from view: UIView) {
    while let subview = view.subviews.last {
        subview.removeFromSuperview()
    }
}
