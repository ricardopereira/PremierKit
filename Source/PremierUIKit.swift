//
//  PremierUIKit.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/07/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import UIKit

public extension UIView {

    /// Find the first responder
    public func findFirstResponder() -> UIView? {
        if self.isFirstResponder() {
            return self
        }
        for subview in subviews {
            if let result = subview.findFirstResponder() {
                return result
            }
        }
        return nil
    }

}

public extension UIFont {
    
    /// Size of text
    public func sizeOfString(string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat(DBL_MAX)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: self], context: nil).size
    }

}

public protocol TextTrimmer {
    var text: String? { get }
}

public extension TextTrimmer {

    public var trimmedText: String {
        return self.text?.trim ?? ""
    }

}

extension UITextField: TextTrimmer { }

extension UILabel: TextTrimmer { }

public extension UIScrollView {

    public func scrollToBottom(animated: Bool = false) {
        let offsetY = self.contentSize.height - self.frame.size.height
        self.setContentOffset(CGPoint(x: 0, y: max(0, offsetY)), animated: animated)
    }
    
}

public extension UIEdgeInsets {

    public static var zero: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}


// MARK: ViewControllerPresentContent

public protocol ViewControllerPresentContent {
    func loadContent()
}


// MARK: ViewControllerPresentErrors

public protocol ViewControllerPresentErrors {
    func presentViewController(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func showError(message: String, handler: ((UIAlertAction) -> Void)?)
}

public extension ViewControllerPresentErrors {

    public func showError(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Destructive, handler: handler)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

}


// MARK: ViewControllerPresentDialogs

public protocol ViewControllerPresenter {
    func presentViewController(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

public protocol ViewControllerPresentDialogs: ViewControllerPresenter {
    func showConfimationDialog(title: String?, message: String?, acceptButtonTitle: String?, acceptButtonStyle: UIAlertActionStyle?, completionAccepted: ()->Void)
    func showMessage(title: String, message: String, handler: ((UIAlertAction) -> Void)?)
}

public extension ViewControllerPresentDialogs {

    public func showConfimationDialog(title: String?, message: String?, acceptButtonTitle: String? = nil, acceptButtonStyle: UIAlertActionStyle? = nil, completionAccepted: ()->Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: acceptButtonTitle ?? "OK", style: acceptButtonStyle ?? .Default) { action in
            completionAccepted()
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    public func showMessage(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: handler)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

}


// MARK: ViewControllerPresentKeyboard

public protocol ViewControllerPresentKeyboard {
    func hideKeyboard()
    func textFieldShouldReturn(textField: UITextField) -> Bool
}

public extension ViewControllerPresentKeyboard where Self: UIViewController {

    public func hideKeyboard() {
        self.view.endEditing(true)
    }

}


// MARK: ViewControllerFieldValidator

public protocol ViewControllerFieldValidator {
    func verifyContent() -> Bool
    func validateContent()
}

public extension ViewControllerFieldValidator {

    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        verifyContent()
        return true
    }

    public func textFieldDidEndEditing(textField: UITextField) {
        validateContent()
    }

}


// MARK: ViewControllerPresentScroll

public protocol ViewControllerPresentScroll: UITextFieldDelegate {
    var containerView: UIView! { get }
    var scrollView: UIScrollView! { get }
    var handleContainerTapGestureSelector: Selector { get }
    func setupScrollPresenter()
}

public extension ViewControllerPresentScroll where Self: UIViewController {

    public func setupScrollPresenter() {
        scrollView.setupKeyboardNotifications()
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: handleContainerTapGestureSelector))
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: handleContainerTapGestureSelector))
        containerView.subviews.flatMap{ $0 as? UITextField }.forEach { field in
            field.delegate = self
        }
    }

}

public extension UIScrollView {

    private func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 20) * (show ? 1 : -1)
        if contentInset.bottom == 0 && adjustmentHeight < 0 {
            return
        }
        contentInset.bottom += adjustmentHeight
        scrollIndicatorInsets.bottom += adjustmentHeight
    }

    internal func keyboardWillShow(sender: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: sender)
    }

    internal func keyboardWillHide(sender: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: sender)
    }

    internal func keyboardWillChangeFrame(sender: NSNotification) {
        contentInset.bottom = 0
        scrollIndicatorInsets.bottom = 0
    }

    public func setupKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillChangeFrame(_:)),
            name: UIKeyboardWillChangeFrameNotification,
            object: nil
        )
    }

}


