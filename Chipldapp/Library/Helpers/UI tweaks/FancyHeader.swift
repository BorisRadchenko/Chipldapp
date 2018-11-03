//
//  FancyHeader.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit


extension FancyHeader {
	
	struct Appearance {
		let artistFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: 39)
		let artistMinFontSize = 15
		let spacersFont = UIFont(name: "Helvetica Neue", size: 25)
	}
}

final class FancyHeader {
	
	//MARK: - Public
	
    var title: String?
    var artist: String?
    var shuffledPlaceholder: String {
		get {
			return shuffleLetters(placeholder)
		}
	}
	var displayArea: UIView
	
	//MARK: - Private
	
	private var placeholder: String
	private let appearance = Appearance()
	
    // MARK: -
	
	
    // TODO: Вычислить экспериментально минимальные ширину и высоту
	
    var minDisplayAreaWidth: CGFloat = 0
    var minDisplayAreaHeight: CGFloat = 0
    var indent: CGFloat = 20
	
    // MARK: -
	
	
	lazy var spaceLabel: UILabel = {
		let view = UILabel()
		view.font = appearance.spacersFont
		view.text = " "
		view.sizeToFit()
		return view
	}()
	
	lazy var hyphenLabel: UILabel = {
		let view = UILabel()
		view.font = appearance.spacersFont
		view.text = "-"
		view.sizeToFit()
		return view
	}()
	
	private lazy var artistHeaderLabel: UILabel = {
		let view = UILabel()
		view.font = appearance.artistFont
		view.numberOfLines = 0
		view.textAlignment = .center
		return view
	}()
	
    // MARK: -
	
    private var titleHeaderParagraph: FancyTextParagraph? = nil
	
    private let titlePartsSpace: CGFloat = 20
    
	//MARK: - Init
	
    init(title: String? = nil, artist: String? = nil, placeholder: String, displayArea: UIView) {
        self.title = title
        self.artist = artist
        self.placeholder = placeholder
        self.displayArea = displayArea
    }
	
	// MARK: - М Е Т О Д Ы:
	
    func hasEnoughDisplayAreaSize() -> Bool {
        guard displayArea.bounds.width >= minDisplayAreaWidth else { return false }
        guard displayArea.bounds.height >= minDisplayAreaHeight else { return false }
        return true
    }
    
    func prepareTitleHeader() {
        // TODO: Рефакторинг
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
    
    func prepareArtistHeader() {
        // TODO: Рефакторинг
        guard let artist = artist else {
            print("There is no artist name to show")
            return
        }
		artistHeaderLabel.text = artist
        artistHeaderLabel.frame = CGRect(x: 0, y: 0, width: displayArea.bounds.width - indent * 2, height: 0)
        artistHeaderLabel.sizeToFit()
    }
    
    func showArtistHeader(topY: CGFloat) {
        // TODO: Рефакторинг
        artistHeaderLabel.frame = CGRect(x: leadingX(byExternalWidth: displayArea.bounds.width, ownWidth: artistHeaderLabel.bounds.width), y: topY, width: artistHeaderLabel.bounds.width, height: artistHeaderLabel.bounds.height)
        displayArea.addSubview(artistHeaderLabel)
    }
    
    func getArtistHeaderHeight() -> CGFloat {
        return artistHeaderLabel.bounds.height
    }
    
    func showPlaceholder() {
        // TODO: Рефакторинг
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
    
    func showHeader() {
        // TODO: Рефакторинг
        if title != "" {
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
}

private func shuffleLetters(_ string: String) -> String {
    // TODO: Рефакторинг
    var chars = Array(String(string.shuffled()).lowercased())
    chars[0] = Character(String(chars[0]).uppercased())
    return String(chars)
}
