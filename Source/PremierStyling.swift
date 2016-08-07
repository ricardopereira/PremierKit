//
//  PremierStyling.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 07/08/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit

public protocol UIButtonStyle {
    var tintColor: UIColor { get }
    var highlightedColor: UIColor { get }
    var disabledColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var borderWidth: CGFloat { get }
    var borderColor: UIColor { get }
}

public extension UIButtonStyle {
    var tintColor: UIColor {
        return .whiteColor()
    }
    var highlightedColor: UIColor {
        return .redColor()
    }
    var disabledColor: UIColor {
        return .grayColor()
    }
    var backgroundColor: UIColor {
        return .clearColor()
    }
    var borderWidth: CGFloat {
        return 0
    }
    var borderColor: UIColor {
        return .clearColor()
    }
}

public struct ButtonBaseStyle: UIButtonStyle {}

public enum ButtonStyle: RawRepresentable {
    case Base
    case Light(borderWidth: CGFloat)

    public init?(rawValue: UIButtonStyle) {
        self = Base
    }

    public var rawValue: UIButtonStyle {
        switch self {
        case Base:
            return ButtonBaseStyle()
        case Light(_):
            return ButtonBaseStyle() //?!
        }
    }
}

public extension UIButton {

    public func updateAppearance(style: ButtonStyle) {
        let styler = style.rawValue
        tintColor = styler.tintColor
        backgroundColor = styler.backgroundColor
        layer.borderWidth = styler.borderWidth
        layer.borderColor = styler.borderColor.CGColor
        setTitleColor(styler.tintColor, forState: .Normal)
        setTitleColor(styler.disabledColor, forState: .Disabled)
    }

}
