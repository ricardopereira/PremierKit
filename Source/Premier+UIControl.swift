//
//  Premier+UIControl.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 29/11/2021.
//  Copyright © 2021 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIControl {

    public func removeAllTargets() {
        removeTarget(nil, action: nil, for: .allEvents)
    }

}
