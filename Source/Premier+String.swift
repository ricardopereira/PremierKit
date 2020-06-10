//
//  Premier+String.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import Foundation

extension String {

    /// Trim whitespace
    public var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    /// Truncates after a given length if string is longer than length
    public func truncated(by length: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: min(self.count, max(0, length)))
        return String(self[..<index])
    }

    /// Email validation
    public var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    /// PT Phone validation
    public var isPhoneNumberPT: Bool {
        let phoneRegex = "\\+351[0-9]{9}"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: self)
    }

    /// String is not empty
    public var isNotEmpty: Bool {
        return !isEmpty
    }

    /// String is blank
    public var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }

}

extension Optional where Wrapped == String {

    public var isBlank: Bool {
        return self?.isBlank ?? true
    }

}
