//
//  Premier+Collection.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 23/08/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public func at(_ i: Index) -> Iterator.Element? {
        return (i >= startIndex && i < endIndex) ? self[i] : nil
    }

}
