//
//  FancyWord.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class FancyWord {
    var letters: [UILabel] = []
    var height: CGFloat = 0
    var width: CGFloat = 0
    
    func add(letter: UILabel) {
        letter.sizeToFit()
        letters.append(letter)
        width += letter.bounds.width
        if letter.bounds.height > height {
            height =  letter.bounds.height
        }
    }
}
