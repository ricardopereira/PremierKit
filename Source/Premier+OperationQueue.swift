//
//  Premier+OperationQueue.swift
//  PremierKitTests
//
//  Created by Ricardo Pereira on 08/10/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import Foundation

/**
 An operation that manages the concurrent execution of one or more async blocks. Mostly like the BlockOperation but with the particularity to handle asynchronous work, i.e., a network request. The block has a complete input closure to be called when the work is done, i.e., then the network request has ended.
 */
public class AsyncBlockOperation: Operation {

    public let id: String?

    public typealias AsyncBlock = (_ operation: AsyncBlockOperation) -> Void

    private let lock = NSLock()
    private var _executing = false
    private var _finished = false
    private var _onCancel: (() -> Void)?

    private let asyncBlock: AsyncBlock

    #if swift(>=5.1)
    private var isCancelledObserver: NSKeyValueObservation?
    #else
    private var isCancelledObserver: KeyValueObserverToken?
    #endif

    @objc public init(id: String? = nil, block: @escaping AsyncBlock) {
        self.id = id
        self.asyncBlock = block
        super.init()

        #if swift(>=5.1)
        isCancelledObserver = self.observe(\.isCancelled, options: [.new]) { [weak self] _, change in
            if change.newValue ?? false {
                self?.onCancel?()
            }
        }
        #else
        isCancelledObserver = self.addObserver(\.isCancelled, options: [.new]) { [weak self] _, change in
            if change.newValue ?? false {
                self?.onCancel?()
            }
        }
        #endif
    }

    deinit {
        isCancelledObserver?.invalidate()
    }

    public override var isAsynchronous: Bool {
        return true
    }

    public override var isExecuting: Bool {
        get {
            lock.lock()
            let value = _executing
            lock.unlock()
            return value
        }
        set {
            if isExecuting != newValue {
                willChangeValue(forKey: "isExecuting")
                lock.lock()
                _executing = newValue
                lock.unlock()
                didChangeValue(forKey: "isExecuting")
            }
        }
    }

    public override var isFinished: Bool {
        get {
            lock.lock()
            let value = _finished
            lock.unlock()
            return value
        }
        set {
            if isFinished != newValue {
                willChangeValue(forKey: "isFinished")
                lock.lock()
                _finished = newValue
                lock.unlock()
                didChangeValue(forKey: "isFinished")
            }
        }
    }

    public var onCancel: (() -> Void)? {
        get {
            lock.lock()
            let value = _onCancel
            lock.unlock()
            return value
        }
        set {
            lock.lock()
            _onCancel = newValue
            lock.unlock()
        }
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let otherOperation = object as? AsyncBlockOperation else {
            return false
        }
        guard let otherId = otherOperation.id else {
            return false
        }
        guard let id = self.id else {
            return false
        }
        return id == otherId
    }

    override public var hash: Int {
        return id?.hash ?? 0
    }

    public override func start() {
        if isCancelled || isExecuting {
            finish()
            return
        }
        isExecuting = true
        asyncBlock(self)
    }

    public func finish() {
        onCancel = nil
        isExecuting = false
        isFinished = true
    }

}
