//
//  PremierTypes.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 19/05/16.
//  Copyright © 2016 Pearland. All rights reserved.
//

import Foundation

public struct NoError: Error {
    public init() {}
}

public final class Box<T> {
    public let value: T

    public init(_ value: T) {
        self.value = value
    }
}

public enum Result<T, E: Error> {
    case success(T)
    case failure(E)

    public init(value: T) {
        self = .success(value)
    }

    public init(error: E) {
        self = .failure(error)
    }

    public var success: T? {
        switch self {
        case .success(let value):
            return value
        case .failure(_):
            return nil
        }
    }

    public var failure: E? {
        if case .failure(let error) = self {
            return error
        }
        else {
            return nil
        }
    }
}
