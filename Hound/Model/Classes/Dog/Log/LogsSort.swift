//
//  LogsSort.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/4/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsSortField: CaseIterable {
    case createdDate
    case modifiedDate
    case logStartDate
    case logEndDate

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
    case ascending
    case descending

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
    
    var sortField: LogsSortField = .logStartDate
    var sortDirection: LogsSortDirection = .ascending
    
    // MARK: - Main
    
    init(sortField: LogsSortField? = nil, sortDirection: LogsSortDirection? = nil) {
        self.sortField = sortField ?? self.sortField
        self.sortDirection = sortDirection ?? self.sortDirection
    }
    
    // MARK: - Function
    
    func sort(logs: [Log]) -> [Log] {
        let filteredLogs: [Log]
        if sortField == .logEndDate {
            filteredLogs = logs.filter { $0.logEndDate != nil }
        } else {
            filteredLogs = logs
        }
        
        let sortedLogs: [Log] = filteredLogs.sorted { (lhs: Log, rhs: Log) in
            let comparisonResult: ComparisonResult
            switch sortField {
            case .createdDate:
                comparisonResult = lhs.createdDate.compare(rhs.createdDate)
            case .modifiedDate:
                comparisonResult = lhs.modifiedDate.compare(rhs.modifiedDate)
            case .logStartDate:
                comparisonResult = lhs.logStartDate.compare(rhs.logStartDate)
            case .logEndDate:
                // Safe to force unwrap because of filter above
                comparisonResult = lhs.logEndDate!.compare(rhs.logEndDate!)
            }
            return sortDirection == .ascending ? (comparisonResult == .orderedAscending) : (comparisonResult == .orderedDescending)
        }
        
        return sortedLogs
    }
}

