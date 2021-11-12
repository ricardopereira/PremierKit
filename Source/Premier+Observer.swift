//
//  Premier+Observer.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 12/11/2021.
//  Copyright © 2021 Ricardo Pereira. All rights reserved.
//

import Foundation

public protocol StateChangesObservable: AnyObject {
    associatedtype StateChangeEventType
    var stateChangesObserverToken: StateChangesObserverToken<StateChangeEventType>? { get set }
    func observeStateChanges(block: @escaping (StateChangeEventType) -> Void) -> StateChangesObserverToken<StateChangeEventType>
    func emitStateChangeEvent(_ event: StateChangeEventType)
}

public class StateChangesObserverToken<Event> {

    private var block: ((Event) -> Void)?

    public init(block: @escaping (Event) -> Void) {
        self.block = block
    }

    deinit {
        invalidate()
    }

    public func invoke(_ state: Event) {
        block?(state)
    }

    public func invalidate() {
        self.block = nil
    }

}

public extension StateChangesObservable {

    func observeStateChanges(block: @escaping (StateChangeEventType) -> Void) -> StateChangesObserverToken<StateChangeEventType> {
        let blockToken = StateChangesObserverToken(block: block)
        stateChangesObserverToken = blockToken
        return blockToken
    }

    func emitStateChangeEvent(_ event: StateChangeEventType) {
        stateChangesObserverToken?.invoke(event)
    }

}
