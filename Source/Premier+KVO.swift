//
//  Premier+KVO.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 08/10/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import Foundation

/**
 Probably, this will be replaced with the Swift standard KVO observation object which has been unstable in older versions.

 Example:

 #if swift(>=5.1)
 layerBoundsObserver = self.observe(\.layer.bounds, options: [.old, .new]) { [weak self] sender, change in
     guard change.oldValue?.size.width != change.newValue?.size.width else {
         return
     }
     self?.repositionViews()
 }
 #else
 ... this solution
 #endif
 */
public class KeyValueObserverToken<Sender: NSObject, Value>: NSObject {

    public typealias Block = (_ sender: Sender, _ change: KeyValueObservedChange<Value>) -> Void

    private(set) var sender: Sender?
    public let keyPath: String
    public let options: NSKeyValueObservingOptions
    private let block: Block

    public init(_ object: Sender, keyPath: String, options: NSKeyValueObservingOptions, block: @escaping Block) {
        self.sender = object
        self.keyPath = keyPath
        self.options = options
        self.block = block
        super.init()
        object.addObserver(self, forKeyPath: keyPath, options: options, context: nil)
    }

    deinit {
        invalidate()
    }

    /**
     Remove observer. Should always be called or a leak will occur because this is holding a strong reference to the sender.
     */
    public func invalidate() {
        if let object = sender {
            object.removeObserver(self, forKeyPath: keyPath, context: nil)
        }
        sender = nil
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.keyPath == keyPath {
            guard let sender = sender else {
                // Ignore since sender has been probably deallocated.
                return
            }

            guard let change = change else {
                assertionFailure("Expected change dictionary")
                return
            }

            // The change dictionary always contains an NSKeyValueChangeKindKey entry whose value is an NSNumber wrapping an NSKeyValueChange (use -[NSNumber unsignedIntegerValue]).
            guard let kindKey = change[NSKeyValueChangeKey.kindKey] as? NSNumber,
                let kind = NSKeyValueChange(rawValue: kindKey.uintValue) else {
                assertionFailure("Expected NSKeyValueChangeKindKey value")
                return
            }

            let newValue = change[.newKey] as? Value
            let oldValue = change[.oldKey] as? Value
            let indexes = change[.indexesKey] as? IndexSet
            let isPrior = change[.notificationIsPriorKey] as? Bool

            let safeChange = KeyValueObservedChange<Value>(
                kind: kind,
                newValue: newValue,
                oldValue: oldValue,
                indexes: indexes,
                isPrior: isPrior ?? false
            )

            block(sender, safeChange)
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}


/**
 Same as NSKeyValueObservedChange.
 */
public struct KeyValueObservedChange<Value> {

    public let kind: NSKeyValueChange

    public let newValue: Value?
    public let oldValue: Value?

    ///indexes will be nil unless the observed KeyPath refers to an ordered to-many property
    public let indexes: IndexSet?

    ///'isPrior' will be true if this change observation is being sent before the change happens, due to .prior being passed to `observe()`
    public let isPrior: Bool

}

extension NSKeyValueChange: CustomStringConvertible {

    public var description: String {
        switch self {
        case .insertion:
            return "Insertion"
        case .removal:
            return "Removal"
        case .replacement:
            return "Replacement"
        case .setting:
            return "Setting"
        @unknown default:
            fatalError("NSKeyValueChange missing case for description")
        }
    }

}

extension NSObjectProtocol where Self: NSObject {

    public func addObserver<Value>(for keyPath: KeyPath<Self, Value>, options: NSKeyValueObservingOptions, block: @escaping KeyValueObserverToken<Self, Value>.Block) -> KeyValueObserverToken<Self, Value> {
        let objcKeyPathString = NSExpression(forKeyPath: keyPath).keyPath
        return KeyValueObserverToken<Self, Value>(self, keyPath: objcKeyPathString, options: options, block: block)
    }

}
