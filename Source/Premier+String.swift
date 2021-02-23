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

    /// Email validation.
    var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    /// PT Phone validation.
    var isPhoneNumberPT: Bool {
        let phoneRegex = "\\+351[0-9]{9}"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
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
