//
//  Premier+NSLayoutConstraint.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

    @discardableResult
    public func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }

    @discardableResult
    public func deactivate() -> NSLayoutConstraint {
        isActive = false
        return self
    }

    public func priority(of value: Float) -> NSLayoutConstraint {
        return priority(of: UILayoutPriority(value))
    }

    public func priority(of value: UILayoutPriority) -> NSLayoutConstraint {
        priority = value
        return self
    }

    public func identifier(value: String) -> NSLayoutConstraint {
        identifier = value
        return self
    }

}
