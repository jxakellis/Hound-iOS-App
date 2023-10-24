//
//  Log Unit.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/2/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/*
 TODO NOW Implementation strategy for log units
 DONE 1. create log action function that returns acceptable log units for a given log action
 DONE 2. create la function that returns display name for unit given a quantity (e.g. 1 unit, 5 units)
 DONE 3. add fields to log data object, create functions to modify values
 4. add a new row to the add log page, which has 2 parts, quantity entry and unit selection
 4a. if we are running low on log page space, change the page to a scrolling one with each field a set size
 DONE 5. if user changes log action, and that log action isn't compatible with current units, then set quantity and units to nil
 DONE 6. make sure quantity and units are both transmitted to the server when log is converted to a body and receieved when a body is decoded to a log
 7. add logic for custom units just like custom log/reminder type, with separate fields to track value and a specicial localized tracker that suggests custom units that were recently input by the user
 */

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
    
    case duration = "duration"
    
    /// For a given logAction, returns the valid LogUnits that could be possible. If there aren't any that make sense, return nil
    static func logUnits(forLogAction logAction: LogAction) -> [LogUnit]? {
        switch logAction {
        case .feed:
            return [.g, .kg, .oz, .lb, .cup]
        case .water:
            return [.ml, .l, .flOz, .cup]
        case .treat:
            return [.treat]
        case .pee, .poo, .both, .neither, .accident:
            return nil
        case .walk:
            return [.km, .mi, .duration]
        case .brush, .bathe:
            return nil
        case .medicine:
            return [.mg, .ml, .tsp, .tbsp, .pill]
        case .weight:
            return [.g, .kg, .oz, .lb]
        case .wakeup, .sleep, .crate, .trainingSession:
            return [.duration]
        case .doctor:
            return nil
        case .custom:
            // assuming all units are possible for custom log action
            return LogUnit.allCases
        }
    }
    
    func displayLogUnitName(forNumberOfUnits numberOfUnits: Int) -> String {
        switch self {
        case .oz:
            return self.rawValue
        case .lb:
            return numberOfUnits == 1 ? self.rawValue : self.rawValue.appending("s")
        case .flOz:
            return self.rawValue
        case .cup:
            return numberOfUnits == 1 ? self.rawValue : self.rawValue.appending("s")
        case .mi:
            return self.rawValue
        case .mg:
            return self.rawValue
        case .g:
            return self.rawValue
        case .kg:
            return self.rawValue
        case .ml:
            return self.rawValue
        case .l:
            return self.rawValue
        case .km:
            return self.rawValue
        case .treat:
            return numberOfUnits == 1 ? self.rawValue : self.rawValue.appending("s")
        case .tsp:
            return self.rawValue
        case .tbsp:
            return self.rawValue
        case .pill:
            return numberOfUnits == 1 ? self.rawValue : self.rawValue.appending("s")
        case .duration:
            return self.rawValue
        }
    }
}
