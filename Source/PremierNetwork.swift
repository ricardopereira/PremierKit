//
//  PremierNetwork.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 07/08/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit

public struct NetworkActivityManager {

    private static var activeActivities = [String:Int]()

    private init() {}

    public static func hasActivity(name: String) -> Bool {
        return (activeActivities[name] ?? 0) > 0
    }

    public static func addActivity(name: String = "unknown") {
        if activeActivities.count == 0 {
            #if os(iOS)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            #endif
        }
        activeActivities[name] = (activeActivities[name] ?? 0) + 1
    }

    public static func removeActivity(name: String = "unknown") {
        if activeActivities.count > 0 {
            activeActivities[name] = (activeActivities[name] ?? 0) - 1
            if !hasActivity(name) {
                activeActivities.removeValueForKey(name)
            }
            if activeActivities.count == 0 {
                #if os(iOS)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                #endif
            }
        }
    }
    
}
