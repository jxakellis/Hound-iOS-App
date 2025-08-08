//
//  LogsFilter.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

class LogsFilter: NSObject, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LogsFilter(dogManagerForDogUUIDs: dogManagerForDogUUIDs)
        copy.searchText = self.searchText
        copy.filteredDogsUUIDs = self.filteredDogsUUIDs
        copy.filteredLogActionActionTypeIds = self.filteredLogActionActionTypeIds
        copy.filteredFamilyMemberUserIds = self.filteredFamilyMemberUserIds
        copy.timeRangeField = self.timeRangeField
        copy.timeRangeFromDate = self.timeRangeFromDate
        copy.timeRangeToDate = self.timeRangeToDate
        copy.onlyShowMyLikes = self.onlyShowMyLikes
        return copy
    }
    
    // MARK: - Equatable
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? LogsFilter else {
            return false
        }
        
        // DONT check availableDogManager
        return self.filteredDogsUUIDs == object.filteredDogsUUIDs &&
        self.searchText == object.searchText &&
        self.filteredDogsUUIDs == object.filteredDogsUUIDs &&
        self.filteredLogActionActionTypeIds == object.filteredLogActionActionTypeIds &&
        self.filteredFamilyMemberUserIds == object.filteredFamilyMemberUserIds &&
        self.timeRangeField == object.timeRangeField &&
        self.timeRangeFromDate == object.timeRangeFromDate &&
        self.timeRangeToDate == object.timeRangeToDate &&
        self.onlyShowMyLikes == object.onlyShowMyLikes
    }
    
    /// Text used to broadly search through logs. If empty, no search text is applied
    var searchText: String = ""
    
    var dogManagerForDogUUIDs: DogManager = DogManager()
    
    var filteredDogsUUIDs: Set<UUID> = []
    
    var filteredLogActionActionTypeIds: Set<Int> = []
    
    var filteredFamilyMemberUserIds: Set<String> = []
    
    var timeRangeField: LogsDateType?
    private static var defaultTimeRangeFromDate: Date = Calendar.user.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    private static var defaultTimeRangeToDate: Date = Calendar.user.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    private(set) var timeRangeFromDate: Date = LogsFilter.defaultTimeRangeFromDate
    func setTimeRangeFromDate(_ date: Date) {
        self.timeRangeFromDate = date
        if date > timeRangeToDate {
            timeRangeToDate = date
        }
    }
    
    private(set) var timeRangeToDate: Date = LogsFilter.defaultTimeRangeToDate
    func setTimeRangeToDate(_ date: Date) {
        self.timeRangeToDate = date
        if date < timeRangeFromDate {
            timeRangeFromDate = date
        }
    }
    
    var onlyShowMyLikes: Bool = false
    
    // MARK: - Main
    
    init(dogManagerForDogUUIDs: DogManager) {
        super.init()
        self.dogManagerForDogUUIDs = dogManagerForDogUUIDs
    }
    
    // MARK: - Computed Properties
    
    var availableTimeRangeFields: [LogsDateType] {
        return LogsDateType.allCases
    }
    
    var availableDogs: [Dog] {
        return dogManagerForDogUUIDs.dogs
    }
    
    var availableLogActions: [LogActionType] {
        return GlobalTypes.shared.logActionTypes
    }
    
    var availableFamilyMembers: [FamilyMember] {
        return FamilyInformation.familyMembers
    }
    
    var isTimeRangeEnabled: Bool {
        return timeRangeField != nil
    }
    
    var hasActiveFilter: Bool {
        return (numActiveFilters ?? 0) > 0
    }
    
    var numActiveFilters: Int? {
        let num = (searchText.isEmpty ? 0 : 1)
        + filteredDogsUUIDs.count
        + filteredLogActionActionTypeIds.count
        + filteredFamilyMemberUserIds.count
        + (onlyShowMyLikes ? 1 : 0)
        + (isTimeRangeEnabled ? 1 : 0)
        
        return num == 0 ? nil : num
    }
    
    // MARK: - Functions
    
    func reset() {
        filteredDogsUUIDs = Set()
        filteredLogActionActionTypeIds = Set()
        filteredFamilyMemberUserIds = Set()
        onlyShowMyLikes = false
        searchText = ""
        timeRangeField = nil
        timeRangeFromDate = LogsFilter.defaultTimeRangeFromDate
        timeRangeToDate = LogsFilter.defaultTimeRangeToDate
    }
}
