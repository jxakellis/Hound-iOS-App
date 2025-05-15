//
//  CompatibleDataTypeForJSON.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// A data type that can be transmitted to / understood by the Hound server through JSON. This means it has to be a standard, primative type which can be undestood (strings, booleans, numbers, nulls, etc.)
protocol CompatibleDataTypeForJSON {}

extension String: CompatibleDataTypeForJSON {}
extension Int: CompatibleDataTypeForJSON {}
/*
extension Int8: CompatibleDataTypeForJSON {}
extension Int16: CompatibleDataTypeForJSON {}
extension Int32: CompatibleDataTypeForJSON {}
extension Int64: CompatibleDataTypeForJSON {}
extension UInt: CompatibleDataTypeForJSON {}
extension UInt8: CompatibleDataTypeForJSON {}
extension UInt16: CompatibleDataTypeForJSON {}
extension UInt32: CompatibleDataTypeForJSON {}
extension UInt64: CompatibleDataTypeForJSON {}
 */
extension Float: CompatibleDataTypeForJSON {}
extension Double: CompatibleDataTypeForJSON {}
extension Bool: CompatibleDataTypeForJSON {}
// now arrays of JSON-compatible elements themselves become JSON-compatible
extension Array: CompatibleDataTypeForJSON where Element: CompatibleDataTypeForJSON {}
extension Dictionary: CompatibleDataTypeForJSON where Key == String, Value: CompatibleDataTypeForJSON {}
