//
//  Premier+UIButton.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 09/09/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import UIKit

open class CustomButton: UIButton {

    open var titleFont: UIFont = .systemFont(ofSize: 15) {
        didSet {
            invalidateTitle()
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted == oldValue {
                return
            }
            if self.isHighlighted {
                if #available(iOS 10.0, *) {
                    UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
                        self.alpha = 0.3
                        }.startAnimation()
                }
                else {
                    UIView.animate(withDuration: 0.1) {
                        self.alpha = 0.3
                    }
                }
            }
            else {
                if #available(iOS 10.0, *) {
                    UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
                        self.alpha = 1.0
                        }.startAnimation()
                }
                else {
                    UIView.animate(withDuration: 0.1) {
                        self.alpha = 1.0
                    }
                }
            }
        }
    }

    override open func tintColorDidChange() {
        super.tintColorDidChange()
        invalidateTitle()
    }

    open func setTitle(_ title: String) {
        setAttributedTitle(NSAttributedString(string: title.uppercased(), attributes: [
            NSAttributedString.Key.font: self.titleFont,
            NSAttributedString.Key.foregroundColor: self.tintColor ?? .black,
        ]), for: .normal)
    }

    open func invalidateTitle() {
        if let title = titleLabel?.text {
            setTitle(title)
        }
    }

}
