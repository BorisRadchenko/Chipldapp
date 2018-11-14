//
//  NSObjectExtension.swift
//  Chipldapp
//
//  Created by Mr.Б on 12/11/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
