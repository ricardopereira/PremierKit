//
//  Premier+UserDefaults.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 01/10/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let suiteName: String?

    public init(_ key: String, defaultValue: T, suiteName: String? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.suiteName = suiteName
    }

    private func userDefaults() -> UserDefaults {
        var userDefaults = UserDefaults.standard
        if let suiteName = suiteName, let suiteUserDefaults = UserDefaults(suiteName: suiteName) {
            userDefaults = suiteUserDefaults
        }
        return userDefaults
    }

    public var wrappedValue: T {
        get {
            return userDefaults().object(forKey: key) as? T ?? defaultValue
        }
        set {
            userDefaults().set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct OptionalUserDefault<T> {
    let key: String
    let defaultValue: T?
    let suiteName: String?

    public init(_ key: String, defaultValue: T? = nil, suiteName: String? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.suiteName = suiteName
    }

    private func userDefaults() -> UserDefaults {
        var userDefaults = UserDefaults.standard
        if let suiteName = suiteName, let suiteUserDefaults = UserDefaults(suiteName: suiteName) {
            userDefaults = suiteUserDefaults
        }
        return userDefaults
    }

    public var wrappedValue: T? {
        get {
            return userDefaults().object(forKey: key) as? T ?? defaultValue
        }
        set {
            userDefaults().set(newValue, forKey: key)
        }
    }
}

private struct TestUserDefault {

    @UserDefault(#function, defaultValue: "")
    static var a: String

    @UserDefault(#function, defaultValue: "", suiteName: "PremierKitGroup")
    static var b: String

    @OptionalUserDefault(#function)
    static var c: String?

    @OptionalUserDefault(#function, suiteName: "PremierKitGroup")
    static var d: String?

}
