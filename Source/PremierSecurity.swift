//
//  PremierSecurity.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 07/08/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import Foundation

open class KeychainPassword {

    let bundleIdentifier: String
    let account: String

    public init(_ account: String, bundleIdentifier: String) {
        self.account = account
        self.bundleIdentifier = bundleIdentifier
    }

    internal func genericPasswordAttributes() -> [String : AnyObject] {
        var attributes = [String : AnyObject]()
        attributes[String(kSecClass)] = kSecClassGenericPassword
        // Item data can only be accessed while the device is unlocked.
        attributes[String(kSecAttrAccessible)] = String(kSecAttrAccessibleWhenUnlocked) as NSString
        attributes[String(kSecAttrService)] = bundleIdentifier as AnyObject?
        attributes[String(kSecAttrAccount)] = account as AnyObject?
        return attributes
    }

    open func setValue<T: AnyObject>(_ value: T) -> Bool {
        var attributes = genericPasswordAttributes()
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: value)
        attributes[String(kSecValueData)] = archivedData as AnyObject?

        var statusCode = SecItemAdd(attributes as CFDictionary, nil)
        if statusCode == errSecDuplicateItem {
            SecItemDelete(attributes as CFDictionary)
            statusCode = SecItemAdd(attributes as CFDictionary, nil)
        }
        if statusCode != errSecSuccess {
            return false
        }
        return true
    }

    open func removeValue() -> Bool {
        let attributes = genericPasswordAttributes()
        let statusCode = SecItemDelete(attributes as CFDictionary)
        if statusCode != errSecSuccess {
            return false
        }
        return true
    }

    open func getValue<T>() -> T? {
        var attributes = genericPasswordAttributes()
        attributes[String(kSecReturnData)] = true as AnyObject?
        attributes[String(kSecReturnAttributes)] = true as AnyObject?

        var match: AnyObject?
        let statusCode = withUnsafeMutablePointer(to: &match) { pointer in
            SecItemCopyMatching(attributes as CFDictionary, UnsafeMutablePointer(pointer))
        }
        if statusCode != errSecSuccess {
            return nil
        }
        guard let result = match as? [String : AnyObject] else {
            return nil
        }
        guard let valueData = result[String(kSecValueData)] as? Data else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: valueData) as? T ?? nil
    }
    
}
