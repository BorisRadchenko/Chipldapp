//
//  CoordinateCalculations.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

// Относительно наглядный способ получать координаты верхней-левой точки на базе имеющихся координат
// для позиционирования центрированного объекта

import UIKit

func topY(byOwnCenterY ownCenterY: CGFloat, ownHeight: CGFloat) -> CGFloat {
    return ownCenterY - ownHeight / 2
}

func topY(byExternalHeight externalHeight: CGFloat, ownHeight: CGFloat) -> CGFloat {
    return externalHeight / 2 - ownHeight / 2
}

func leadingX(byOwnCenterX ownCenterX: CGFloat, ownWidth: CGFloat) -> CGFloat {
    return ownCenterX - ownWidth / 2
}

func leadingX(byExternalWidth externalWidth: CGFloat, ownWidth: CGFloat) -> CGFloat {
    return externalWidth / 2 - ownWidth / 2
}
