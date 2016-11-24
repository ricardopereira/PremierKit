//
//  PremierTypes.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 19/05/16.
//  Copyright © 2016 Pearland. All rights reserved.
//

import Foundation

public struct NoError: ErrorType {
    public init() {}
}

public final class Box<T> {
    public let value: T

    public init(_ value: T) {
        self.value = value
    }
}

public enum Result<T, E: ErrorType> {
    case Success(T)
    case Failure(E)

    public init(value: T) {
        self = .Success(value)
    }

    public init(error: E) {
        self = .Failure(error)
    }

    public var success: T? {
        switch self {
        case .Success(let value):
            return value
        case .Failure(_):
            return nil
        }
    }

    public var failure: E? {
        if case .Failure(let error) = self {
            return error
        }
        else {
            return nil
        }
    }
}
