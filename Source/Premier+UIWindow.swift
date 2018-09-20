//
//  Premier+UIWindow.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIWindow {

    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewController(from: self.rootViewController)
    }

    public static func getVisibleViewController(from viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return UIWindow.getVisibleViewController(from: navigationController.visibleViewController)
        }
        else if let tabBarController = viewController as? UITabBarController {
            return UIWindow.getVisibleViewController(from: tabBarController.selectedViewController)
        }
        else {
            if let presentedViewController = viewController?.presentedViewController {
                return UIWindow.getVisibleViewController(from: presentedViewController)
            }
            else {
                return viewController
            }
        }
    }

}
