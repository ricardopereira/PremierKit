//
//  Premier+String.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import Foundation

extension String {

    /// Trim whitespace.
    public var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    /// Truncate string after a given length if it is longer than the given length and add a text at the end when it overflows (ellipsis by default).
    public func truncated(at maxLength: Int, suffix: String? = nil) -> String {
        let value = self.trimmed
        if value.lengthOfBytes(using: .utf8) > maxLength {
            let index = self.index(self.startIndex, offsetBy: min(self.count, max(0, maxLength)))
            let truncated = String(value[..<index])
            if let suffix = suffix {
                return truncated + suffix
            }
            return truncated
        }
        return value
    }

    /// Email validation (based on https://emailregex.com/)
    func isEmail() -> Bool {
        let emailRegex = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        return validate(regex: emailRegex)
    }

    /// Validate string with a Regular Expression formula.
    func validate(regex: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    /// String is not empty.
    public var isNotEmpty: Bool {
        return !isEmpty
    }

    /// String is blank.
    public var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }

}

extension Optional where Wrapped == String {

    public var isBlank: Bool {
        return self?.isBlank ?? true
    }

}
