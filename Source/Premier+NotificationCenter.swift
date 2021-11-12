//
//  Premier+NotificationCenter.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 03/09/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import Foundation

public typealias EventEmitter = NotificationCenter

public class EventToken {

    private var token: NSObjectProtocol?
    private let emitter: EventEmitter

    public init(token: NSObjectProtocol, emitter: EventEmitter) {
        self.token = token
        self.emitter = emitter
    }

    deinit {
        invalidate()
    }

    public func invalidate() {
        if let token = token {
            emitter.removeObserver(token)
            self.token = nil
        }
    }

}

public protocol Event: RawRepresentable {
    func uniqueName() -> String
    func emit(emitter: EventEmitter)
    func emit<A>(with object: A, emitter: EventEmitter)
    func observe(emitter: EventEmitter, using block: @escaping () -> Void) -> EventToken
    func observe<A>(emitter: EventEmitter, using block: @escaping (A?) -> Void) -> EventToken
}

public extension Event where Self.RawValue == String {

    func uniqueName() -> String {
        let typeName = String(describing: Self.self)
        let uniqueName = "\(typeName).\(self.rawValue)"
        return uniqueName
    }

    func emit(emitter: EventEmitter = .default) {
        let event = Notification(name: Notification.Name(rawValue: self.uniqueName()), object: nil)
        emitter.post(event)
    }

    func emit<A>(with object: A, emitter: EventEmitter = .default) {
        let event = Notification(name: Notification.Name(rawValue: self.uniqueName()), object: object)
        emitter.post(event)
    }

    func observe(emitter: EventEmitter = .default, using block: @escaping () -> Void) -> EventToken {
        let token = emitter.addObserver(forName: Notification.Name(rawValue: self.uniqueName()), object: nil, queue: .main, using: { _ in
            block()
        })
        return EventToken(token: token, emitter: emitter)
    }

    func observe<A>(emitter: EventEmitter = .default, using block: @escaping (A?) -> Void) -> EventToken {
        let token = emitter.addObserver(forName: NSNotification.Name(rawValue: self.uniqueName()), object: nil, queue: .main, using: { [eventName = self.uniqueName()] notification in
            if notification.object == nil {
                block(nil)
            }
            else if let object = notification.object as? A {
                block(object)
            }
            else {
                fatalError("Event \"\(eventName)\" with object (\(String(describing: notification.object))) doesn't match the expected \(String(describing: A.self)) type")
            }
        })
        return EventToken(token: token, emitter: emitter)
    }

}
