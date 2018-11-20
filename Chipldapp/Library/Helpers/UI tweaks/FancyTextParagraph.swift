//
//  FancyTextParagraph.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

//  Разбивает текст на слова, состоящие из label'ов, оформленных в разных стилях.
//  Формирует из слов абзац, соответствующий ширине и полям контейнера.
//  Слишком длинные слова разбиваются переносами.
//  Показывает своё содержимое в контейнере, на указанной высоте.

import UIKit

class FancyTextParagraph {
    // MARK: - P R O P E R T I E S / public
    var height: CGFloat { return getHeight() }
    
    // MARK: - P R O P E R T I E S / private
    private var lines: [FancyTextLine] = []
    private var currentLine = FancyTextLine()
    private var container: UIView
    private var width: CGFloat { return container.bounds.width }
    private var indent: CGFloat
    private var widthLimit: CGFloat { return width - indent * 2 }
    private var spaceLabel: UILabel
    private var hyphenLabel: UILabel
    private var interlineSpace: CGFloat
    private var text: String
    
    // MARK: P R O P E R T I E S / private / outlets
    // MARK: - M E T H O D S / public
    init(text: String, container: UIView, indent: CGFloat, interlineSpacing: CGFloat, spaceLabel: UILabel, hyphenLabel: UILabel) {
        self.container = container
        self.indent = indent
        self.interlineSpace = interlineSpacing
        self.spaceLabel = spaceLabel
        self.hyphenLabel = hyphenLabel
        self.text = text
        fillLines(withText: text)
    }
    func placeInParentViewAt(startY: CGFloat) {
        let visibleContent = UIView()
        var lineY = startY
        for line in lines {
            var startX = line.leadingX(byExternalWidth: widthLimit) 
            for letterLabel in line.letters {
                let insideLineY = letterLabel.topY(byExternalHeight: line.height)
                letterLabel.frame = CGRect(x: startX + indent,
                                           y: lineY + insideLineY,
                                           width: letterLabel.bounds.width,
                                           height: letterLabel.bounds.height)
                visibleContent.addSubview(letterLabel)
                startX += letterLabel.bounds.width
            }
            lineY += line.height + interlineSpace
        }
        container.addSubview(visibleContent)
        visibleContent.addShadow(color: .shadowColor, opacity: 0.7)
    }
    
    // MARK: M E T H O D S / public / actions
    // MARK: - M E T H O D S / private
    private func fillLines(withText text: String) {
        let words: [String] = text.components(separatedBy: .whitespacesAndNewlines).filter {!$0.isEmpty}
        for word in words {
            let fancyWord = FancyWord()
            for letter in word {
                let letterLabel = UILabel()
                letterLabel.attributedText = FancyLetterStyle.decorateRandomly(letter) //.decorateMinSize(letter)
                letterLabel.layer.borderColor = .letterBorderColor
                letterLabel.layer.borderWidth = 0.3
                fancyWord.add(letter: letterLabel)
            }
            addWord(fancyWord)
        }
        finish()
    }
    private func addWord(_ word: FancyWord) {
        var wordParts: [FancyWord] = []
        if word.width > widthLimit {
            if currentLine.isNotEmpty {
                let wordPart = word.prefixByWidthLimit(getEmptySpaceInCurrentLine()-hyphenLabel.bounds.width)
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
    private func finish() {
        saveAndClearCurrentLine()
    }
    private func getHeight() -> CGFloat {
        var height: CGFloat = 0
        lines.forEach{ height += $0.height}
        height += interlineSpace * CGFloat(lines.count - 1)
        return height
    }
    private func hyphenCopy() -> UILabel {
        let copy = UILabel ()
        copy.text = hyphenLabel.text
        copy.font = hyphenLabel.font
        copy.sizeToFit()
        return copy
    }
}
