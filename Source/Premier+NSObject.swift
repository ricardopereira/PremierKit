//
//  PremierFoundation.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 30/07/2015.
//  Copyright (c) 2015 Ricardo Pereira. All rights reserved.
//

import Foundation

extension NSObject {

    public var toBase64: String {
        return (try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0)).base64EncodedString()) ?? ""
    }

}
