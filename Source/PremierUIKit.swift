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
    public func getFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let result = subview.getFirstResponder() {
                return result
            }
        }
        return nil
    }

    /// Add a mask by rounding corners
    public func setCustomCornerRadius(_ cornerRadius: CGFloat, corners: UIRectCorner) {
        layer.mask = { layer in
            let path = UIBezierPath(roundedRect:self.bounds, byRoundingCorners:corners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
            layer.path = path.cgPath
            return layer
        }(CAShapeLayer())
    }

    /// TODO
    public func activateConstraints(_ view: UIView) {
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo: view.topAnchor),
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        } else {
            // Fallback on earlier versions
        }
    }

}

public extension UIWindow {

    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    public static func getVisibleViewControllerFrom(_ viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(navigationController.visibleViewController)
        } else if let tabBarController = viewController as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tabBarController.selectedViewController)
        } else {
            if let presentedViewController = viewController?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(presentedViewController)
            } else {
                return viewController
            }
        }
    }

}

public extension UIFont {
    
    /// Size of text
    public func sizeOfString(_ string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: self], context: nil).size
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

    public func scrollToBottom(_ animated: Bool = false) {
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
    func presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func showError(_ message: String, handler: ((UIAlertAction) -> Void)?)
}

public extension ViewControllerPresentErrors {

    public func showError(_ message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: handler)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

}


// MARK: ViewControllerPresentDialogs

public protocol ViewControllerPresenter: class {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)?)
}

public protocol ViewControllerPresentDialogs: ViewControllerPresenter {
    func showConfimationDialog(_ title: String?, message: String?, acceptButtonTitle: String?, acceptButtonStyle: UIAlertActionStyle?, completionAccepted: @escaping () -> Void)
    func showMessage(_ title: String, message: String, handler: ((UIAlertAction) -> Void)?)
}

public extension ViewControllerPresentDialogs {

    public func showConfimationDialog(_ title: String?, message: String?, acceptButtonTitle: String? = nil, acceptButtonStyle: UIAlertActionStyle? = nil, completionAccepted: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: acceptButtonTitle ?? "OK", style: acceptButtonStyle ?? .default) { action in
            completionAccepted()
        }
        alertController.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    public func showMessage(_ title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}


// MARK: ViewControllerPresentKeyboard

public protocol ViewControllerPresentKeyboard {
    func hideKeyboard()
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

public extension ViewControllerPresentKeyboard where Self: UIViewController {

    public func hideKeyboard() {
        self.view.endEditing(true)
    }

}


// MARK: ViewControllerFieldValidator

public protocol ViewControllerFieldValidator {
    @discardableResult func verifyContent() -> Bool
    func validateContent()
}

public extension ViewControllerFieldValidator {

    public func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        verifyContent()
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
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
        // FIXME: should be recursive!
        containerView.subviews.flatMap{ $0 as? UITextField }.forEach { field in
            field.delegate = self
        }
    }

}

public extension UIScrollView {

    fileprivate func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        if contentInset.bottom == 0 && adjustmentHeight < 0 {
            return
        }
        contentInset.bottom += adjustmentHeight
        scrollIndicatorInsets.bottom += adjustmentHeight
    }

    internal func keyboardWillShow(_ sender: Notification) {
        adjustInsetForKeyboardShow(true, notification: sender)
    }

    internal func keyboardWillHide(_ sender: Notification) {
        adjustInsetForKeyboardShow(false, notification: sender)
    }

    internal func keyboardWillChangeFrame(_ sender: Notification) {
        contentInset.bottom = 0
        scrollIndicatorInsets.bottom = 0
    }

    public func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillChangeFrame(_:)),
            name: NSNotification.Name.UIKeyboardWillChangeFrame,
            object: nil
        )
    }

}


// MARK: ViewControllerPresentPicker

public protocol ViewControllerPresentPicker: ViewControllerPresenter {
    func showPicker<T: CustomStringConvertible>(_ list: [T], completion: ((Int?) -> Void))
}

