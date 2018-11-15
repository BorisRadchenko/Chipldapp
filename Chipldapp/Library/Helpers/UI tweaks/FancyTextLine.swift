//
//  FancyTextLine.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class FancyTextLine: NSCopying {
    var letters: [UILabel] = []
    var height: CGFloat = 0
    var width: CGFloat = 0
    var isNotEmpty: Bool { get { return !letters.isEmpty }}
    // MARK: - М Е Т О Д Ы:
    func add(_ word: FancyWord) {
        letters += word.letters
        width += word.width
        if word.height > height {
            height = word.height
        }
    }
    
    func add(_ label: UILabel) {
        letters.append(label)
        width += label.bounds.width
        if label.bounds.height > height {
            height = label.bounds.height
        }
    }
    
    func clear() {
        letters = []
        height = 0
        width = 0
    }
    
    init(letters: [UILabel] = [], height: CGFloat = 0, width: CGFloat = 0){
        self.letters = letters
        self.height = height
        self.width = width
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = FancyTextLine(letters: letters, height: height, width: width)
        return copy
    }
}

extension FancyTextLine { // FIXME: Объединить с расширением UIView
    func leadingX(byOwnCenterX ownCenterX: CGFloat) -> CGFloat {
        return ownCenterX - self.width / 2
    }
    
    func leadingX(byExternalWidth externalWidth: CGFloat) -> CGFloat {
        return externalWidth / 2 - self.width / 2
    }
}
