//
//  PremierDialogs.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 15/10/2015.
//  Copyright © 2015 Ricardo Pereira. All rights reserved.
//

import UIKit

public struct PremierDialogOptions {
    let parent: UIViewController
    let title: String
    let placeholder: String
    let moreActions: [String]
}

public func askString(_ options: PremierDialogOptions, success: @escaping ([String])->(), fields: Optional<(UITextField)->()> = nil) {
    let alertController = UIAlertController(title: options.title, message: nil, preferredStyle: .alert)
    
    let addStringAction = UIAlertAction(title: "Add", style: .default) { action in
        // Did press
        var values: [String] = []
        guard let textFields = alertController.textFields else { return }
        for field in textFields {
            values.append(field.text ?? "")
        }

        success(values)
    }
    addStringAction.isEnabled = false
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    // Text field: string value
    alertController.addTextField { textField in
        textField.placeholder = options.placeholder
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { notification in
            addStringAction.isEnabled = textField.text != ""
        }
    }

    if !options.moreActions.isEmpty {
        for action in options.moreActions {
            alertController.addTextField { textField in
                textField.placeholder = action
                // FIXME:
                textField.keyboardType = .decimalPad

                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { notification in
                    addStringAction.isEnabled = textField.text != ""
                }
            }
        }
    }

    alertController.textFields?.forEach({ if let perform = fields { perform($0) } })
    
    alertController.addAction(addStringAction)
    alertController.addAction(cancelAction)
    
    options.parent.present(alertController, animated: true, completion: nil)
}
