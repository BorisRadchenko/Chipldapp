//
//  FancyHeader.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

// TODO: Сначала заголовок оформляется, а потом размещается с учётом его габаритов

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
    
    let artistFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: 39)
    let artistMinFontSize = 15
    
    let spacersFont = UIFont(name: "Helvetica Neue", size: 25)
    let spaceLabel = UILabel()
    let hyphenLabel = UILabel()
    
    
// MARK: -
    init(title: String? = nil, artist: String? = nil, placeholder: String, displayArea: UIView) {
        self.title = title
        self.artist = artist
        self.placeholder = placeholder
        self.displayArea = displayArea
        self.spaceLabel.font = spacersFont
        self.spaceLabel.text = " "
        self.hyphenLabel.font = spacersFont
        self.hyphenLabel.text = "-"
    }
    
    func hasEnoughDisplayAreaSize() -> Bool {
        guard displayArea.bounds.width >= minDisplayAreaWidth else { return false }
        guard displayArea.bounds.height >= minDisplayAreaHeight else { return false }
        return true
    }
    
    func showTitle() {
        guard let title = title else {
            print("There is no title to show")
            return
        }
        let paragraph = FancyTextParagraph(container: displayArea, inset: 20, space: spaceLabel, interlineSpacing: 3)
        var words: [String] = []
        words = title.components(separatedBy: .whitespacesAndNewlines).filter {!$0.isEmpty}
        for word in words {
            let fancyWord = FancyWord()
            for letter in word {
                let label = UILabel()
                label.attributedText = FancyLetterStyle.decorate(letter)
                label.sizeToFit() // нужно ли?
                fancyWord.add(letter: label)
            }
            paragraph.addWord(fancyWord)
        }
        paragraph.finish()
        paragraph.show()
    }
    
    func showArtist() {
        guard let artist = artist else {
            print("There is no artist name to show")
            return
        }
        let label = UILabel()
        label.text = artist
        label.font = artistFont
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.frame = CGRect(x: 0, y: 0, width: displayArea.bounds.width, height: 0)
        label.sizeToFit()
// TODO: Строка ниже будет не нужна, когда заголовок будет размещаться исходя из размеров двух его частей
        label.frame = CGRect(x: displayArea.bounds.width / 2 - label.bounds.width / 2,
                             y: displayArea.bounds.height / 2 - label.bounds.height / 2,
                             width: label.bounds.width,
                             height: label.bounds.height)
        label.layer.borderColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        label.layer.borderWidth = 1
        displayArea.addSubview(label)
    }
    
    func showPlaceholder() {
        let label = UILabel()
//        label.text = shuffledPLaceholder
        label.attributedText = FancyLetterStyle.decorate(shuffledPLaceholder.first!)
//        label.font = UIFont(name: "TimesNewRomanPS-BoldMT", size: 39)
        label.textAlignment = .center
        label.sizeToFit()
        let labelFrame = CGRect(x: displayArea.bounds.width / 2 - label.bounds.width / 2,
                                y: displayArea.bounds.height / 2 - label.bounds.height / 2,
                                width: label.bounds.width,
                                height: label.bounds.height)
        label.frame = labelFrame
        displayArea.addSubview(label)
        addShadow(on: label, using: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), and: 0.9)
    }
    
    func placeHeader() {
        // MOCK:
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        view.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        view.layer.borderWidth = 1
        view.alpha = 0.7
        let quotient = CGFloat.random(in: 0.25..<1)
        let viewHeight = displayArea.bounds.height * quotient
        print("viewHeight = \(viewHeight)")
        
        // REAL:
//        TODO: Добавить проверку высоты заголовка (если превышает высоту контейнера, нужно сжимать содержимое)
        var viewY = UIScreen.main.bounds.height * 0.33 - viewHeight / 2
        if viewHeight > UIScreen.main.bounds.height * 0.66 {
            print("viewHeight > \(UIScreen.main.bounds.height * 0.66)")
            viewY = displayArea.bounds.height / 2 - viewHeight / 2
        }
        let viewFrame = CGRect(x: 0,
                               y: viewY,
                               width: displayArea.bounds.width,
                               height: viewHeight)
        view.frame = viewFrame
        displayArea.addSubview(view)
        
        // MOCK:
        let bottomHalf = UIView()
        bottomHalf.layer.borderColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        bottomHalf.layer.borderWidth = 1
        bottomHalf.frame = CGRect(x: 0,
                                  y: view.bounds.height / 2,
                                  width: view.bounds.width,
                                  height: view.bounds.height / 2)
        view.addSubview(bottomHalf)
        let label = UILabel()
        label.text = String(Float(quotient))
        label.sizeToFit()
        view.addSubview(label)
    }
}

// MARK: -
private func shuffleLetters(_ string: String) -> String {
    var chars = Array(String(string.shuffled()).lowercased())
    chars[0] = Character(String(chars[0]).uppercased())
    return String(chars)
}

