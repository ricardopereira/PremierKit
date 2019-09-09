//
//  Premier+UIViewController.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 24/08/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIViewController {

    public func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    public func removeAsChildViewController() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

}
