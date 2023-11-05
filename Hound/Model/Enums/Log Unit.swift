//
//  Log Unit.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/2/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

// TODO NOW add communication of measurementSystem from client to server and back so syncs
// TODO NOW add selector in appearance for measurement system
// TODO NOW if trying to display a measurement unit that a user doesn't allow, convert to a unit they do allow

enum LogUnit: String, CaseIterable {
    // Imperial
    case oz = "oz"
    case lb = "lb"
    
    case flOz = "fl oz"
    case cup = "cup"
    
    case mi = "mi"
    
    // Metric
    case mg = "mg"
    case g = "g"
    case kg = "kg"
    
    case ml = "ml"
    case l = "l"

    case km = "km"
    
    // Both
    
    case treat = "treat"
    
    case tsp = "tsp"
    case tbsp = "tbsp"
    case pill = "pill"
    
    case hour = "hour"
    case minute = "minute"
    
    /// For a given logAction, returns the valid LogUnits that could be possible. If there aren't any that make sense, return nil
    static func logUnits(forLogAction logAction: LogAction) -> [LogUnit] {
        // Based on the user's measurement system, disallows them from using certains units and removes them from the array
        func removeNonConformingUnits(forLogUnits: [LogUnit]) -> [LogUnit] {
            var logUnits = forLogUnits
            
            logUnits.removeAll { logUnit in
                switch UserConfiguration.measurementSystem {
                case .imperial:
                    return logUnit == .mg || logUnit == .g
                    || logUnit == .kg || logUnit == .ml
                    || logUnit == .l || logUnit == .km
                case .metric:
                    return logUnit == .oz || logUnit == .lb
                    || logUnit == .flOz || logUnit == .cup
                    || logUnit == .mi
                case .both:
                    return false
                }
            }
            
            return logUnits
        }
        
        switch logAction {
        case .feed:
            return removeNonConformingUnits(forLogUnits: [.g, .kg, .oz, .lb, .cup])
        case .water:
            return removeNonConformingUnits(forLogUnits: [.ml, .l, .flOz, .cup])
        case .treat:
            return removeNonConformingUnits(forLogUnits: [.treat])
        case .pee, .poo, .both, .neither, .accident, .brush, .bathe, .doctor:
            return removeNonConformingUnits(forLogUnits: [])
        case .walk:
            return removeNonConformingUnits(forLogUnits: [.km, .mi, .hour, .minute])
        case .medicine:
            return removeNonConformingUnits(forLogUnits: [.mg, .ml, .tsp, .tbsp, .pill])
        case .weight:
            return removeNonConformingUnits(forLogUnits: [.g, .kg, .oz, .lb])
        case .wakeup, .sleep, .crate, .trainingSession:
            return removeNonConformingUnits(forLogUnits: [.hour, .minute])
        case .custom:
            // assuming all units are possible for custom log action
            return removeNonConformingUnits(forLogUnits: LogUnit.allCases)
        }
    }
    
    /// Produces a logNumberOfLogUnits that is more readable to the user. We accomplish this by rounding the double to two decimal places. Additionally, the decimal separator is varied based on locale (e.g. period in U.S.)
    static func readableLogNumberOfLogUnits(forLogNumberOfLogUnits logNumberOfLogUnits: Double?) -> String? {
        guard let logNumberOfLogUnits = logNumberOfLogUnits else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: logNumberOfLogUnits as NSNumber)
    }
    
    static func logNumberOfLogUnitsFromReadable(forReadableLogNumberOfLogUnits readableLogNumberOfLogUnits: String?) -> Double? {
        guard let readableLogNumberOfLogUnits = readableLogNumberOfLogUnits else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.number(from: readableLogNumberOfLogUnits)?.doubleValue
    }
    
    /// Produces a logUnit that is more readable to the user. We accomplish this by changing the plurality of a log unit if needed : "cup" -> "cups" (changed needed if numberOfUnits != 1); "g" -> "g" (no change needed ever).
    static func readableLogUnit(forLogUnit logUnit: LogUnit?, forLogNumberOfLogUnits logNumberOfLogUnits: Double?) -> String? {
        guard let logUnit = logUnit, let logNumberOfLogUnits = logNumberOfLogUnits else {
            return nil
        }
        
        func isApproximatelyOne(_ value: Double, epsilon: Double = 0.0001) -> Bool {
            return abs(value - 1.0) < epsilon
        }
        
        switch logUnit {
        case .oz, .flOz, .mi, .mg, .g, .kg, .ml, .l, .km, .tsp, .tbsp:
            return logUnit.rawValue
        case .lb, .cup, .treat, .pill, .hour, .minute:
            return isApproximatelyOne(logNumberOfLogUnits) ? logUnit.rawValue : logUnit.rawValue.appending("s")
        }
    }
    
    /// Produces a logUnit and logNumberOfLogUnits that is more readable to the user. For example: .cup, 1.5 -> "1.5 cups"; .g, 1.0 -> "1g"
    static func readableLogUnitWithLogNumberOfLogUnits(forLogUnit logUnit: LogUnit?, forLogNumberOfLogUnits logNumberOfLogUnits: Double?) -> String? {
        guard let logUnit = logUnit, let logNumberOfLogUnits = logNumberOfLogUnits else {
            return nil
        }
        
        // Take our raw values and convert them to something more readable
        let readableLogUnit = LogUnit.readableLogUnit(forLogUnit: logUnit, forLogNumberOfLogUnits: logNumberOfLogUnits) ?? ""
        let readableLogNumberOfLogUnits = LogUnit.readableLogNumberOfLogUnits(forLogNumberOfLogUnits: logNumberOfLogUnits) ?? ""
        
        // Depending on the unit, we optionally add a space in-between. Example: 1.5 cups, 1.5g
        switch logUnit {
        case .oz, .lb, .flOz, .cup, .mi, .ml, .l, .km, .treat, .tsp, .tbsp, .pill, .hour, .minute:
            return "\(readableLogNumberOfLogUnits) \(readableLogUnit)"
        case .mg, .g, .kg:
            return "\(readableLogNumberOfLogUnits)\(readableLogUnit)"
        }
    }
}
