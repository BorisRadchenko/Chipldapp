//
//  MessageScreenController.swift
//  Chipldapp
//
//  Created by Mr.Б on 16/11/2018.
//  Copyright © 2018 KexitSoft. All rights reserved.
//

import UIKit

class MessageScreenController: UIViewController {
    
    @IBOutlet weak var smallFrame: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        smallFrame.layer.cornerRadius = 5
    }
    
    @IBAction func closeScreen(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
