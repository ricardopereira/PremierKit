//
//  PremierLog.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 29/12/15.
//  Copyright © 2015 Ricardo Pereira. All rights reserved.
//

import Foundation
#if FABRIC
import Crashlytics
#endif

public enum LogLevel: Int {
    case NONE
    case ERROR
    case WARN
    case INFO
    case DEBUG
    case VERBOSE
}

public struct LogOptions {
    static var level = LogLevel.NONE
}

public func logMessage(message: String, level: LogLevel = .DEBUG, customAttributes: [String:AnyObject]? = nil, filename: NSString = #file, line: Int = #line, function: String = #function) {
    assert(level != .NONE)
    if level.rawValue <= LogOptions.level.rawValue {
        NSLog("\(filename.lastPathComponent):\(line) \(function) \(level) \(message) [\(customAttributes)]")
    }
    // Events
    #if FABRIC && !((arch(i386) || arch(x86_64)) && os(iOS))
        // On Device where DEBUG,VERBOSE <= INFO
        if level.rawValue <= LogLevel.INFO.rawValue {
            let attributes: [String:AnyObject] = ["LogLevel":"\(level)", "File":filename.lastPathComponent, "Line":line, "Function":function]
            Answers.logCustomEventWithName("\(message)", customAttributes: attributes + customAttributes)
        }
    #endif
}
