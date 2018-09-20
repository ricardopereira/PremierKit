//
//  Premier+URLResponse.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import Foundation

extension URLResponse {

    public var httpStatusCode: Int {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        else {
            return 0
        }
    }

}
