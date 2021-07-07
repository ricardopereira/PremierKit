//
//  PremierUIKit.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/07/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import UIKit


// MARK: ViewControllerPresentDialogs

public protocol ViewControllerPresenter: AnyObject {
    var tabBarController: UITabBarController? { get }
    var navigationController: UINavigationController? { get }
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Swift.Void)?)
}

public protocol ViewControllerDialogsPresenter: ViewControllerPresenter {
    func showConfimationDialog(_ title: String?, message: String?, acceptButtonTitle: String?, acceptButtonStyle: UIAlertAction.Style?, completionAccepted: @escaping () -> Void)
    func showMessage(_ title: String, message: String, handler: ((UIAlertAction) -> Void)?)
}

public extension ViewControllerDialogsPresenter {

    func showConfimationDialog(_ title: String?, message: String?, acceptButtonTitle: String? = nil, acceptButtonStyle: UIAlertAction.Style? = nil, completionAccepted: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: acceptButtonTitle ?? "OK", style: acceptButtonStyle ?? .default) { action in
            completionAccepted()
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func showMessage(_ title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}

// MARK: ViewControllerErrorPresenter

public protocol ViewControllerErrorPresenter {
    func showError(_ message: String, handler: ((UIAlertAction) -> Void)?)
}

public extension ViewControllerErrorPresenter where Self: ViewControllerPresenter {

    func showError(_ message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}

// MARK: ViewControllerKeyboardPresenter

public protocol ViewControllerKeyboardPresenter {
    func hideKeyboard()
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

public extension ViewControllerKeyboardPresenter where Self: UIViewController {

    func hideKeyboard() {
        self.view.endEditing(true)
    }

}


// MARK: - UIViewController helpers

public extension UIViewController {

    func backToRootViewController(_ animated: Bool = true) {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }

    func smoothlyDeselectRows(tableView: UITableView?) {
        // Get the initially selected index paths, if any
        let selectedIndexPaths = tableView?.indexPathsForSelectedRows ?? []

        // Grab the transition coordinator responsible for the current transition
        if let coordinator = transitionCoordinator {
            // Animate alongside the master view controller's view
            coordinator.animateAlongsideTransition(in: parent?.view, animation: { context in
                // Deselect the cells, with animations enabled if this is an animated transition
                selectedIndexPaths.forEach {
                    tableView?.deselectRow(at: $0, animated: context.isAnimated)
                }
                }, completion: { context in
                    // If the transition was cancel, reselect the rows that were selected before,
                    // so they are still selected the next time the same animation is triggered
                    if context.isCancelled {
                        selectedIndexPaths.forEach {
                            tableView?.selectRow(at: $0, animated: false, scrollPosition: .none)
                        }
                    }
            })
        }
        else { // If this isn't a transition coordinator, just deselect the rows without animating
            selectedIndexPaths.forEach {
                tableView?.deselectRow(at: $0, animated: false)
            }
        }
    }

}
