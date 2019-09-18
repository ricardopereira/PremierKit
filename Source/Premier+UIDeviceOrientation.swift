//
//  Premier+UIDeviceOrientation.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 24/08/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIDeviceOrientation: CustomStringConvertible {

    public var description: String {
        switch self {
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .faceDown:
            return "faceDown"
        case .faceUp:
            return "faceUp"
        case .unknown:
            return "unknown"
        default:
            return "UIDeviceOrientation.\(self) not implemented"
        }
    }

}
