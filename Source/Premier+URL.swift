//
//  Premier+URL.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 13/05/2019.
//  Copyright © 2019 Ricardo Pereira. All rights reserved.
//

import Foundation

extension URL {

    public init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }

}
