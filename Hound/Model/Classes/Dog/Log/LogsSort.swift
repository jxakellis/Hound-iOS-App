//
//  LogsSort.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsDateType: CaseIterable {
    case logStartDate
    case logEndDate
    case createdDate
    case modifiedDate
    
    static let defaultDateType = LogsDateType.logStartDate
    
    var readableValue: String {
        switch self {
        case .createdDate:
            return "Created"
        case .modifiedDate:
            return "Modified"
        case .logStartDate:
            return "Start Date"
        case .logEndDate:
            return "End Date"
        }
    }
    
    func dateForDateType(_ log: Log) -> Date {
        switch self {
        case .createdDate:
            return log.logCreated
        case .modifiedDate:
            return log.logLastModified ?? log.logCreated
        case .logStartDate:
            return log.logStartDate
        case .logEndDate:
            return log.logEndDate ?? log.logStartDate
        }
    }
    
    func compare(lhs: Log, rhs: Log) -> ComparisonResult {
        return self.dateForDateType(lhs).compare(self.dateForDateType(rhs))
    }
}

enum LogsSortDirection: CaseIterable {
    case descending
    case ascending
    
    static let defaultSortDirection = LogsSortDirection.descending

    var readableValue: String {
        switch self {
        case .ascending:
            return "Oldest First"
        case .descending:
            return "Newest First"
        }
    }
}

final class LogsSort: NSObject, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LogsSort()
        copy.dateType = self.dateType
        copy.sortDirection = self.sortDirection
        return copy
    }
    
    // MARK: - Equatable
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LogsSort else {
            return false
        }
        
        return self.dateType == object.dateType && self.sortDirection == object.sortDirection
    }
    
    // MARK: - Properties
    
    var dateType: LogsDateType = LogsDateType.defaultDateType
    
    var sortDirection: LogsSortDirection = LogsSortDirection.defaultSortDirection
    
    // MARK: - Computed Properties
    
    var availableFields: [LogsDateType] {
        return LogsDateType.allCases
    }
    
    var availableDirections: [LogsSortDirection] {
        return LogsSortDirection.allCases
    }
    
    var hasActiveSort: Bool {
        return self.dateType != LogsDateType.defaultDateType || self.sortDirection != LogsSortDirection.defaultSortDirection
    }
    
    // MARK: - Main
    
    init(dateType: LogsDateType? = nil, sortDirection: LogsSortDirection? = nil) {
        self.dateType = dateType ?? self.dateType
        self.sortDirection = sortDirection ?? self.sortDirection
    }
    
    // MARK: - Function
    
    func reset() {
        self.dateType = LogsDateType.defaultDateType
        self.sortDirection = LogsSortDirection.defaultSortDirection
    }
    
    func sort(_ logs: [Log]) -> [Log] {
        return LogsSort.sort(logs, dateType: self.dateType, sortDirection: self.sortDirection)
    }
    
    /// Sorts an array of logs based on the current sort field and direction.
    static func sort(_ logs: [Log], dateType: LogsDateType, sortDirection: LogsSortDirection) -> [Log] {
        let sortedLogs: [Log] = logs.sorted { (lhs: Log, rhs: Log) in
            let comparisonResult = dateType.compare(lhs: lhs, rhs: rhs)
            return sortDirection == .ascending ? (comparisonResult == .orderedAscending) : (comparisonResult == .orderedDescending)
        }
        
        return sortedLogs
    }
}
