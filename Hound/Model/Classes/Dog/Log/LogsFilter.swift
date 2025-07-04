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
        copy.startDate = self.startDate
        copy.endDate = self.endDate
        copy.isStartDateEnabled = self.isStartDateEnabled
        copy.isEndDateEnabled = self.isEndDateEnabled
        return copy
    }
    
    // MARK: - Properties
    
    private(set) var dogManager: DogManager = DogManager()
    
    /// Text used to broadly search through logs. If empty, no search text is applied
    private(set) var searchText: String = ""
    
    private(set) var filteredDogsUUIDs: Set<UUID> = []
    
    private(set) var filteredLogActionActionTypeIds: Set<Int> = []
    
    private(set) var filteredFamilyMemberUserIds: Set<String> = []
    
    /// Caches the selected start date. Only applied when isStartDateEnabled is true
    private(set) var startDate: Date?
    /// Caches the selected end date. Only applied when isEndDateEnabled is true
    private(set) var endDate: Date?
    
    private(set) var isStartDateEnabled: Bool = false
    private(set) var isEndDateEnabled: Bool = false
    
    var hasActiveFilter: Bool {
        return searchText.isEmpty &&
        filteredDogsUUIDs.isEmpty &&
        filteredLogActionActionTypeIds.isEmpty &&
        filteredFamilyMemberUserIds.isEmpty &&
        isStartDateEnabled == false &&
        isEndDateEnabled == false
    }
    
    // MARK: - Main
    
    init(forDogManager: DogManager) {
        super.init()
        apply(forDogManager: dogManager)
    }
    
    // MARK: - Computed Properties
    
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
        apply(forStartDate: nil)
        apply(forEndDate: nil)
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
    
    // startDate
    func apply(forStartDate: Date?) {
        startDate = forStartDate
    }
    
    func apply(forStartDateEnabled: Bool) {
        isStartDateEnabled = forStartDateEnabled
    }
    
    // endDate
    func apply(forEndDate: Date?) {
        endDate = forEndDate
    }
    
    func apply(forEndDateEnabled: Bool) {
        isEndDateEnabled = forEndDateEnabled
    }
}
