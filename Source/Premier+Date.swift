//
//  Premier+Date.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import Foundation

extension Date {

    public var timeIntervalUntilNow: TimeInterval {
        return -timeIntervalSinceNow
    }

    public func isBefore(_ other: Date) -> Bool {
        return self.compare(other) == ComparisonResult.orderedAscending
    }

}
