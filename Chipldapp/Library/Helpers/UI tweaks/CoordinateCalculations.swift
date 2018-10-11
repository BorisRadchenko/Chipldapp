//
//  CoordinateCalculations.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

struct CenteredRect {
    static func getTopY(byRectCenterY rectCenterY: CGFloat, rectHeight: CGFloat) -> CGFloat {
        return rectCenterY - rectHeight / 2
    }
    static func getTopY(byContainerHeight containerHeight: CGFloat, rectHeight: CGFloat) -> CGFloat {
        return containerHeight / 2 - rectHeight / 2
    }
    static func getLeftX(byRectCenterX rectCenterX: CGFloat, rectWidth: CGFloat) -> CGFloat {
        return rectCenterX - rectWidth / 2
    }
    static func getLeftX(byContainerWidth containerWidth: CGFloat, rectWidth: CGFloat) -> CGFloat {
        return containerWidth / 2 - rectWidth / 2
    }
}
