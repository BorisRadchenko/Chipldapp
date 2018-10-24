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
    // MARK: - М Е Т О Д Ы:
    init(widthLimit: CGFloat, interlineSpacing: CGFloat, spaceLabel: UILabel, hyphenLabel: UILabel) {
        self.widthLimit = widthLimit
        self.interlineSpace = interlineSpacing
        self.spaceLabel = spaceLabel
        // spaceLabel.sizeToFit()
        self.hyphenLabel = hyphenLabel
        // hyphenLabel.sizeToFit()
    }
    
    func addWord(_ word: FancyWord) {
        //        1) Узнать длину текущей строки (если строка непустая)
        //        2) Проверить, не превышает ли слово ширину строки
        //            Если превышает, то разбить слово переносами
        //        Проверить, вмещается ли новое слово в текущую строку
        //          Если не вмещается, то разбить на несколько слов с помощью переносов
        //        Метод "начать новую строку"
        //        Метод "дополнить текущую строку"
        //        Метод "узнать объём свободного места в текущей строке"
        var wordParts: [FancyWord] = []
        if word.width > widthLimit {
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
                }
            }
            while word.letterCount > 0 {
                let wordPart = word.prefixByWidthLimit(widthLimit-hyphenLabel.bounds.width)
                word.removePart(length: wordPart!.letterCount)
                if word.letterCount > 0 { wordPart!.add(letter: hyphenCopy()) }
                wordParts.append(wordPart!)
            }
        } else {
            wordParts.append(word)
        }
        for wordPart in wordParts {
            var spacedWord = wordPart.copy() as! FancyWord
            if currentLine.isNotEmpty {
                spacedWord.insert(letter: spaceLabel, at: 0)
            }
            if getEmptySpaceInCurrentLine() < spacedWord.width {
                saveAndClearCurrentLine()
                spacedWord = wordPart.copy() as! FancyWord
            }
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
    
    func show(inContainer container: UIView, withIndent indent: CGFloat, startY: CGFloat) {
        let labelsView = UIView()
        var lineY = startY
        for line in lines {
            var startX = leadingX(byExternalWidth: widthLimit, ownWidth: line.width)
            for label in line.letters {
                let startY = topY(byExternalHeight: line.height, ownHeight: label.bounds.height)
                label.frame = CGRect(x: startX + indent, y: lineY + startY, width: label.bounds.width, height: label.bounds.height)
                labelsView.addSubview(label)
                startX += label.bounds.width
            }
            lineY += line.height + interlineSpace
        }
        container.addSubview(labelsView)
        labelsView.addShadow(color: shadowColor, opacity: 0.7)
    }
    
    func getHeight()->CGFloat {
        var height: CGFloat = 0
        lines.forEach{ height += $0.height}
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
