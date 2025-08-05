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
        let copy = LogsFilter(forDogManager: dogManager)
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
    
    private(set) var timeRangeField: LogsSortField = LogsSortField.logStartDate
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
    
    init(forDogManager: DogManager) {
        super.init()
        apply(forDogManager: forDogManager)
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
    
    func clearAll() {
        apply(forFilterDogs: [])
        apply(forFilterLogActions: [])
        apply(forFilterFamilyMembers: [])
        apply(forSearchText: "")
        apply(forTimeRangeField: LogsSortField.logStartDate)
        apply(forTimeRangeFromDate: nil)
        apply(forTimeRangeToDate: nil)
    }
    
    func apply(forDogManager: DogManager) {
        dogManager = forDogManager
    }
    
    // filteredDogsUUIDs
    func apply(forFilterDogs: [Dog]) {
        filteredDogsUUIDs = Set(forFilterDogs.map({ $0.dogUUID }))
    }
    func add(forFilterDogUUID: UUID) {
        filteredDogsUUIDs.insert(forFilterDogUUID)
    }
    func remove(forFilterDogUUID: UUID) {
        filteredDogsUUIDs.remove(forFilterDogUUID)
    }
    
    // filteredLogActionActionTypeIds
    func apply(forFilterLogActions: [LogActionType]) {
        filteredLogActionActionTypeIds = Set(forFilterLogActions.map({ $0.logActionTypeId }))
    }
    func add(forLogActionTypeId: Int) {
        filteredLogActionActionTypeIds.insert(forLogActionTypeId)
    }
    func remove(forLogActionTypeId: Int) {
        filteredLogActionActionTypeIds.remove(forLogActionTypeId)
    }
    
    // filteredFamilyMemberUserIds
    func apply(forFilterFamilyMembers: [FamilyMember]) {
        filteredFamilyMemberUserIds = Set(forFilterFamilyMembers.map({ $0.userId }))
    }
    func add(forUserId: String) {
        filteredFamilyMemberUserIds.insert(forUserId)
    }
    func remove(forUserId: String) {
        filteredFamilyMemberUserIds.remove(forUserId)
    }
    
    // forSearchText
    func apply(forSearchText: String) {
        searchText = forSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // timeRangeField, timeRangeFromDate, timeRangeToDate
    func apply(forTimeRangeField: LogsSortField) {
        timeRangeField = forTimeRangeField
    }
    func apply(forTimeRangeFromDate: Date?) {
        timeRangeFromDate = forTimeRangeFromDate
    }
    func apply(forTimeRangeToDate: Date?) {
        timeRangeToDate = forTimeRangeToDate
    }
    
}
