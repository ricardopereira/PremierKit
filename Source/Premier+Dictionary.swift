//
//  PremierCollections.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/12/15.
//  Copyright © 2015 Ricardo Pereira. All rights reserved.
//

import Foundation

extension Dictionary {

    /// Unite/Combine immutable dictionaries
    public static func +(lhs: Dictionary, rhs: Dictionary?) -> Dictionary {
        guard let rhs = rhs else {
            return lhs
        }
        return lhs.merging(rhs, uniquingKeysWith: { current, new in new })
    }

    /// Unite/Combine mutable dictionaries
    public static func +=(lhs: inout Dictionary, rhs: Dictionary?) {
        guard let rhs = rhs else {
            return
        }
        lhs.merge(rhs, uniquingKeysWith: { current, new in new })
    }

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public func at(_ key: Key) -> Iterator.Element? {
        guard let index = index(forKey: key) else {
            return nil
        }
        return at(index)
    }

}
