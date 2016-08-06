//
//  PremierCollections.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/12/15.
//  Copyright © 2015 Ricardo Pereira. All rights reserved.
//

import Foundation

// Unite/Combine immutable dictionaries
public func + <K,V> (left: Dictionary<K,V>, right: Dictionary<K,V>?) -> Dictionary<K,V> {
    guard let right = right else { return left }
    return left.reduce(right) {
        var new = $0 as [K:V]
        new.updateValue($1.1, forKey: $1.0)
        return new
    }
}

// Unite/Combine mutable dictionaries
public func += <K,V> (inout left: Dictionary<K,V>, right: Dictionary<K,V>?) {
    guard let right = right else { return }
    right.forEach { key, value in
        left.updateValue(value, forKey: key)
    }
}
