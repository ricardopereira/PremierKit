//
//  Premier+UILabel.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 24/08/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UILabel {

    public convenience init(text: String, font: UIFont, color: UIColor = .white) {
        self.init(frame: .null)
        self.text = text
        self.font = font
        self.textColor = color
        self.numberOfLines = 0
    }

}