// MARK: ViewControllerPresentPicker

public protocol ViewControllerPresentPicker: ViewControllerPresenter {
    func showPicker<T: CustomStringConvertible>(list: [T], completion: ((Int?) -> Void))
}

public class PickerViewController<T: CustomStringConvertible>: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let list: [T]

    public var selectedRow: Int {
        return pickerView.selectedRowInComponent(0)
    }

    private let titleLabel = UILabel()
    private let pickerView = UIPickerView()
    // TODO: missing Done button
    private let buttonCancel = UIButton(type: .System)
    private var initialConstraint: NSLayoutConstraint?

    @available(iOS, unavailable)
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.list = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(list: [T]) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .OverCurrentContext

        let attributedString = NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(20)])
        buttonCancel.setAttributedTitle(attributedString, forState: .Normal)
        buttonCancel.layer.masksToBounds = true
        buttonCancel.layer.cornerRadius = 14.0
        buttonCancel.backgroundColor = .whiteColor()

        if #available(iOS 9.0, *) {
            initialConstraint = buttonCancel.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor, constant: -10)
        } else {
            initialConstraint = NSLayoutConstraint(item: buttonCancel, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -10)
        }
        buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonCancel)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activateConstraints([
                buttonCancel.heightAnchor.constraintEqualToConstant(56),
                buttonCancel.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor, constant: 10),
                buttonCancel.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor, constant: -10),
                self.initialConstraint!,
            ])
        } else {
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: buttonCancel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 56),
                NSLayoutConstraint(item: buttonCancel, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 10),
                NSLayoutConstraint(item: buttonCancel, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: -10),
                self.initialConstraint!,
            ])
        }
        buttonCancel.addTarget(self, action: #selector(didTouchCancel), forControlEvents: .TouchUpInside)

        pickerView.layer.masksToBounds = true
        pickerView.layer.cornerRadius = 14.0
        pickerView.backgroundColor = .whiteColor()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activateConstraints([
                pickerView.heightAnchor.constraintEqualToConstant(180),
                pickerView.leadingAnchor.constraintEqualToAnchor(buttonCancel.leadingAnchor),
                pickerView.trailingAnchor.constraintEqualToAnchor(buttonCancel.trailingAnchor),
                pickerView.bottomAnchor.constraintEqualToAnchor(buttonCancel.topAnchor, constant: -8),
            ])
        } else {
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: pickerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 180),
                NSLayoutConstraint(item: pickerView, attribute: .Leading, relatedBy: .Equal, toItem: buttonCancel, attribute: .Leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: pickerView, attribute: .Trailing, relatedBy: .Equal, toItem: buttonCancel, attribute: .Trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: pickerView, attribute: .Bottom, relatedBy: .Equal, toItem: buttonCancel, attribute: .Top, multiplier: 1.0, constant: -8),
            ])
        }

        titleLabel.hidden = true
        titleLabel.text = "Test"
        titleLabel.textColor = .grayColor()
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleLabel.backgroundColor = .whiteColor()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activateConstraints([
                titleLabel.heightAnchor.constraintEqualToConstant(56),
                titleLabel.leadingAnchor.constraintEqualToAnchor(pickerView.leadingAnchor),
                titleLabel.trailingAnchor.constraintEqualToAnchor(pickerView.trailingAnchor),
                titleLabel.bottomAnchor.constraintEqualToAnchor(pickerView.topAnchor),
            ])
        } else {
            NSLayoutConstraint.activateConstraints([
                NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 56),
                NSLayoutConstraint(item: titleLabel, attribute: .Leading, relatedBy: .Equal, toItem: pickerView, attribute: .Leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: titleLabel, attribute: .Trailing, relatedBy: .Equal, toItem: pickerView, attribute: .Trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: pickerView, attribute: .Top, multiplier: 1.0, constant: 0),
            ])
        }
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initialConstraint?.constant = 300
        pickerView.layoutIfNeeded()
        buttonCancel.layoutIfNeeded()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.CurveEaseOut], animations: {
            self.initialConstraint?.constant = -10
            self.pickerView.layoutIfNeeded()
            self.buttonCancel.layoutIfNeeded()
            }, completion: nil)
    }

    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    internal func didTouchCancel(sender: AnyObject) {
        UIView.animateWithDuration(0.3, animations: {
            self.initialConstraint?.constant = 300
            self.pickerView.layoutIfNeeded()
            self.buttonCancel.layoutIfNeeded()
            }, completion: { _ in
                self.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    // Delegate

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row].description
    }

    // Datasource

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }

}

