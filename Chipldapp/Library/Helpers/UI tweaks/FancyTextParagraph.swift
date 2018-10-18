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
    var currentLine = FancyTextLine()
    var widthLimit: CGFloat
    var spaceLabel: UILabel
    var hyphenLabel: UILabel
    var interlineSpace: CGFloat
    
    init(widthLimit: CGFloat, interlineSpacing: CGFloat, spaceLabel: UILabel, hyphenLabel: UILabel) {
        self.widthLimit = widthLimit
        self.interlineSpace = interlineSpacing
        self.spaceLabel = spaceLabel
        // spaceLabel.sizeToFit()
        self.hyphenLabel = hyphenLabel
        // hyphenLabel.sizeToFit()
    }
    
//    func addWord(_ word: FancyWord) {
//        let spaceWidth = spaceLabel.bounds.width
//
//        if word.width > widthLimit { //a single current word is wider than the limit
//            print("USE HYPHEN!")
////            первая часть слова + дефис должны вмещаться в строку, при этом первая часть должна включать более двух букв
//        } else if currentLine.width + word.width + spaceWidth > widthLimit { // space after current word together with word itself does not fit the line
//
//            if word.width < getEmptySpaceInCurrentLine() { // current word does not fit the current line
//                if (currentLine.letters[currentLine.letters.endIndex-1] as UILabel).text == " " {
//                    currentLine.letters.remove(at: currentLine.letters.endIndex-1)//(delete last space in line)
//                }
//                saveAndClearCurrentLine()
//                currentLine.add(word) //move word to the next line
//                currentLine.add(spaceLabel)
//            } else { //only last space does not fit, the word itself fits
//                currentLine.add(word) //add word to line, do not add the last space
//                saveAndClearCurrentLine()
//            }
//        } else { // current word and space after fit the line
//            currentLine.add(word) //add word to line
//            currentLine.add(spaceLabel) //add space to line
//        }
//
//    }
    
    func addWord2(_ word: FancyWord) {
        //        1) Узнать длину текущей строки (если строка непустая)
        //        2) Проверить, не превышает ли слово ширину строки
        //            Если превышает, то разбить слово переносами
        
        //        Проверить, вмещается ли новое слово в текущую строку
        //          Если не вмещается, то разбить на несколько слов с помощью переносов
        
        //        Метод "начать новую строку"
        //        Метод "дополнить текущую строку"
        //        Метод "узнать объём свободного места в текущей строке"
        print("Width limit = \(widthLimit)")
        print ("'\(word.text)' width = \(word.width)")
        
        // print("Width of 3 first letters = \(word.widthOfAPart(length: 3))")
        
        var wordParts: [FancyWord] = []
        if word.width > widthLimit {
            print("Необходимы переносы")
            // Переносы необходимы, если word.width > widthLimit
            // Разделить длинное слово на части
            //  - в текущую строку попробовать добавить начало слова
            //      - часть должна состоять из как минимум трёх букв
            //      - если не вмещается, значит первая часть слова будет размещаться не на текущей, а на следующей строке
            //  - двигаясь слева направо, отсекать от слова как можно большие фрагменты, способные вместиться вместе с символом переноса в установленную ширину
            // Каждую часть плюс дефис добавить в абзац так же, как если бы это было отдельное слово
            if currentLine.isNotEmpty {
                //  - в текущую строку попробовать добавить начало слова
                // Зная ширину свободного места в строке, подобрать максимальную возможную часть слова
                let wordPart = word.prefixByWidthLimit(getEmptySpaceInCurrentLine()-hyphenLabel.bounds.width)
                //      - часть должна состоять из как минимум трёх букв
                if wordPart!.letterCount > 2 {
                    word.removePart(length: wordPart!.letterCount)
                    wordPart!.add(letter: hyphenCopy())
                    wordParts.append(wordPart!)
                    // print(wordPart!.text)
                }
            }
            while word.letterCount > 0 {
                let wordPart = word.prefixByWidthLimit(widthLimit-hyphenLabel.bounds.width)
                word.removePart(length: wordPart!.letterCount)
                if word.letterCount > 0 { wordPart!.add(letter: hyphenCopy()) }
                wordParts.append(wordPart!)
                print(wordPart!.text)
            }
        } else {
            wordParts.append(word)
        }
        for wordPart in wordParts {
            var spacedWord = wordPart.copy() as! FancyWord
            if currentLine.isNotEmpty {
                // print("В текущей строке уже что-то есть. При добавлении слова в строку необходимо ставить перед ним пробел.")
                spacedWord.insert(letter: spaceLabel, at: 0)
            }
            if getEmptySpaceInCurrentLine() < spacedWord.width {
                // print("Слово не вмещается в текущую строку. Сохранить и очистить текущую строку.")
                saveAndClearCurrentLine()
                spacedWord = wordPart.copy() as! FancyWord
            }
            print(spacedWord.text)
            currentLine.add(spacedWord)
        }
    }
    
    private func getEmptySpaceInCurrentLine() -> CGFloat {
        return widthLimit - currentLine.width
    }
    
    private func addFirstWordToCurrentLine(_ word: FancyWord) {
        currentLine.add(word)
    }
    
    private func addNextWordToCurrentLine(_ word: FancyWord) {
        currentLine.add(spaceLabel)
        currentLine.add(word)
    }
    
    private func saveAndClearCurrentLine() {
        lines.append(currentLine.copy() as! FancyTextLine)
        currentLine.clear()
    }
    
    
    func finish() {
        saveAndClearCurrentLine()
    }
    
    func show(inside container: UIView, withIndent indent: CGFloat, topY: CGFloat) {
        let labelsView = UIView()
        var lineY = topY
        for line in lines {
            var startX = CenteredRect.getLeftX(byContainerWidth: widthLimit, rectWidth: line.width)
            for label in line.letters {
                let startY = CenteredRect.getTopY(byContainerHeight: line.height, rectHeight: label.bounds.height)
                label.frame = CGRect(x: startX + indent, y: lineY + startY, width: label.bounds.width, height: label.bounds.height)
                labelsView.addSubview(label)
                startX += label.bounds.width
            }
            lineY += line.height + interlineSpace
        }
        container.addSubview(labelsView)
        addShadow(to: labelsView, usingColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), andOpacity: 0.7)
    }
    
    func getHeight()->CGFloat {
        var height: CGFloat = 0
        for line in lines {
            height += line.height
        }
        height += interlineSpace * CGFloat(lines.count - 1)
        return height
    }
    
    func hyphenCopy() -> UILabel {
        let copy = UILabel ()
        copy.text = hyphenLabel.text
        copy.font = hyphenLabel.font
        copy.sizeToFit()
        return copy
    }
    
}
