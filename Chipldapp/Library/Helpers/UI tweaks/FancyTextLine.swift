//
//  FancyTextLine.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class FancyTextLine: NSCopying {
    // MARK: - P R O P E R T I E S / public
    var letters: [UILabel] = []
    var height: CGFloat = 0
    var width: CGFloat = 0
    var isNotEmpty: Bool { get { return !letters.isEmpty }}
    
    // MARK: P R O P E R T I E S / private
    // MARK: P R O P E R T I E S / private / outlets
    // MARK: - M E T H O D S / public
    init(letters: [UILabel] = [], height: CGFloat = 0, width: CGFloat = 0){
        self.letters = letters
        self.height = height
        self.width = width
    }
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
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = FancyTextLine(letters: letters, height: height, width: width)
        return copy
    }
    // MARK: M E T H O D S / public / actions
    // MARK: M E T H O D S / private
}
// MARK: -
extension FancyTextLine { // FIXME: Объединить с расширением UIView
    func leadingX(byOwnCenterX ownCenterX: CGFloat) -> CGFloat {
        return ownCenterX - self.width / 2
    }
    
    func leadingX(byExternalWidth externalWidth: CGFloat) -> CGFloat {
        return externalWidth / 2 - self.width / 2
    }
}
