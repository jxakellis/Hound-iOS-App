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
        let copy = LogsFilter(dogManager: dogManager)
        copy.searchText = self.searchText
        copy.filteredDogsUUIDs = self.filteredDogsUUIDs
        copy.filteredLogActionActionTypeIds = self.filteredLogActionActionTypeIds
        copy.filteredFamilyMemberUserIds = self.filteredFamilyMemberUserIds
        copy.timeRangeField = self.timeRangeField
        copy.timeRangeFromDate = self.timeRangeFromDate
        copy.timeRangeToDate = self.timeRangeToDate
        return copy
    }
    
    // MARK: - Properties
    
    private(set) var dogManager: DogManager = DogManager()
    
    /// Text used to broadly search through logs. If empty, no search text is applied
    private(set) var searchText: String = ""
    
    private(set) var filteredDogsUUIDs: Set<UUID> = []
    
    private(set) var filteredLogActionActionTypeIds: Set<Int> = []
    
    private(set) var filteredFamilyMemberUserIds: Set<String> = []
    
    private(set) var timeRangeField: LogsSortField = LogsSortField.defaultSortField
    private(set) var timeRangeFromDate: Date?
    private(set) var timeRangeToDate: Date?
    
    var isFromDateEnabled: Bool {
        return timeRangeFromDate != nil
    }
    var isToDateEnabled: Bool {
        return timeRangeToDate != nil
    }
    
    var hasActiveFilter: Bool {
        return (numActiveFilters ?? 0) > 0
    }
    
    var numActiveFilters: Int? {
        let num = (searchText.isEmpty ? 0 : 1)
        + filteredDogsUUIDs.count
        + filteredLogActionActionTypeIds.count
        + filteredFamilyMemberUserIds.count
        + (isFromDateEnabled ? 1 : 0)
        + (isToDateEnabled ? 1 : 0)
        
        return num == 0 ? nil : num
    }
    
    // MARK: - Main
    
    init(dogManager: DogManager) {
        super.init()
        apply(dogManager: dogManager)
    }
    
    // MARK: - Computed Properties
    
    var availableTimeRangeFields: [LogsSortField] {
        return LogsSortField.allCases
    }
    
    var availableDogs: [Dog] {
        return dogManager.dogs
    }
    
    var availableLogActions: [LogActionType] {
        return GlobalTypes.shared.logActionTypes
    }
    
    var availableFamilyMembers: [FamilyMember] {
        return FamilyInformation.familyMembers
    }
    
    // MARK: - Functions
    
    func reset() {
        apply(filterDogs: [])
        apply(filterLogActions: [])
        apply(filterFamilyMembers: [])
        apply(searchText: "")
        apply(timeRangeField: LogsSortField.defaultSortField)
        apply(timeRangeFromDate: nil)
        apply(timeRangeToDate: nil)
    }
    
    func apply(dogManager: DogManager) {
        self.dogManager = dogManager
    }
    
    // filteredDogsUUIDs
    func apply(filterDogs: [Dog]) {
        filteredDogsUUIDs = Set(filterDogs.map({ $0.dogUUID }))
    }
    func add(filterDogUUID: UUID) {
        filteredDogsUUIDs.insert(filterDogUUID)
    }
    func remove(filterDogUUID: UUID) {
        filteredDogsUUIDs.remove(filterDogUUID)
    }
    
    // filteredLogActionActionTypeIds
    func apply(filterLogActions: [LogActionType]) {
        filteredLogActionActionTypeIds = Set(filterLogActions.map({ $0.logActionTypeId }))
    }
    func add(logActionTypeId: Int) {
        filteredLogActionActionTypeIds.insert(logActionTypeId)
    }
    func remove(logActionTypeId: Int) {
        filteredLogActionActionTypeIds.remove(logActionTypeId)
    }
    
    // filteredFamilyMemberUserIds
    func apply(filterFamilyMembers: [FamilyMember]) {
        filteredFamilyMemberUserIds = Set(filterFamilyMembers.map({ $0.userId }))
    }
    func add(userId: String) {
        filteredFamilyMemberUserIds.insert(userId)
    }
    func remove(userId: String) {
        filteredFamilyMemberUserIds.remove(userId)
    }
    
    // searchText
    func apply(searchText: String) {
        self.searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // timeRangeField, timeRangeFromDate, timeRangeToDate
    func apply(timeRangeField: LogsSortField) {
        self.timeRangeField = timeRangeField
    }
    func apply(timeRangeFromDate: Date?) {
        self.timeRangeFromDate = timeRangeFromDate
    }
    func apply(timeRangeToDate: Date?) {
        self.timeRangeToDate = timeRangeToDate
    }
    
}
