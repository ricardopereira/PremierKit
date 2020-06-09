//
//  PremierObfuscator.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 09/06/2020.
//  Copyright © 2020 Ricardo Pereira. All rights reserved.
//
//  Credit to https://gist.github.com/DejanEnspyra/80e259e3c9adf5e46632631b49cd1007
//

import Foundation

public class Obfuscator {

    // MARK: - Variables

    /// The salt used to obfuscate and reveal the string.
    private let salt: String

    // MARK: - Initialization

    public init(with salt: String) {
        self.salt = salt
    }


    // MARK: - Instance Methods

    /**
     This method obfuscates the string passed in using the salt
     that was used when the Obfuscator was initialized.

     - parameter string: the string to obfuscate

     - returns: the obfuscated string in a byte array
     */
    public func bytesByObfuscatingString(string: String) -> [UInt8] {
        let text = [UInt8](string.utf8)
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count

        var obfuscated = [UInt8]()

        for t in text.enumerated() {
            obfuscated.append(t.element ^ cipher[t.offset % length])
        }

        #if DEBUG
        print("\nObfuscator")
        print("Salt used: \(self.salt)")
        print("Swift Code:\n************")
        print("// Original \"\(string)\"")
        print("let key: [UInt8] = \(obfuscated)\n")
        #endif

        return obfuscated
    }

    /**
     This method reveals the original string from the obfuscated
     byte array passed in. The salt must be the same as the one
     used to encrypt it in the first place.

     - parameter key: the byte array to reveal

     - returns: the original string
     */
    public func reveal(key: [UInt8]) -> String {
        let cipher = [UInt8](self.salt.utf8)
        let length = cipher.count

        var decrypted = [UInt8]()

        for k in key.enumerated() {
            decrypted.append(k.element ^ cipher[k.offset % length])
        }

        return String(bytes: decrypted, encoding: .utf8)!
    }

}
