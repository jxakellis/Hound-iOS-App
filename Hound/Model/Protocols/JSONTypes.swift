//
//  CompatibleDataTypeForJSON.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

typealias JSONRequestBody = [String: JSONValue?]
typealias JSONResponseBody = [String: Any?]

enum JSONValue {
    case string(String?)
    case int(Int?)
    case double(Double?)
    case bool(Bool?)
    case array([JSONValue?])
    case object([String: JSONValue?])
    
    func toAny() -> Any? {
        switch self {
        case .string(let str): return str
        case .int(let int): return int
        case .double(let dbl): return dbl
        case .bool(let bool): return bool
        case .array(let arr):
            // For JSON, NSNull represents nil elements in arrays
            return arr.map { $0?.toAny() ?? NSNull() }
        case .object(let obj):
            // Remove any nil values if needed, or keep as NSNull
            var dict = [String: Any]()
            for (key, value) in obj {
                dict[key] = value?.toAny() ?? NSNull()
            }
            return dict
        }
    }
}

extension Dictionary where Key == String, Value == JSONValue? {
    func toAnyDictionary() -> [String: Any] {
        var out = [String: Any]()
        for (k, v) in self {
            if let val = v?.toAny() {
                out[k] = val
            }
            else {
                out[k] = NSNull() // or skip if you prefer to omit null keys
            }
        }
        return out
    }
}
