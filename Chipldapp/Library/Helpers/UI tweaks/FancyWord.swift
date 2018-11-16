//
//  FancyWord.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class FancyWord: NSCopying {
    // MARK: - P R O P E R T I E S / public
    var letters: [UILabel] = []
    var height: CGFloat = 0
    var width: CGFloat = 0
    var text: String {
        get {
            guard !letters.isEmpty else { return "" }
            var s = ""
            for label in letters {
                s += label.text!
            }
            return s
        }
    }
    var letterCount: Int { get { return letters.count } }
    
    // MARK: P R O P E R T I E S / private
    // MARK: P R O P E R T I E S / private / outlets
    // MARK: - M E T H O D S / public
    init (_ letters: [UILabel] = []) {
        letters.forEach{ add(letter: $0) }
    }
    init (letters: [UILabel], width: CGFloat, height: CGFloat) {
        self.letters = letters
        self.width = width
        self.height = height
    }
    func add(letter: UILabel) {
        letter.sizeToFit()
        letters.append(letter)
        width += letter.bounds.width
        if letter.bounds.height > height {
            height =  letter.bounds.height
        }
    }
    func insert(letter: UILabel, at: Int) {
        letter.sizeToFit()
        letters.insert(letter, at: at)
        width += letter.bounds.width
        if letter.bounds.height > height {
            height =  letter.bounds.height
        }
    }
    func removePart(startingAt startIndex: Int = 0 , length: Int) {
        for index in (startIndex...startIndex+length-1).reversed() {
            letters.remove(at: index)
        }
        width = 0
        height = 0
        for letter in letters {
            width += letter.bounds.width
            if letter.bounds.height > height {
                height = letter.bounds.height
            }
        }
    }
    func widthOfAPart(startAt startIndex: Int = 0, length: Int) -> CGFloat {
        var partWidth: CGFloat = 0
        for index in startIndex ... startIndex + length - 1 {
            partWidth += letters[index].bounds.width
        }
        return partWidth
    }
    func part(startAt startIndex: Int = 0, length: Int) -> FancyWord {
        let lettersSubset = Array(letters[startIndex...startIndex+length-1])
        return FancyWord(lettersSubset)
    }
    func prefixByWidthLimit(_ widthLimit: CGFloat) -> FancyWord? {
        var partWidth: CGFloat
        var length = letterCount
        repeat {
            partWidth = widthOfAPart(length: length)
            length -= 1
        } while (partWidth > widthLimit) && (length > 0)
        length += 1
        return part(length: length)
    }
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = FancyWord(letters: letters, width: width, height: height) // FIXME: Передавать копию массива letters, а не ссылку на него! (или нет?)
        return copy
    }
    
    // MARK - M E T H O D S / public / actions
    // MARK - M E T H O D S / private
}
