//
//  PremierUIKit.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/07/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import UIKit

public extension UIFont {
    
    /// Size of text
    public func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat(DBL_MAX)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self], context: nil).size
    }

}

protocol TextTrimmer {
    var text: String? { get }
}

extension TextTrimmer {

    var trimmedText: String {
        return self.text?.trim ?? ""
    }

}

extension UITextField: TextTrimmer { }

extension UILabel: TextTrimmer { }

extension UIScrollView {

    public func scrollToBottom(animated: Bool = false) {
        let offsetY = self.contentSize.height - self.frame.size.height
        self.setContentOffset(CGPoint(x: 0, y: max(0, offsetY)), animated: animated)
    }
    
}

extension UIEdgeInsets {

    static var zero: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
