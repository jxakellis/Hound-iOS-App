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
        let copy = LogsFilter(availableDogManager: availableDogManager)
        copy.searchText = self.searchText
        copy.filteredDogsUUIDs = self.filteredDogsUUIDs
        copy.filteredLogActionActionTypeIds = self.filteredLogActionActionTypeIds
        copy.filteredFamilyMemberUserIds = self.filteredFamilyMemberUserIds
        copy.timeRangeField = self.timeRangeField
        copy.timeRangeFromDate = self.timeRangeFromDate
        copy.timeRangeToDate = self.timeRangeToDate
        copy.onlyShowLikes = self.onlyShowLikes
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
            self.onlyShowLikes == object.onlyShowLikes
    }
    
    /// Text used to broadly search through logs. If empty, no search text is applied
    private(set) var searchText: String = ""
    
    private(set) var availableDogManager: DogManager = DogManager()
    private(set) var filteredDogsUUIDs: Set<UUID> = []
    
    private(set) var filteredLogActionActionTypeIds: Set<Int> = []
    
    private(set) var filteredFamilyMemberUserIds: Set<String> = []

    private(set) var timeRangeField: LogsDateType?
    private(set) var timeRangeFromDate: Date?
    private(set) var timeRangeToDate: Date?
    private(set) var onlyShowLikes: Bool = false
    
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
        + (onlyShowLikes ? 1 : 0)
        + (isFromDateEnabled ? 1 : 0)
        + (isToDateEnabled ? 1 : 0)
        
        return num == 0 ? nil : num
    }
    
    // MARK: - Main
    
    init(availableDogManager: DogManager) {
        super.init()
        apply(availableDogManager: availableDogManager)
    }
    
    // MARK: - Computed Properties
    
    var availableTimeRangeFields: [LogsDateType] {
        return LogsDateType.allCases
    }
    
    var availableDogs: [Dog] {
        return availableDogManager.dogs
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
        apply(onlyShowLikes: false)
        apply(searchText: "")
        apply(timeRangeField: LogsDateType.defaultDateType)
        apply(timeRangeFromDate: nil)
        apply(timeRangeToDate: nil)
    }
    
    func apply(availableDogManager: DogManager) {
        self.availableDogManager = availableDogManager
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

    func apply(onlyShowLikes: Bool) {
        self.onlyShowLikes = onlyShowLikes
    }
    
    // searchText
    func apply(searchText: String) {
        self.searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // timeRangeField, timeRangeFromDate, timeRangeToDate
    func apply(timeRangeField: LogsDateType?) {
        self.timeRangeField = timeRangeField
    }
    func apply(timeRangeFromDate: Date?) {
        self.timeRangeFromDate = timeRangeFromDate
    }
    func apply(timeRangeToDate: Date?) {
        self.timeRangeToDate = timeRangeToDate
    }
    
}
