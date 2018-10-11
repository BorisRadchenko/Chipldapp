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
    var widthLimit: CGFloat
    var spaceLabel: UILabel
    var interlineSpace: CGFloat
    
    init(widthLimit: CGFloat, interlineSpacing: CGFloat, spaceLabel: UILabel) {
        self.widthLimit = widthLimit
        self.interlineSpace = interlineSpacing
        self.spaceLabel = spaceLabel
    }
    
    func addWord(_ word: FancyWord) {
        //        TODO: Оптимизировать проверки
        let spaceWidth = spaceLabel.bounds.width
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
                lastLine.add(spaceLabel)
            } else { //only last space does not fit, the word itself fits
                lastLine.add(word) //add word to line, do not add the last space
                lines.append(lastLine.copy() as! FancyTextLine) //save gained line
                lastLine.clear()
            }
        } else { // current word and space after fit the line
            lastLine.add(word) //add word to line
            lastLine.add(spaceLabel) //add space to line
        }
    }
    
    func finish() {
        lines.append(lastLine.copy() as! FancyTextLine) // add the last word
        lastLine.clear()
    }
    
    func show(inside container: UIView, withIndent indent: CGFloat, topY: CGFloat) {
        var lineY = topY
        for line in lines {
            var startX = CenteredRect.getLeftX(byContainerWidth: widthLimit, rectWidth: line.width)
            for label in line.letters {
                let startY = CenteredRect.getTopY(byContainerHeight: line.height, rectHeight: label.bounds.height)
                label.frame = CGRect(x: startX + indent, y: lineY + startY, width: label.bounds.width, height: label.bounds.height)
                container.addSubview(label)
                startX += label.bounds.width
            }
            lineY += line.height + interlineSpace
        }
    }
    
    func getHeight()->CGFloat {
        var height: CGFloat = 0
        for line in lines {
            height += line.height
        }
        height += interlineSpace * CGFloat(lines.count - 1)
        return height
    }
    
}
