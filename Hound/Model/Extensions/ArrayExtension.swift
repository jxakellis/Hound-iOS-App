//
//  ArrayExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/18/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element: CustomStringConvertible {
    func joined(separator: String, endingSeparator: String) -> String {
        switch count {
        case 0: return ""
        case 1: return self[0].description
        case 2: return self.map { $0.description }.joined(separator: endingSeparator)
        default:
            let allButLast = self.dropLast().map { $0.description }.joined(separator: separator)
            return "\(allButLast)\(endingSeparator)\(self.last!.description)" // swiftlint:disable:this force_unwrapping
        }
    }
}
