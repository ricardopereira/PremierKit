//
//  Premier+Data.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import Foundation

extension Data {

    public var utf8String: String {
        return String(data: self, encoding: .utf8) ?? ""
    }

}
