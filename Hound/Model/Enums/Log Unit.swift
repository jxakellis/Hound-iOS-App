//
//  Log Unit.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/2/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogUnit: String, CaseIterable {
    // Weight
    case mg = "milligram"     // Metric
    case g = "gram"       // Metric
    case oz = "ounce"     // Imperial
    case lb = "pound"     // Imperial
    case kg = "kilogram"     // Metric

    // Volume (Liquid)
    case ml = "milliliter"     // Metric
    case tsp = "teaspoon"   // Imperial
    case tbsp = "tablespoon" // Imperial
    case flOz = "fluid ounce"// Imperial
    case cup = "cup"   // Imperial
    case l = "liter"       // Metric

    // Distance
    case km = "kilometer"     // Metric
    case mi = "mile"     // Imperial

    // Time
    case minute = "minute" // Both
    case hour = "hour"     // Both

    // Countable Items
    case pill = "pill"     // Both
    case treat = "treat"   // Both

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
                    || logUnit == .mi || logUnit == .tsp
                    || logUnit == .tbsp
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
            return removeNonConformingUnits(forLogUnits: [.km, .mi, .minute, .hour])
        case .medicine:
            return removeNonConformingUnits(forLogUnits: [.mg, .ml, .tsp, .tbsp, .pill])
        case .weight:
            return removeNonConformingUnits(forLogUnits: [.g, .kg, .oz, .lb])
        case .wakeup, .sleep, .crate, .trainingSession:
            return removeNonConformingUnits(forLogUnits: [.minute, .hour])
        case .custom:
            // assuming all units are possible for custom log action
            return removeNonConformingUnits(forLogUnits: LogUnit.allCases)
        }
    }
    
    /// Produces a logNumberOfLogUnits that is more readable to the user. We accomplish this by rounding the double to two decimal places. Additionally, the decimal separator is varied based on locale (e.g. period in U.S.)
    static func roundedString(forLogNumberOfLogUnits logNumberOfLogUnits: Double?) -> String? {
        guard let logNumberOfLogUnits = logNumberOfLogUnits, logNumberOfLogUnits >= 0.01 else {
            // If logNumberOfLogUnits isn't greater than 0.01, we have nothing to display, return nil
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: logNumberOfLogUnits as NSNumber)
    }
    
    static func fromRoundedString(forLogNumberOfLogUnits logNumberOfLogUnits: String?) -> Double? {
        guard let logNumberOfLogUnits = logNumberOfLogUnits else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        let doubleValue = formatter.number(from: logNumberOfLogUnits)?.doubleValue
        
        // If logNumberOfLogUnits isn't greater than 0.01, we have nothing to display, return nil
        return (doubleValue ?? 0.0) >= 0.01 ? doubleValue : nil
    }
    
    /// Produces a logUnit that is more readable to the user. We accomplish this by changing the plurality of a log unit if needed : "cup" -> "cups" (changed needed if numberOfUnits != 1); "g" -> "g" (no change needed ever).
    static func adjustedPluralityString(forLogUnit logUnit: LogUnit?, forLogNumberOfLogUnits logNumberOfLogUnits: Double?) -> String? {
        guard let logUnit = logUnit, let logNumberOfLogUnits = logNumberOfLogUnits else {
            return nil
        }
        
        func isApproximatelyOne(_ value: Double, epsilon: Double = 0.0001) -> Bool {
            return abs(value - 1.0) < epsilon
        }
        
        return isApproximatelyOne(logNumberOfLogUnits) ? logUnit.rawValue : logUnit.rawValue.appending("s")
        /*
        switch logUnit {
        case .oz, .flOz, .mi, .mg, .g, .kg, .ml, .l, .km, .tsp, .tbsp:
            return logUnit.rawValue
        case .lb, .cup, .treat, .pill, .hour, .minute:
            return isApproximatelyOne(logNumberOfLogUnits) ? logUnit.rawValue : logUnit.rawValue.appending("s")
        }
         */
    }
    
    /// Produces a logUnit and logNumberOfLogUnits that is more readable to the user. Converts the unit and value of units into the correct system.For example: .cup, 1.5 -> "1.5 cups"; .g, 1.0 -> "1g"
    static func convertedMeasurementString(forLogUnit: LogUnit?, forLogNumberOfLogUnits: Double?, toTargetSystem: MeasurementSystem) -> String? {
        guard let forLogUnit = forLogUnit, let forLogNumberOfLogUnits = forLogNumberOfLogUnits else {
            return nil
        }
        
        let converted = UnitConverter.convert(forLogUnit: forLogUnit, forNumberOfLogUnits: forLogNumberOfLogUnits, toTargetSystem: toTargetSystem)
        let convertedLogUnit = converted?.0
        let convertedLogNumberOfLogUnits = converted?.1
        
        guard let convertedLogUnit = convertedLogUnit, let convertedLogNumberOfLogUnits = convertedLogNumberOfLogUnits else {
            return nil
        }
        
        // Take our raw values and convert them to something more readable
        let adjustedPluralityString = LogUnit.adjustedPluralityString(forLogUnit: convertedLogUnit, forLogNumberOfLogUnits: convertedLogNumberOfLogUnits) ?? ""
        let readableIndividualLogNumberOfLogUnits = LogUnit.roundedString(forLogNumberOfLogUnits: convertedLogNumberOfLogUnits) ?? ""
        
        return "\(readableIndividualLogNumberOfLogUnits) \(adjustedPluralityString)"
    }
}
