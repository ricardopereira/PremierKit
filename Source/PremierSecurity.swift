//
//  PremierSecurity.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 07/08/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import Foundation

public class KeychainPassword {

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
        attributes[String(kSecAttrAccessible)] = String(kSecAttrAccessibleWhenUnlocked)
        attributes[String(kSecAttrService)] = bundleIdentifier
        attributes[String(kSecAttrAccount)] = account
        return attributes
    }

    public func setValue<T: AnyObject>(value: T) -> Bool {
        var attributes = genericPasswordAttributes()
        let archivedData = NSKeyedArchiver.archivedDataWithRootObject(value)
        attributes[String(kSecValueData)] = archivedData

        var statusCode = SecItemAdd(attributes, nil)
        if statusCode == errSecDuplicateItem {
            SecItemDelete(attributes)
            statusCode = SecItemAdd(attributes, nil)
        }
        if statusCode != errSecSuccess {
            return false
        }
        return true
    }

    public func removeValue() -> Bool {
        let attributes = genericPasswordAttributes()
        let statusCode = SecItemDelete(attributes)
        if statusCode != errSecSuccess {
            return false
        }
        return true
    }

    public func getValue<T>() -> T? {
        var attributes = genericPasswordAttributes()
        attributes[String(kSecReturnData)] = true
        attributes[String(kSecReturnAttributes)] = true

        var match: AnyObject?
        let statusCode = withUnsafeMutablePointer(&match) { pointer in
            SecItemCopyMatching(attributes, UnsafeMutablePointer(pointer))
        }
        if statusCode != errSecSuccess {
            return nil
        }
        guard let result = match as? [String : AnyObject] else {
            return nil
        }
        guard let valueData = result[String(kSecValueData)] as? NSData else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObjectWithData(valueData) as? T ?? nil
    }
    
}
