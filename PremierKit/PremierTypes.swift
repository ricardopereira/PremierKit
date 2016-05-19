//
//  PremierTypes.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 19/05/16.
//  Copyright © 2016 Pearland. All rights reserved.
//

import Foundation

public final class Box<T> {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}

public enum Result<T, E: ErrorType> {
    case Success(T)
    case Failure(E)

    init(value: T) {
        self = .Success(value)
    }

    init(error: E) {
        self = .Failure(error)
    }
}
