//
//  Premier+UIFont.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIFont {

    public func size(of string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self], context: nil).size
    }

}
