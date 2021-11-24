//
//  Premier+KeyValueStore.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 24/11/2021.
//  Copyright © 2021 Ricardo Pereira. All rights reserved.
//

import Foundation

public protocol KeyValueStore {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)

    func string(forKey defaultName: String) -> String?
    func array(forKey defaultName: String) -> [Any]?
    func dictionary(forKey defaultName: String) -> [String : Any]?
    func data(forKey defaultName: String) -> Data?
    func stringArray(forKey defaultName: String) -> [String]?
    func integer(forKey defaultName: String) -> Int
    func float(forKey defaultName: String) -> Float
    func double(forKey defaultName: String) -> Double
    func bool(forKey defaultName: String) -> Bool
    func url(forKey defaultName: String) -> URL?

    func set(_ value: Int, forKey defaultName: String)
    func set(_ value: Float, forKey defaultName: String)
    func set(_ value: Double, forKey defaultName: String)
    func set(_ value: Bool, forKey defaultName: String)
    func set(_ url: URL?, forKey defaultName: String)
}

@propertyWrapper
public struct StorePropertyValue<T> {
    let key: String
    let defaultValue: T
    let store: KeyValueStore

    public init(_ key: String, store: KeyValueStore, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }

    public var wrappedValue: T {
        get {
            return store.object(forKey: key) as? T ?? defaultValue
        }
        set {
            store.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct StorePropertyOptionalValue<T> {
    let key: String
    let defaultValue: T?
    let store: KeyValueStore

    public init(_ key: String, store: KeyValueStore, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }

    public var wrappedValue: T? {
        get {
            return store.object(forKey: key) as? T ?? defaultValue
        }
        set {
            store.set(newValue, forKey: key)
        }
    }
}
