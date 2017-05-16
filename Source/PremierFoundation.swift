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
    public var trim: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    /// Email validation
    public var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// Email validation
    public var isPhoneNumber: Bool {
        let phoneRegex = "\\+351[0-9]{9}"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
    }
    
    /// Double value
    public var toDouble: Double? {
        return (self as NSString).doubleValue
    }
    
    /// Integer value
    public var toInteger: Int? {
        return (self as NSString).integerValue
    }

    /// Replace a string with another one
    public func replace(_ value: String, withString string: String) -> String {
        return self.replacingOccurrences(of: value, with: string, options: NSString.CompareOptions.literal, range: nil)
    }

    /// Length of Bytes using UTF8 encoding
    public var length: Int {
        return self.lengthOfBytes(using: String.Encoding.utf8)
    }

    /// String is not empty
    public var isNotEmpty: Bool {
        return !isEmpty
    }

    /// Get a substring to index
    public func substringToIndex(_ index: Int) -> String {
        if index > length - 1 {
            return ""
        }
        return substring(to: self.characters.index(self.startIndex, offsetBy: index))
    }

    /// Get a substring from index
    public func substringFromIndex(_ index: Int) -> String {
        if index > length - 1 {
            return ""
        }
        return substring(from: self.characters.index(self.startIndex, offsetBy: index))
    }

}

public extension URLResponse {
    
    public var httpStatusCode: Int {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        else {
            return 0
        }
    }
    
}

public extension Data {

    public var base64String: String {
        return self.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
    public var utf8String: String {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as? String ?? ""
    }
    
}

public extension NSObject {

    public var toBase64: String {
        return (try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0)).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))) ?? ""
    }
    
}

public extension Date {

    public var timeIntervalUntilNow: TimeInterval {
        return -timeIntervalSinceNow
    }

    func isBefore(_ other: Date) -> Bool {
        return self.compare(other) == ComparisonResult.orderedAscending
    }

}

public extension NSRegularExpression {

    public class func match(_ value: String?, pattern: String) -> Bool {
        guard let value = value else {
            return false
        }
        let options = NSRegularExpression.Options()
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let range = NSMakeRange(0, value.lengthOfBytes(using: String.Encoding.utf8))
        return regex.rangeOfFirstMatch(in: value, options: [], range: range).location != NSNotFound
    }

    public class func extract(_ value: String?, pattern: String) -> String? {
        guard let value = value else {
            return nil
        }
        let options = NSRegularExpression.Options()
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let range = NSMakeRange(0, value.lengthOfBytes(using: String.Encoding.utf8))
        let result = regex.firstMatch(in: value, options: [], range: range)
        guard let textRange = result?.rangeAt(0) else { return nil }
        let convertedRange =  value.characters.index(value.startIndex, offsetBy: textRange.location)..<value.characters.index(value.startIndex, offsetBy: textRange.location+textRange.length)
        return value.substring(with: convertedRange)
    }
    
}