open class PickerViewController<T: CustomStringConvertible>: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let list: [T]

    open var selectedRow: Int {
        return pickerView.selectedRow(inComponent: 0)
    }

    fileprivate let titleLabel = UILabel()
    fileprivate let pickerView = UIPickerView()
    // TODO: missing Done button
    fileprivate let buttonCancel = UIButton(type: .system)
    fileprivate var initialConstraint: NSLayoutConstraint?

    @available(iOS, unavailable)
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext

        let attributedString = NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)])
        buttonCancel.setAttributedTitle(attributedString, for: UIControlState())
        buttonCancel.layer.masksToBounds = true
        buttonCancel.layer.cornerRadius = 14.0
        buttonCancel.backgroundColor = .white

        if #available(iOS 9.0, *) {
            initialConstraint = buttonCancel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        } else {
            initialConstraint = NSLayoutConstraint(item: buttonCancel, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10)
        }
        buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonCancel)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                buttonCancel.heightAnchor.constraint(equalToConstant: 56),
                buttonCancel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                buttonCancel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
                self.initialConstraint!,
            ])
        } else {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: buttonCancel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 56),
                NSLayoutConstraint(item: buttonCancel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 10),
                NSLayoutConstraint(item: buttonCancel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -10),
                self.initialConstraint!,
            ])
        }
        buttonCancel.addTarget(self, action: #selector(didTouchCancel), for: .touchUpInside)

        pickerView.layer.masksToBounds = true
        pickerView.layer.cornerRadius = 14.0
        pickerView.backgroundColor = .white
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                pickerView.heightAnchor.constraint(equalToConstant: 180),
                pickerView.leadingAnchor.constraint(equalTo: buttonCancel.leadingAnchor),
                pickerView.trailingAnchor.constraint(equalTo: buttonCancel.trailingAnchor),
                pickerView.bottomAnchor.constraint(equalTo: buttonCancel.topAnchor, constant: -8),
            ])
        } else {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: pickerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 180),
                NSLayoutConstraint(item: pickerView, attribute: .leading, relatedBy: .equal, toItem: buttonCancel, attribute: .leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: pickerView, attribute: .trailing, relatedBy: .equal, toItem: buttonCancel, attribute: .trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: pickerView, attribute: .bottom, relatedBy: .equal, toItem: buttonCancel, attribute: .top, multiplier: 1.0, constant: -8),
            ])
        }

        titleLabel.isHidden = true
        titleLabel.text = "Test"
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
        titleLabel.backgroundColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                titleLabel.heightAnchor.constraint(equalToConstant: 56),
                titleLabel.leadingAnchor.constraint(equalTo: pickerView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: pickerView.trailingAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: pickerView.topAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 56),
                NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: pickerView, attribute: .leading, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: pickerView, attribute: .trailing, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: pickerView, attribute: .top, multiplier: 1.0, constant: 0),
            ])
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialConstraint?.constant = 300
        pickerView.layoutIfNeeded()
        buttonCancel.layoutIfNeeded()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
            self.initialConstraint?.constant = -10
            self.pickerView.layoutIfNeeded()
            self.buttonCancel.layoutIfNeeded()
            }, completion: nil)
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss(animated: true, completion: nil)
    }

    internal func didTouchCancel(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, animations: {
            self.initialConstraint?.constant = 300
            self.pickerView.layoutIfNeeded()
            self.buttonCancel.layoutIfNeeded()
            }, completion: { _ in
                self.dismiss(animated: true, completion: nil)
        })
    }

    // Delegate

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row].description
    }

    // Datasource

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }

}

public extension ViewControllerPresentDialogs {

    public func showPicker<T: CustomStringConvertible>(_ list: [T], completion: @escaping ((Int?) -> Void)) {
        let pickerViewController = PickerViewController(list: list)
        present(pickerViewController, animated: true, completion: {
            completion(pickerViewController.selectedRow)
        })
    }

}


// MARK: UIFieldSeparator

open class UIFieldSeparator: UIView {

    fileprivate var originalColor: UIColor = .black

    fileprivate lazy var errorLabel = UILabel()
    open var error: String? {
        didSet {
            guard let errorMessage = error else {
                self.backgroundColor = originalColor
                errorLabel.removeFromSuperview()
                return
            }
            if errorMessage.isEmpty == false && errorLabel.superview == nil {
                addSubview(errorLabel)
                errorLabel.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 18)
                errorLabel.textAlignment = .right
                self.originalColor = backgroundColor ?? .black
                self.backgroundColor = .red
                errorLabel.textColor = self.backgroundColor
                errorLabel.font = errorLabel.font.withSize(10)
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

    fileprivate func setErrorMessageWithAnimation(_ message: String) {
        if self.errorLabel.trimmedText == message {
            return
        }
        let fadeTransition = CATransition()
        fadeTransition.duration = 0.2
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.errorLabel.text = message
            self.errorLabel.layer.add(fadeTransition, forKey: kCATransition)
        }
        errorLabel.text = ""
        errorLabel.layer.add(fadeTransition, forKey: kCATransition)
        CATransaction.commit()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        errorLabel.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 18)
    }
    
}


