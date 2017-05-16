//
//  PremierNetwork.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 07/08/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit

public struct NetworkActivityManager {

    fileprivate static var activeActivities = [String:Int]()

    fileprivate init() {}

    public static func hasActivity(_ name: String) -> Bool {
        return (activeActivities[name] ?? 0) > 0
    }

    public static func addActivity(_ name: String = "unknown") {
        if activeActivities.count == 0 {
            #if os(iOS)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            #endif
        }
        activeActivities[name] = (activeActivities[name] ?? 0) + 1
    }

    public static func removeActivity(_ name: String = "unknown") {
        if activeActivities.count > 0 {
            activeActivities[name] = (activeActivities[name] ?? 0) - 1
            if !hasActivity(name) {
                activeActivities.removeValue(forKey: name)
            }
            if activeActivities.count == 0 {
                #if os(iOS)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                #endif
            }
        }
    }
    
}
