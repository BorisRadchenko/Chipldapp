//
//  FancyTextParagraph.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class FancyTextParagraph {
    var lines: [FancyTextLine] = []
    var lastLine = FancyTextLine()
    var container: UIView
    var containerWidth: CGFloat
    var inset: CGFloat
    var space: UILabel
    var spaceWidth: CGFloat
    var interlineSpace: CGFloat
    
    init(container: UIView, inset: CGFloat, space: UILabel, interlineSpacing: CGFloat) {
        self.container = container
        self.containerWidth = container.bounds.width
        self.inset = inset
        self.space = space
        self.spaceWidth = space.bounds.width
        self.interlineSpace = interlineSpacing
    }
    
    func addWord(_ word: FancyWord) {
        let widthLimit = containerWidth - inset * 2
        
        if word.width > widthLimit { //a single current word is wider than the limit
            print("Oops!..")
        } else if lastLine.width + word.width + spaceWidth > widthLimit { // space after current word together with word itself does not fit the line
            if lastLine.width + word.width > widthLimit { // current word does not fit the current line
                if (lastLine.letters[lastLine.letters.endIndex-1] as UILabel).text == " " {
                    lastLine.letters.remove(at: lastLine.letters.endIndex-1)//(delete last space in line)
                }
                lines.append(lastLine.copy() as! FancyTextLine) //save gained line
                lastLine.clear()
                lastLine.add(word) //move word to the next line
                lastLine.add(space)
            } else { //only last space does not fit, the word itself fits
                lastLine.add(word) //add word to line, do not add the last space
                lines.append(lastLine.copy() as! FancyTextLine) //save gained line
                lastLine.clear()
            }
        } else { // current word and space after fit the line
            lastLine.add(word) //add word to line
            lastLine.add(space) //add space to line
        }
    }
    
    func finish() {
        lines.append(lastLine.copy() as! FancyTextLine) // add the last word
        lastLine.clear()
    }
    
    func show() {
        var lineY: CGFloat = 0
        for line in lines {
            var startX = round(containerWidth / 2) - round(line.width / 2)
            for label in line.letters {
                let startY = lineY + round(line.height / 2) - round(label.bounds.height / 2)
                let rect = CGRect(x: startX, y: startY, width: label.bounds.width, height: label.bounds.height)
                label.frame = rect
                container.addSubview(label)
                startX += label.bounds.width
            }
            lineY += line.height + interlineSpace
        }
    }
    
}
