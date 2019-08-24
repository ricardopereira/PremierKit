//
//  Premier+UIViewController.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 24/08/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIViewController {

    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

}
