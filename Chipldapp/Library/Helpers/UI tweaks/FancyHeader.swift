//
//  FancyHeader.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class FancyHeader {
    // MARK: - P R O P E R T I E S / public
    // MARK: P R O P E R T I E S / private
    private var title: String?
    private var artist: String?
    private var placeholder: String
    private var shuffledPlaceholder: String { get { return shuffleLetters(placeholder) } }
    private var titleHeaderParagraph: FancyTextParagraph? = nil
    private var artistHeaderLabel: UILabel? = nil
    private var minDisplayAreaWidth: CGFloat = 0 // FIXME: Вычислить экспериментально минимальные ширину и высоту
    private var minDisplayAreaHeight: CGFloat = 0
    private var indent: CGFloat = 20
    private let titlePartsSpace: CGFloat = 20
    private var displayArea: UIView
    private let artistFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: 39)
    private let artistMinFontSize = 15
    private let spacersFont = UIFont(name: "Helvetica Neue", size: 25)
    private let spaceLabel = UILabel()
    private let hyphenLabel = UILabel()
    
    // MARK: - P R O P E R T I E S / private / outlets
    // MARK: M E T H O D S / public
    init(title: String? = nil, artist: String? = nil, placeholder: String, displayArea: UIView) {
        self.title = title
        self.artist = artist
        self.placeholder = placeholder
        self.displayArea = displayArea
        self.spaceLabel.font = spacersFont
        self.spaceLabel.text = " "
        self.spaceLabel.sizeToFit()
        self.hyphenLabel.font = spacersFont
        self.hyphenLabel.text = "-"
        self.hyphenLabel.sizeToFit()
    }
    func hasEnoughDisplayAreaSize() -> Bool {
        guard displayArea.bounds.width >= minDisplayAreaWidth else { return false }
        guard displayArea.bounds.height >= minDisplayAreaHeight else { return false }
        return true
    }
    func show() { // FIXME: Рефакторинг
        // 1) displayArea имеет недостаточный размер -> ничего не делаем
        // 2) title и artist равны nil или пустой строке -> показываем заглушку
        // 3) только title равен nil или пустой строке -> показываем только artist
        // 4) только artist равен nil или пустой строке -> показываем только title
        // 5) есть и artist, и title -> показываем title и artist
        if (title != "") && (title != nil) {
            prepareTitleHeader()
            let titleHeaderHeight = titleHeaderParagraph!.getHeight()
            prepareArtistHeader()
            let artistHeaderHeight = getArtistHeaderHeight()
            let totalHeaderHeight = titleHeaderHeight + titlePartsSpace + artistHeaderHeight
            var titleTopY: CGFloat = 0
            if totalHeaderHeight > UIScreen.main.bounds.height * 0.5 {
                titleTopY = topY(byExternalHeight: displayArea.bounds.height, ownHeight: totalHeaderHeight)
            } else {
                titleTopY = topY(byOwnCenterY: UIScreen.main.bounds.height * 0.33, ownHeight: totalHeaderHeight)
            }
            let artistTopY = titleTopY + titleHeaderHeight + titlePartsSpace
            titleHeaderParagraph!.show(inContainer: displayArea, withIndent: 20, startY: titleTopY)
            showArtistHeader(topY: artistTopY)
            let scale = displayArea.bounds.height / totalHeaderHeight
            if scale < 1 {
                displayArea.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else {
            showPlaceholder()
        }
    }
    
    // MARK: - M E T H O D S / public / actions
    // MARK: M E T H O D S / private
    private func prepareTitleHeader() { // FIXME: Рефакторинг
        guard let title = title else {
            print("There is no title to prepare")
            return
        }
        titleHeaderParagraph = FancyTextParagraph(widthLimit: displayArea.bounds.width - indent * 2, interlineSpacing: 3, spaceLabel: spaceLabel, hyphenLabel: hyphenLabel)
        let words: [String] = title.components(separatedBy: .whitespacesAndNewlines).filter {!$0.isEmpty}
        for word in words {
            let fancyWord = FancyWord()
            for letter in word {
                let letterLabel = UILabel()
                letterLabel.attributedText = FancyLetterStyle.decorateRandomly(letter) //.decorateMinSize(letter)
                letterLabel.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                letterLabel.layer.borderWidth = 0.3
                fancyWord.add(letter: letterLabel)
            }
            titleHeaderParagraph!.addWord(fancyWord)
        }
        titleHeaderParagraph!.finish()
    }
    private func prepareArtistHeader() { // FIXME: Рефакторинг
        
        guard let artist = artist else {
            print("There is no artist name to show")
            return
        }
        artistHeaderLabel = UILabel()
        artistHeaderLabel!.text = artist
        artistHeaderLabel!.font = artistFont
        artistHeaderLabel!.numberOfLines = 0
        artistHeaderLabel!.textAlignment = .center
        
        artistHeaderLabel!.frame = CGRect(x: 0, y: 0, width: displayArea.bounds.width - indent * 2, height: 0)
        artistHeaderLabel!.sizeToFit()
    }
    private func showArtistHeader(topY: CGFloat) { // FIXME: Рефакторинг
        artistHeaderLabel!.frame = CGRect(x: leadingX(byExternalWidth: displayArea.bounds.width, ownWidth: artistHeaderLabel!.bounds.width),
                                          y: topY,
                                          width: artistHeaderLabel!.bounds.width,
                                          height: artistHeaderLabel!.bounds.height)
        displayArea.addSubview(artistHeaderLabel!)
    }
    private func getArtistHeaderHeight() -> CGFloat {
        return artistHeaderLabel!.bounds.height
    }
    private func showPlaceholder() { // FIXME: Рефакторинг
        let placeholderParagraph = FancyTextParagraph(widthLimit: displayArea.bounds.width - indent * 2, interlineSpacing: 3, spaceLabel: spaceLabel, hyphenLabel: hyphenLabel)
        
        let words: [String] = shuffledPlaceholder.components(separatedBy: .whitespacesAndNewlines).filter {!$0.isEmpty}
        
        for word in words {
            let fancyWord = FancyWord()
            for letter in word {
                let letterLabel = UILabel()
                letterLabel.attributedText = FancyLetterStyle.decorateRandomly(letter)
                letterLabel.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                letterLabel.layer.borderWidth = 0.3
                fancyWord.add(letter: letterLabel)
            }
            placeholderParagraph.addWord(fancyWord)
        }
        placeholderParagraph.finish()
        var placeholderTopY: CGFloat = 0
        if placeholderParagraph.getHeight() > UIScreen.main.bounds.height * 0.5 {
            placeholderTopY = topY(byExternalHeight: displayArea.bounds.height, ownHeight: placeholderParagraph.getHeight())
        } else {
            placeholderTopY = topY(byOwnCenterY: UIScreen.main.bounds.height * 0.33, ownHeight: placeholderParagraph.getHeight())
        }
        placeholderParagraph.show(inContainer: displayArea, withIndent: 20, startY: placeholderTopY)
    }
    private func shuffleLetters(_ string: String) -> String {
        // TODO: Рефакторинг
        var chars = Array(String(string.shuffled()).lowercased())
        chars[0] = Character(String(chars[0]).uppercased())
        return String(chars)
    }
}
// MARK: -
