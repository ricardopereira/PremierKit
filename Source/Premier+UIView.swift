//
//  Premier+UIView.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIView {

    public func firstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let result = subview.firstResponder() {
                return result
            }
        }
        return nil
    }

}
