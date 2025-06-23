//
//  NSCoderExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/22/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension NSCoder {
    func decodeOptionalInteger(forKey key: String) -> Int? {
        return containsValue(forKey: key) ? decodeInteger(forKey: key) : nil
    }
    
    func decodeOptionalBool(forKey key: String) -> Bool? {
        return containsValue(forKey: key) ? decodeBool(forKey: key) : nil
    }
    
    func decodeOptionalDouble(forKey key: String) -> Double? {
        return containsValue(forKey: key) ? decodeDouble(forKey: key) : nil
    }
    
    func decodeOptionalFloat(forKey key: String) -> Float? {
        return containsValue(forKey: key) ? decodeFloat(forKey: key) : nil
    }
    
    func decodeOptionalString(forKey key: String) -> String? {
        return decodeOptionalObject(forKey: key)
    }
    
    func decodeOptionalObject<T>(forKey key: String) -> T? {
        return containsValue(forKey: key) ? decodeObject(forKey: key) as? T : nil
    }
}
