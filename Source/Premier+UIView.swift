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

    // MARK: - AutoLayout

    public var heightLayout: NSLayoutConstraint? {
        return constraints.filter({
            $0.firstAttribute == .height &&
            $0.firstAnchor === self.heightAnchor &&
            $0.firstItem === self &&
            $0.secondItem == nil &&
            $0.secondAnchor == nil
        }).first
    }

    public var widthLayout: NSLayoutConstraint? {
        return constraints.filter({
            $0.firstAttribute == .width &&
            $0.firstAnchor === self.widthAnchor &&
            $0.firstItem === self &&
            $0.secondItem == nil &&
            $0.secondAnchor == nil
        }).first
    }

}
