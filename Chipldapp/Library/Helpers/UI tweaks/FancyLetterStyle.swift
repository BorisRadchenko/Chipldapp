//
//  FancyLetterStyle.swift
//  Chipldapp
//
//  Created by Mr.Б on 11/10/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

// TODO: Добавить возможность оформления в компактном режиме (размер шрифта от минимального до +5)
// TODO: Добавить новую структуру для оформления в самом крупногабаритном режиме

struct FancyLetterStyle {
    let size: CGFloat
    let font: UIFont
    let foregroundColor: UIColor
    let backgroundColor: UIColor
    let strokeColor: UIColor
    let strokeWidth: NSNumber
    
    init() {
        let fontNames = ["Arial-BoldMT", "TimesNewRomanPS-BoldMT"]
        let minFontSize: CGFloat = 25
        let maxFontSize: CGFloat = 67
        let foregroundColors = [#colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.9803921569, blue: 0.9411764706, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        let backgroundColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.3137254902, alpha: 1), #colorLiteral(red: 0.2705882353, green: 0.3176470588, blue: 0.3960784314, alpha: 1), #colorLiteral(red: 1, green: 0.8745098039, blue: 0, alpha: 1)]
        let strokeColor = #colorLiteral(red: 0.6679443717, green: 0.473043263, blue: 0, alpha: 1)
        self.size = CGFloat.random(in: minFontSize ..< maxFontSize)
        self.font = UIFont(name: fontNames.randomElement()!, size: self.size)!
        self.foregroundColor = foregroundColors.randomElement()!
        self.backgroundColor = backgroundColors.randomElement()!
        if backgroundColor == #colorLiteral(red: 1, green: 0.8745098039, blue: 0, alpha: 1) {
            self.strokeColor = strokeColor
            self.strokeWidth = -1
        } else {
            self.strokeColor = foregroundColor
            self.strokeWidth = 0
        }
    }
    
    private static func randomAttributes() -> [NSAttributedString.Key : Any] {
        let style = FancyLetterStyle()
        let attributes = [NSAttributedString.Key.font             : style.font,
                          NSAttributedString.Key.foregroundColor  : style.foregroundColor,
                          NSAttributedString.Key.backgroundColor  : style.backgroundColor,
                          NSAttributedString.Key.strokeColor      : style.strokeColor,
                          NSAttributedString.Key.strokeWidth      : style.strokeWidth] as [NSAttributedString.Key : Any]
        return attributes
    }
    
    static func decorate(_ character: Character) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: String(character))
        attributedString.addAttributes(FancyLetterStyle.randomAttributes(), range: NSRange(location:0,length:1))
        return attributedString
    }
}
