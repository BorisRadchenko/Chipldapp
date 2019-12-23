//
//  PrintNicely.swift
//  Chipldapp
//
//  Created by Mr.Б on 14.12.2019.
//  Copyright © 2019 KexitSoft. All rights reserved.
//

import Foundation

func printNicely(_ text: String) {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateStyle = .short
    formatter.dateFormat = "dd.MM.yy HH:mm:ss"
    print("\(formatter.string(from: Date())) «🔔» \(text)")
}