public extension ViewControllerPresentDialogs {

    public func showPicker<T: CustomStringConvertible>(list: [T], completion: ((Int?) -> Void)) {
        let pickerViewController = PickerViewController(list: list)
        presentViewController(pickerViewController, animated: true, completion: {
            completion(pickerViewController.selectedRow)
        })
    }

}


// MARK: UIFieldSeparator

public class UIFieldSeparator: UIView {

    private var originalColor: UIColor = .blackColor()

    private lazy var errorLabel = UILabel()
    public var error: String? {
        didSet {
            guard let errorMessage = error else {
                self.backgroundColor = originalColor
                errorLabel.removeFromSuperview()
                return
            }
            if errorMessage.isEmpty == false && errorLabel.superview == nil {
                addSubview(errorLabel)
                errorLabel.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 18)
                errorLabel.textAlignment = .Right
                self.originalColor = backgroundColor ?? .blackColor()
                self.backgroundColor = .redColor()
                errorLabel.textColor = self.backgroundColor
                errorLabel.font = errorLabel.font.fontWithSize(10)
                setErrorMessageWithAnimation(errorMessage)
            }
            else if errorMessage.isEmpty == false {
                setErrorMessageWithAnimation(errorMessage)
            }
            else {
                self.backgroundColor = originalColor
                errorLabel.removeFromSuperview()
            }
        }
    }

    private func setErrorMessageWithAnimation(message: String) {
        if self.errorLabel.trimmedText == message {
            return
        }
        let fadeTransition = CATransition()
        fadeTransition.duration = 0.2
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.errorLabel.text = message
            self.errorLabel.layer.addAnimation(fadeTransition, forKey: kCATransition)
        }
        errorLabel.text = ""
        errorLabel.layer.addAnimation(fadeTransition, forKey: kCATransition)
        CATransaction.commit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        errorLabel.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 18)
    }
    
}


// UIViewController extension

public extension UIViewController {

