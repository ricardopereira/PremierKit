//
//  Premier+UIScrollView.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIScrollView {

    public func scrollToBottom(_ animated: Bool = false) {
        let offsetY = self.contentSize.height - self.frame.size.height
        self.setContentOffset(CGPoint(x: 0, y: max(0, offsetY)), animated: animated)
    }

    // MARK: - Keyboard

    fileprivate func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        if contentInset.bottom == 0 && adjustmentHeight < 0 {
            return
        }
        contentInset.bottom += adjustmentHeight
        scrollIndicatorInsets.bottom += adjustmentHeight
    }

    @objc internal func keyboardWillShow(_ sender: Notification) {
        adjustInsetForKeyboardShow(true, notification: sender)
    }

    @objc internal func keyboardWillHide(_ sender: Notification) {
        adjustInsetForKeyboardShow(false, notification: sender)
    }

    @objc internal func keyboardWillChangeFrame(_ sender: Notification) {
        contentInset.bottom = 0
        scrollIndicatorInsets.bottom = 0
    }

    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

}
