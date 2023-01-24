//
//  Hash.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/12/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import CryptoKit
import Foundation

enum Hash {
    static func sha256Hash(forString string: String) -> String {
        let dataString = Data(string.utf8)
        let hashedString = SHA256.hash(data: dataString)
        // SHA256.digest -> "1f66dxxxxxxxxxxxxxxx"
        let hashedStringBackIntoString = hashedString.compactMap { String(format: "%02x", $0) }.joined()
        return hashedStringBackIntoString
    }
    
    static let defaultSHA256Hash: String = sha256Hash(forString: "-1")
}
