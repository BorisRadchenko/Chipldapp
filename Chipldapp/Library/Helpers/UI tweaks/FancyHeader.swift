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
    
    // MARK: P R O P E R T I E S / private / outlets
    // MARK: - M E T H O D S / public
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
    func show() { // FIXME: Добавить проверку соответствия displayArea минимальным размерам
     // 1. Составить заголовок из artist, title, placeholder
        var topY: CGFloat = 0 // верхний Y верхнего элемента заголовка
        let headerView = UIView() // контейнер, в котором собирается содержимое заголовка, а затем отображается в displayArea
        headerView.frame = displayArea.frame
        var totalHeaderHeight: CGFloat = 0
        var metadataIsEmpty = true
        if title != nil && title != "" {
            let titleHeader = FancyTextParagraph(text: title!, container: headerView, indent: indent, interlineSpacing: 3, spaceLabel: spaceLabel, hyphenLabel: hyphenLabel)
            titleHeader.showInContainerAt(startY: topY)
            topY += titleHeader.height + titlePartsSpace
            totalHeaderHeight = titleHeader.height
            metadataIsEmpty = false
            print(" = = = [\(self.className)] Подготовлено название песни (\(title!)), высота = \(titleHeader.height).")
        }
        if artist != nil && artist != "" { // создать artist-часть заголовка
            let artistHeader = createArtistHeader()
            show(label: artistHeader, inContainer: headerView, atY: topY) // добавить artist-часть заголовка в headerView
            if totalHeaderHeight > 0 {
                totalHeaderHeight += titlePartsSpace
            }
            totalHeaderHeight += artistHeader.bounds.height
            metadataIsEmpty = false
            print(" = = = [\(self.className)] Подготовлен исполнитель (\(artist!)), высота = \(artistHeader.bounds.height).")
        }
        if metadataIsEmpty { // создать placeholder-заголовок
            let placeholderHeader = FancyTextParagraph(text: shuffledPlaceholder, container: headerView, indent: indent, interlineSpacing: 3, spaceLabel: spaceLabel, hyphenLabel: hyphenLabel)
            placeholderHeader.showInContainerAt(startY: topY)
            totalHeaderHeight = placeholderHeader.height
            print(" = = = [\(self.className)] Подготовлена заглушка, высота = \(placeholderHeader.height).")
        }
        headerView.frame.size.height = totalHeaderHeight
        print(" = = = [\(self.className)] Общая высота заголовка = \(totalHeaderHeight).")
        // 2. Разместить headerView в зависимости от его высоты по центру или по верхней трети
        if totalHeaderHeight > UIScreen.main.bounds.height * 0.5 {
            headerView.frame.origin.y = headerView.topY(byExternalHeight: displayArea.bounds.height)
            print(" = = = [\(self.className)] Общая высота заголовка больше половины высоты экрана, размещаем заголовок по центру верхней области (\(displayArea.bounds.height/2)).")
        } else {
            headerView.frame.origin.y = headerView.topY(byOwnCenterY: UIScreen.main.bounds.height * 0.33)
            print(" = = = [\(self.className)] Общая высота заголовка меньше половины высоты экрана, центрируем заголовок по верхней трети экрана (\(UIScreen.main.bounds.height * 0.33)).")
        }
        displayArea.addSubview(headerView)
        // 3. При необходимости масштабировать headerView
        let scale = displayArea.bounds.height / totalHeaderHeight
        if scale < 1 {
            headerView.transform = CGAffineTransform(scaleX: scale, y: scale)
            print(" = = = [\(self.className)] К заголовку применён коэффициент масштабирования = \(scale).")
        }
    }
    
    // MARK: M E T H O D S / public / actions
    // MARK: - M E T H O D S / private
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
    private func show(label: UILabel, inContainer container: UIView, atY startY: CGFloat) {
        label.frame.size.width = container.bounds.width - indent * 2
        label.frame.origin.y = startY
        label.sizeToFit()
        label.frame.origin.x = label.leadingX(byExternalWidth: container.bounds.width)
        container.addSubview(label)
    }
    private func hasEnoughDisplayAreaSize() -> Bool {
        guard displayArea.bounds.width >= minDisplayAreaWidth else { return false }
        guard displayArea.bounds.height >= minDisplayAreaHeight else { return false }
        return true
    }
}
