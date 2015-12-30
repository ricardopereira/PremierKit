//
//  PremierUIKit.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/07/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import UIKit

extension String {
    
    /// Trim whitespace
    var trim: String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    /// Email validation
    var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(self)
    }
    
    /// Email validation
    var isPhoneNumber: Bool {
        let phoneRegex = "\\+351[0-9]{9}"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluateWithObject(self)
    }
    
    /// Double value
    var toDouble: Double? {
        return (self as NSString).doubleValue
    }
    
    /// Integer value
    var toInteger: Int? {
        return (self as NSString).integerValue
    }
    
}

extension UIFont {
    
    /// Size of text
    func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat(DBL_MAX)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self], context: nil).size
    }

}

extension NSURLResponse {
    
    var httpStatusCode: Int {
        if let httpResponse = self as? NSHTTPURLResponse {
            return httpResponse.statusCode
        }
        else {
            return 0
        }
    }
    
}

extension NSData {
    
    var utf8String: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding) as? String ?? ""
    }
    
}
