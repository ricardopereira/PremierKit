//
//  PremierFoundation.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/07/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import Foundation

public extension String {
    
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

    func replace(value: String, withString string: String) -> String {
        return self.stringByReplacingOccurrencesOfString(value, withString: string, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
}

public extension NSURLResponse {
    
    var httpStatusCode: Int {
        if let httpResponse = self as? NSHTTPURLResponse {
            return httpResponse.statusCode
        }
        else {
            return 0
        }
    }
    
}

public extension NSData {

    var base64String: String {
        return self.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
    
    var utf8String: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding) as? String ?? ""
    }
    
}

public extension NSObject {

    var toBase64: String {
        return (try? NSJSONSerialization.dataWithJSONObject(self, options: NSJSONWritingOptions(rawValue: 0)).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))) ?? ""
    }
    
}

extension NSDate: Comparable { }

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs.compare(rhs) == .OrderedSame)
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs.compare(rhs) == .OrderedAscending)
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs.compare(rhs) == .OrderedDescending)
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs < rhs || lhs == rhs)
}

public func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs > rhs || lhs == rhs)
}

public extension NSDate {
    func isBefore(other: NSDate) -> Bool {
        return self.compare(other) == NSComparisonResult.OrderedAscending
    }
}

public extension NSRegularExpression {

    class func match(value: String?, pattern: String) -> Bool {
        guard let value = value else {
            return false
        }
        let options = NSRegularExpressionOptions()
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let range = NSMakeRange(0, value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        return regex.rangeOfFirstMatchInString(value, options: [], range: range).location != NSNotFound
    }

    class func extract(value: String?, pattern: String) -> String? {
        guard let value = value else {
            return nil
        }
        let options = NSRegularExpressionOptions()
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let range = NSMakeRange(0, value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let result = regex.firstMatchInString(value, options: [], range: range)
        guard let textRange = result?.rangeAtIndex(0) else { return nil }
        let convertedRange =  value.startIndex.advancedBy(textRange.location)..<value.startIndex.advancedBy(textRange.location+textRange.length)
        return value.substringWithRange(convertedRange)
    }
    
}
