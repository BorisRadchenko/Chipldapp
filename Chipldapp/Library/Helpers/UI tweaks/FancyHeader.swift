//
//  FancyHeader.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class FancyHeader {
    var title: String?
    var artist: String?
    private var placeholder: String
    var shuffledPLaceholder: String {
        get { return shuffleLetters(placeholder) }
    }
    
    var displayArea: UIView
// TODO: Вычислить экспериментально минимальные ширину и высоту
    var minDisplayAreaWidth: CGFloat = 0
    var minDisplayAreaHeight: CGFloat = 0
    var indent: CGFloat = 20
    
    let artistFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: 39)
    let artistMinFontSize = 15
    
    let spacersFont = UIFont(name: "Helvetica Neue", size: 25)
    let spaceLabel = UILabel()
    let hyphenLabel = UILabel()
    
    private var titleHeaderParagraph: FancyTextParagraph? = nil
    private var artistHeaderLabel: UILabel? = nil
    private let titlePartsSpace: CGFloat = 20
    
// MARK: -
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
    
    func prepareTitleHeader() {
        
        guard let title = title else {
            print("There is no title to prepare")
            return
        }
        
        titleHeaderParagraph = FancyTextParagraph(widthLimit: displayArea.bounds.width - indent * 2, interlineSpacing: 3, spaceLabel: spaceLabel)
        
        let words: [String] = title.components(separatedBy: .whitespacesAndNewlines).filter {!$0.isEmpty}

        for word in words {
            let fancyWord = FancyWord()
            for letter in word {
                let letterLabel = UILabel()
                letterLabel.attributedText = FancyLetterStyle.decorate(letter)
                letterLabel.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                letterLabel.layer.borderWidth = 0.3
                fancyWord.add(letter: letterLabel)
            }
            titleHeaderParagraph!.addWord(fancyWord)
        }
        titleHeaderParagraph!.finish()
    }
    
    
    func prepareArtistHeader() {
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
    
    func showArtistHeader(topY: CGFloat) {
        artistHeaderLabel!.frame = CGRect(x: CenteredRect.getLeftX(byContainerWidth: displayArea.bounds.width, rectWidth: artistHeaderLabel!.bounds.width),
                                          y: topY,
                                          width: artistHeaderLabel!.bounds.width,
                                          height: artistHeaderLabel!.bounds.height)
        displayArea.addSubview(artistHeaderLabel!)
    }
    
    func getArtistHeaderHeight() -> CGFloat {
        return artistHeaderLabel!.bounds.height
    }
    
    func showPlaceholder() {
        let placeholderParagraph = FancyTextParagraph(widthLimit: displayArea.bounds.width - indent * 2, interlineSpacing: 3, spaceLabel: spaceLabel)
        
        let words: [String] = shuffledPLaceholder.components(separatedBy: .whitespacesAndNewlines).filter {!$0.isEmpty}
        
        for word in words {
            let fancyWord = FancyWord()
            for letter in word {
                let letterLabel = UILabel()
                letterLabel.attributedText = FancyLetterStyle.decorate(letter)
                letterLabel.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                letterLabel.layer.borderWidth = 0.3
                fancyWord.add(letter: letterLabel)
            }
            placeholderParagraph.addWord(fancyWord)
        }
        placeholderParagraph.finish()
        var placeholderTopY: CGFloat = 0
        if placeholderParagraph.getHeight() > UIScreen.main.bounds.height * 0.5 {
            placeholderTopY = CenteredRect.getTopY(byContainerHeight: displayArea.bounds.height, rectHeight: placeholderParagraph.getHeight())
        } else {
            placeholderTopY = CenteredRect.getTopY(byRectCenterY: UIScreen.main.bounds.height * 0.33, rectHeight: placeholderParagraph.getHeight())
        }
        placeholderParagraph.show(inside: displayArea, withIndent: 20, topY: placeholderTopY)
    }
    
    func showHeader() {
        prepareTitleHeader()
        let titleHeaderHeight = titleHeaderParagraph!.getHeight()
        prepareArtistHeader()
        let artistHeaderHeight = getArtistHeaderHeight()
        let totalHeaderHeight = titleHeaderHeight + artistHeaderHeight
        //        TODO: Добавить проверку высоты заголовка (если превышает высоту контейнера, нужно сжимать содержимое)
        var titleTopY: CGFloat = 0
        if totalHeaderHeight > UIScreen.main.bounds.height * 0.5 {
            titleTopY = CenteredRect.getTopY(byContainerHeight: displayArea.bounds.height, rectHeight: totalHeaderHeight)
        } else {
            titleTopY = CenteredRect.getTopY(byRectCenterY: UIScreen.main.bounds.height * 0.33, rectHeight: totalHeaderHeight)
        }
        let artistTopY = titleTopY + titleHeaderHeight + titlePartsSpace
        titleHeaderParagraph!.show(inside: displayArea, withIndent: 20, topY: titleTopY)
        showArtistHeader(topY: artistTopY)
    }
}

// MARK: -
private func shuffleLetters(_ string: String) -> String {
    var chars = Array(String(string.shuffled()).lowercased())
    chars[0] = Character(String(chars[0]).uppercased())
    return String(chars)
}

