//
//  FancyHeader.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

// На основе текстовых значений title, artist и placeholder
// создаёт визуальные элементы заголовка
// и надлежащим образом размещает их в заданном view

import UIKit

class FancyHeader: NSObject {
    // MARK: P R O P E R T I E S / public
    // MARK: - P R O P E R T I E S / private
    private var title: String?
    private var artist: String?
    private var placeholderText: String
    private var shuffledPlaceholder: String { get { return shuffleLetters(placeholderText) } }
    
    //private var titleHeaderParagraph: FancyTextParagraph? = nil
    //private var artistHeaderLabel: UILabel? = nil
    
    //private var minDisplayAreaWidth: CGFloat = 0 // FIXME: Вычислить экспериментально минимальные ширину и высоту
    //private var minDisplayAreaHeight: CGFloat = 0
    private var parentView: UIView
    private var headerContentView: UIView
    private var indent: CGFloat = 20                                            // FIXME: Перенести в setup
    private let titlePartsSpace: CGFloat = 20                                   //
    private let artistFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: 39)   //
    private let artistMinFontSize = 15                                          //
    private let spacersFont = UIFont(name: "Helvetica Neue", size: 25)          //
    private let spaceLabel = UILabel()                                          //
    private let hyphenLabel = UILabel()                                         //
    
    // MARK: P R O P E R T I E S / private / outlets
    // MARK: - M E T H O D S / public
    init(title: String? = nil, artist: String? = nil, placeholderText: String, parentView: UIView) {
        self.title = title
        self.artist = artist
        self.placeholderText = placeholderText
        self.parentView = parentView
        self.spaceLabel.font = spacersFont
        self.spaceLabel.text = " "
        self.spaceLabel.sizeToFit()
        self.hyphenLabel.font = spacersFont
        self.hyphenLabel.text = "-"
        self.hyphenLabel.sizeToFit()
        headerContentView = UIView() // контейнер, в котором собирается содержимое заголовка, а затем отображается в parentView
        headerContentView.frame = parentView.frame
    }
    
    func showTitleAndArtist() {
        var topY: CGFloat = 0 // верхний Y верхнего элемента заголовка
        var totalHeaderHeight: CGFloat = 0
        var metadataIsEmpty = true
        if title != nil && title != "" { // Подготовка части заголовка с названием песни
            let titleHeader = FancyTextParagraph(text: title!, container: headerContentView, indent: indent, interlineSpacing: 3, spaceLabel: spaceLabel, hyphenLabel: hyphenLabel)
            titleHeader.placeInParentViewAt(startY: topY)
            topY += titleHeader.height + titlePartsSpace
            totalHeaderHeight = titleHeader.height
            metadataIsEmpty = false
        }
        if artist != nil && artist != "" { // Подготовка части заголовка, содержащей исполнителя
            let artistHeader = createArtistHeader()
            place(label: artistHeader, inParentView: headerContentView, atY: topY)
            if totalHeaderHeight > 0 {
                totalHeaderHeight += titlePartsSpace
            }
            totalHeaderHeight += artistHeader.bounds.height
            metadataIsEmpty = false
        }
        if metadataIsEmpty { // Подготовка заглушки
            showPlaceholder()
        } else {
            placeHeaderView(withTotalHeight: totalHeaderHeight) // Размещение заголовка
        }
    }
    func showPlaceholder() {
        let placeholderHeader = FancyTextParagraph(text: shuffledPlaceholder, container: headerContentView, indent: indent, interlineSpacing: 3, spaceLabel: spaceLabel, hyphenLabel: hyphenLabel)
        placeholderHeader.placeInParentViewAt(startY: 0)
        placeHeaderView(withTotalHeight: placeholderHeader.height)
    }
    
    // MARK: M E T H O D S / public / actions
    // MARK: - M E T H O D S / private
    private func placeHeaderView(withTotalHeight totalHeaderHeight: CGFloat) {
        headerContentView.frame.size.height = totalHeaderHeight
        // Разместить headerView в зависимости от величины его высоты по центру или по верхней трети
        if totalHeaderHeight > UIScreen.main.bounds.height * 0.5 {
            headerContentView.frame.origin.y = headerContentView.topY(byExternalHeight: parentView.bounds.height)
        } else {
            headerContentView.frame.origin.y = headerContentView.topY(byOwnCenterY: UIScreen.main.bounds.height * 0.33)
        }
        parentView.addSubview(headerContentView)
        // При необходимости масштабировать headerView
        let scale = parentView.bounds.height / totalHeaderHeight
        if scale < 1 {
            headerContentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    private func shuffleLetters(_ string: String) -> String {
        var chars = Array(String(string.shuffled()).lowercased())
        chars[0] = Character(String(chars[0]).uppercased())
        return String(chars)
    }
    private func createArtistHeader() -> UILabel {
        let label = UILabel()
        label.text = artist!
        label.font = artistFont
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }
    private func place(label: UILabel, inParentView parentView: UIView, atY startY: CGFloat) {
        label.frame.size.width = parentView.bounds.width - indent * 2
        label.frame.origin.y = startY
        label.sizeToFit()
        label.frame.origin.x = label.leadingX(byExternalWidth: parentView.bounds.width)
        parentView.addSubview(label)
    }
    // private func hasEnoughDisplayAreaSize() -> Bool {
    //     guard parentView.bounds.width >= minDisplayAreaWidth else { return false }
    //     guard parentView.bounds.height >= minDisplayAreaHeight else { return false }
    //     return true
    // }
}
