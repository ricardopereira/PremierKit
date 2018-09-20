//
//  Premier+TextTrimmer.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

public protocol TextTrimmer {
    var text: String? { get }
}

extension TextTrimmer {

    public var trimmedText: String {
        return self.text?.trim ?? ""
    }

}

extension UITextField: TextTrimmer {}
extension UILabel: TextTrimmer {}
