//
//  LogsSort.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsSortField: CaseIterable {
    case logStartDate
    case logEndDate
    case createdDate
    case modifiedDate
    
    var readableValue: String {
        switch self {
        case .createdDate:
            return "Created Date"
        case .modifiedDate:
            return "Modified Date"
        case .logStartDate:
            return "Start Date"
        case .logEndDate:
            return "End Date"
        }
    }
}

enum LogsSortDirection: CaseIterable {
    case descending
    case ascending

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
        copy.sortField = self.sortField
        copy.sortDirection = self.sortDirection
        return copy
    }
    
    // MARK: - Properties
    
    var sortField: LogsSortField = .logStartDate
    
    var sortDirection: LogsSortDirection = .descending
    
    // MARK: - Computed Properties
    
    var availableFields: [LogsSortField] {
        return LogsSortField.allCases
    }
    
    var availableDirections: [LogsSortDirection] {
        return LogsSortDirection.allCases
    }
    
    // MARK: - Main
    
    init(sortField: LogsSortField? = nil, sortDirection: LogsSortDirection? = nil) {
        self.sortField = sortField ?? self.sortField
        self.sortDirection = sortDirection ?? self.sortDirection
    }
    
    // MARK: - Function
    
    func reset() {
        self.sortField = .logStartDate
        self.sortDirection = .descending
    }
    
    func sort(_ logs: [Log]) -> [Log] {
        return LogsSort.sort(logs, sortField: self.sortField, sortDirection: self.sortDirection)
    }
    
    /// Sorts an array of logs based on the current sort field and direction.
    static func sort(_ logs: [Log], sortField: LogsSortField, sortDirection: LogsSortDirection) -> [Log] {
        let sortedLogs: [Log] = logs.sorted { (lhs: Log, rhs: Log) in
            let comparisonResult = lhs.compare(to: rhs, sortField: sortField)
            return sortDirection == .ascending ? (comparisonResult == .orderedAscending) : (comparisonResult == .orderedDescending)
        }
        
        return sortedLogs
    }
}

