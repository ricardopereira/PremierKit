//
//  Premier+UIGestureRecognizer.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 24/08/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIGestureRecognizer.State: CustomStringConvertible {

    public var description: String {
        switch self {
        case .began:
            return "began"
        case .cancelled:
            return "cancelled"
        case .changed:
            return "changed"
        case .ended:
            return "ended"
        case .failed:
            return "failed"
        case .possible:
            return "possible"
        default:
            return "UIGestureRecognizer.State.\(self) not implemented"
        }
    }

}
