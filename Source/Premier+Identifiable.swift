//
//  Premier+Identifiable.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 23/02/2021.
//  Copyright © 2021 Ricardo Pereira. All rights reserved.
//

import Foundation

/// Protocol composition with an extension to provide `Hashable` conformance to an object.
public protocol IdentifiableHashable: Hashable & Identifiable {}

public extension IdentifiableHashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