// UIViewController extension

public extension UIViewController {

    public func backToRootViewController(_ animated: Bool = true) {
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }

    public func smoothlyDeselectRows(tableView: UITableView?) {
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
infix operator ==? : ComparisonPrecedence
public func ==?(lhs: AnyObject?, rhs: AnyObject?) -> Bool {
    if let a = lhs as? Int, let b = rhs as? Int {
        return a == b
    }
    else if let a = lhs as? Float, let b = rhs as? Float {
        return a == b
    }
    else if let a = lhs as? Double, let b = rhs as? Double {
        return a == b
    }
    else if let a = lhs as? String, let b = rhs as? String {
        return a == b
    }
    else if let a = lhs as? Bool, let b = rhs as? Bool {
        return a == b
    }
    return false
}


// MARK: NSURLError extension

extension URLError.Code: CustomStringConvertible {

    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .cancelled:
            return "Cancelled"
        case .badURL:
            return "Bad URL"
        case .timedOut:
            return "Timed out"
        case .unsupportedURL:
            return "Unsupported URL"
        case .cannotFindHost:
            return "Cannot find host"
        case .cannotConnectToHost:
            return "Cannot connect to host"
        case .networkConnectionLost:
            return "Network connection lost"
        case .dnsLookupFailed:
            return "DNS lookup failed"
        case .httpTooManyRedirects:
            return "HTTP too many redirects"
        case .resourceUnavailable:
            return "Resource unavailable"
        case .notConnectedToInternet:
            return "No active internet connection"
        case .redirectToNonExistentLocation:
            return "Redirect to non existent location"
        case .badServerResponse:
            return "Bad server response"
        case .userCancelledAuthentication:
            return "User cancelled authentication"
        case .userAuthenticationRequired:
            return "User authentication required"
        case .zeroByteResource:
            return "Zero byte resource"
        case .cannotDecodeRawData:
            return "Cannot decode raw data"
        case .cannotDecodeContentData:
            return "Cannot decode content data"
        case .cannotParseResponse:
            return "Cannot parse response"
        case .appTransportSecurityRequiresSecureConnection:
            return "App transport security requires secure connection"
        case .fileDoesNotExist:
            return "File does not exist"
        case .fileIsDirectory:
            return "File is directory"
        case .noPermissionsToReadFile:
            return "No permissions to read file"
        case .dataLengthExceedsMaximum:
            return "Data length exceeds maximum"
        case .secureConnectionFailed:
            return "Secure connection failed"
        case .serverCertificateHasBadDate:
            return "Server certificate has bad date"
        case .serverCertificateUntrusted:
            return "Server certificate untrusted"
        case .serverCertificateHasUnknownRoot:
            return "Server certificate has unknown root"
        case .serverCertificateNotYetValid:
            return "Server certificate not yet valid"
        case .clientCertificateRejected:
            return "Client certificate rejected"
        case .clientCertificateRequired:
            return "Client certificate required"
        case .cannotLoadFromNetwork:
            return "Cannot load from network"
        case .cannotCreateFile:
            return "Cannot create file"
        case .cannotOpenFile:
            return "Cannot open file"
        case .cannotCloseFile:
            return "Cannot close file"
        case .cannotWriteToFile:
            return "Cannot write to file"
        case .cannotRemoveFile:
            return "Cannot remove file"
        case .cannotMoveFile:
            return "Cannot move file"
        case .downloadDecodingFailedMidStream:
            return "Download decoding failed mid stream"
        case .downloadDecodingFailedToComplete:
            return "Download decoding failed to complete"
        case .internationalRoamingOff:
            return "International roaming off"
        case .callIsActive:
            return "Call is active"
        case .dataNotAllowed:
            return "Data not allowed"
        case .requestBodyStreamExhausted:
            return "Request body stream exhausted"
        case .backgroundSessionRequiresSharedContainer:
            return "Background session requires shared container"
        case .backgroundSessionInUseByAnotherProcess:
            return "Background session in use by another process"
        case .backgroundSessionWasDisconnected:
            return "Background session was disconnected"
        default:
            return "Unknown"
        }
    }

}


// MARK: UIGestureRecognizerState extension

extension UIGestureRecognizerState: CustomStringConvertible {

    public var description: String {
        switch self {
        case .began:
            return "Began"
        case .cancelled:
            return "Cancelled"
        case .changed:
            return "Changed"
        case .ended:
            return "Ended"
        case .failed:
            return "Failed"
        case .possible:
            return "Possible"
        }
    }

}
