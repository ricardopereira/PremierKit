//
//  Premier+UIUserInterfaceSizeClass.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 24/08/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIUserInterfaceSizeClass: CustomStringConvertible {

    public var description: String {
        switch self {
        case .compact:
            return "compact"
        case .regular:
            return "regular"
        case .unspecified:
            return "unspecified"
        default:
            return "UIUserInterfaceSizeClass.\(self) not implemented"
        }
    }

}
