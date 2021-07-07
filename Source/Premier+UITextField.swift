//
//  Premier+UITextField.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 07/07/2021.
//  Copyright © 2021 Ricardo Pereira. All rights reserved.
//

import UIKit

open class UIFieldSeparator: UIView {

    fileprivate var originalColor: UIColor = .black

    fileprivate lazy var errorLabel = UILabel()
    open var error: String? {
        didSet {
            guard let errorMessage = error else {
                self.backgroundColor = originalColor
                errorLabel.removeFromSuperview()
                return
            }
            if errorMessage.isEmpty == false && errorLabel.superview == nil {
                addSubview(errorLabel)
                errorLabel.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 18)
                errorLabel.textAlignment = .right
                self.originalColor = backgroundColor ?? .black
                self.backgroundColor = .red
                errorLabel.textColor = self.backgroundColor
                errorLabel.font = errorLabel.font.withSize(10)
                setErrorMessageWithAnimation(errorMessage)
            }
            else if errorMessage.isEmpty == false {
                setErrorMessageWithAnimation(errorMessage)
            }
            else {
                self.backgroundColor = originalColor
                errorLabel.removeFromSuperview()
            }
        }
    }

    fileprivate func setErrorMessageWithAnimation(_ message: String) {
        if self.errorLabel.trimmedText == message {
            return
        }
        let fadeTransition = CATransition()
        fadeTransition.duration = 0.2
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.errorLabel.text = message
            self.errorLabel.layer.add(fadeTransition, forKey: kCATransition)
        }
        errorLabel.text = ""
        errorLabel.layer.add(fadeTransition, forKey: kCATransition)
        CATransaction.commit()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        errorLabel.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 18)
    }

}


// MARK: ViewControllerFieldValidator

public protocol ViewControllerFieldValidator {
    @discardableResult func verifyContent() -> Bool
    func validateContent()
}

public extension ViewControllerFieldValidator {

    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        verifyContent()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        validateContent()
    }

}