    public func backToRootViewController(animated: Bool = true) {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewControllerAnimated(true)
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    public func smoothlyDeselectRows(tableView tableView: UITableView?) {
        // Get the initially selected index paths, if any
        let selectedIndexPaths = tableView?.indexPathsForSelectedRows ?? []

        // Grab the transition coordinator responsible for the current transition
        if let coordinator = transitionCoordinator() {
            // Animate alongside the master view controller's view
            coordinator.animateAlongsideTransitionInView(parentViewController?.view, animation: { context in
                // Deselect the cells, with animations enabled if this is an animated transition
                selectedIndexPaths.forEach {
                    tableView?.deselectRowAtIndexPath($0, animated: context.isAnimated())
                }
                }, completion: { context in
                    // If the transition was cancel, reselect the rows that were selected before,
                    // so they are still selected the next time the same animation is triggered
                    if context.isCancelled() {
                        selectedIndexPaths.forEach {
                            tableView?.selectRowAtIndexPath($0, animated: false, scrollPosition: .None)
                        }
                    }
            })
        }
        else { // If this isn't a transition coordinator, just deselect the rows without animating
            selectedIndexPaths.forEach {
                tableView?.deselectRowAtIndexPath($0, animated: false)
            }
        }
    }

}


// MARK: CGSize compare operators

public func <(left: CGSize, right: CGSize) -> Bool {
    return left.width + left.height < right.width + right.height
}

public func >(left: CGSize, right: CGSize) -> Bool {
    return left.width + left.height > right.width + right.height
}

public func <=(left: CGSize, right: CGSize) -> Bool {
    return left.width + left.height <= right.width + right.height
}

public func >=(left: CGSize, right: CGSize) -> Bool {
    return left.width + left.height >= right.width + right.height
}

public func ==(left: CGSize, right: CGSize) -> Bool {
    return left.width + left.height == right.width + right.height
}


// MARK: Custom operator `==?` to compare AnyObjects

infix operator ==? { associativity none precedence 160 }
public func ==?(lhs: AnyObject?, rhs: AnyObject?) -> Bool {
    if let a = lhs as? Int, b = rhs as? Int {
        return a == b
    }
    else if let a = lhs as? Float, b = rhs as? Float {
        return a == b
    }
    else if let a = lhs as? Double, b = rhs as? Double {
        return a == b
    }
    else if let a = lhs as? String, b = rhs as? String {
        return a == b
    }
    else if let a = lhs as? Bool, b = rhs as? Bool {
        return a == b
    }
    return false
}


// MARK: NSURLError extension

extension NSURLError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .Cancelled:
            return "Cancelled"
        case .BadURL:
            return "Bad URL"
        case .TimedOut:
            return "Timed out"
        case .UnsupportedURL:
            return "Unsupported URL"
        case .CannotFindHost:
            return "Cannot find host"
        case .CannotConnectToHost:
            return "Cannot connect to host"
        case .NetworkConnectionLost:
            return "Network connection lost"
        case .DNSLookupFailed:
            return "DNS lookup failed"
        case .HTTPTooManyRedirects:
            return "HTTP too many redirects"
        case .ResourceUnavailable:
            return "Resource unavailable"
        case .NotConnectedToInternet:
            return "No active internet connection"
        case .RedirectToNonExistentLocation:
            return "Redirect to non existent location"
        case .BadServerResponse:
            return "Bad server response"
        case .UserCancelledAuthentication:
            return "User cancelled authentication"
        case .UserAuthenticationRequired:
            return "User authentication required"
        case .ZeroByteResource:
            return "Zero byte resource"
        case .CannotDecodeRawData:
            return "Cannot decode raw data"
        case .CannotDecodeContentData:
            return "Cannot decode content data"
        case .CannotParseResponse:
            return "Cannot parse response"
        case .FileDoesNotExist:
            return "File does not exist"
        case .FileIsDirectory:
            return "File is directory"
        case .NoPermissionsToReadFile:
            return "No permissions to read file"
        case .SecureConnectionFailed:
            return "Secure connection failed"
        case .ServerCertificateHasBadDate:
            return "Server certificate has bad date"
        case .ServerCertificateUntrusted:
            return "Server certificate untrusted"
        case .ServerCertificateHasUnknownRoot:
            return "Server certificate has unknown root"
        case .ServerCertificateNotYetValid:
            return "Server certificate not yet valid"
        case .ClientCertificateRejected:
            return "Client certificate rejected"
        case .ClientCertificateRequired:
            return "Client certificate required"
        case .CannotLoadFromNetwork:
            return "Cannot load from network"
        case CannotCreateFile:
            return "Cannot create file"
        case CannotOpenFile:
            return "Cannot open file"
        case CannotCloseFile:
            return "Cannot close file"
        case CannotWriteToFile:
            return "Cannot write to file"
        case CannotRemoveFile:
            return "Cannot remove file"
        case CannotMoveFile:
            return "Cannot move file"
        case .DownloadDecodingFailedMidStream:
            return "Download decoding failed mid stream"
        case .DownloadDecodingFailedToComplete:
            return "Download decoding failed to complete"
        case .InternationalRoamingOff:
            return "International roaming off"
        case .CallIsActive:
            return "Call is active"
        case .DataNotAllowed:
            return "Data not allowed"
        case .RequestBodyStreamExhausted:
            return "Request body stream exhausted"
        case .BackgroundSessionRequiresSharedContainer:
            return "Background session requires shared container"
        case .BackgroundSessionInUseByAnotherProcess:
            return "Background session in use by another process"
        case .BackgroundSessionWasDisconnected:
            return "Background session was disconnected"
        }
    }

}


// MARK: UIGestureRecognizerState extension

extension UIGestureRecognizerState: CustomStringConvertible {

    public var description: String {
        switch self {
        case .Began:
            return "Began"
        case .Cancelled:
            return "Cancelled"
        case .Changed:
            return "Changed"
        case .Ended:
            return "Ended"
        case .Failed:
            return "Failed"
        case .Possible:
            return "Possible"
        }
    }

}
