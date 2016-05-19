//
//  PremierDialogs.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 15/10/2015.
//  Copyright © 2015 Ricardo Pereira. All rights reserved.
//

import UIKit

struct PremierDialogOptions {
    let parent: UIViewController
    let title: String
    let placeholder: String
    let moreActions: [String]
}

func askString(options: PremierDialogOptions, success: ([String])->(), fields: Optional<(UITextField)->()> = nil) {
    let alertController = UIAlertController(title: options.title, message: nil, preferredStyle: .Alert)
    
    let addStringAction = UIAlertAction(title: "Add", style: .Default) { action in
        // Did press
        var values: [String] = []
        guard let textFields = alertController.textFields else { return }
        for field in textFields {
            values.append(field.text ?? "")
        }

        success(values)
    }
    addStringAction.enabled = false
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    
    // Text field: string value
    alertController.addTextFieldWithConfigurationHandler { textField in
        textField.placeholder = options.placeholder
        
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { notification in
            addStringAction.enabled = textField.text != ""
        }
    }

    if !options.moreActions.isEmpty {
        for action in options.moreActions {
            alertController.addTextFieldWithConfigurationHandler { textField in
                textField.placeholder = action
                // FIXME:
                textField.keyboardType = .DecimalPad

                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { notification in
                    addStringAction.enabled = textField.text != ""
                }
            }
        }
    }

    alertController.textFields?.forEach({ if let perform = fields { perform($0) } })
    
    alertController.addAction(addStringAction)
    alertController.addAction(cancelAction)
    
    options.parent.presentViewController(alertController, animated: true, completion: nil)
}