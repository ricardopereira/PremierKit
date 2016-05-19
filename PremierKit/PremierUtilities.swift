//
//  PremierUtilities.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 19/05/16.
//  Copyright © 2016 Pearland. All rights reserved.
//

import Foundation

public public func delay(seconds: NSTimeInterval, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(seconds * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
