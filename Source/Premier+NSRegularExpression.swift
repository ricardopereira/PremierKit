//
//  Premier+NSRegularExpression.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import Foundation

extension NSRegularExpression {

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
        guard let textRange = result?.range(at: 0) else { return nil }
        let convertedRange =  value.index(value.startIndex, offsetBy: textRange.location)..<value.index(value.startIndex, offsetBy: textRange.location+textRange.length)
        return String(value[convertedRange])
    }

}
