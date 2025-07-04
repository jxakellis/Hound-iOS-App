//
//  LogsFilter.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

class LogsFilter: NSObject {
    
    // MARK: - Properties
    
    private(set) var dogManager: DogManager = DogManager()
    
    /// Text used to broadly search through logs. If empty, no search text is applied
    private(set) var searchText: String = ""
    
    private(set) var filteredDogsUUIDs: Set<UUID> = []
    
    private(set) var filteredLogActionActionTypeIds: Set<Int> = []
    
    private(set) var filteredFamilyMemberUserIds: Set<String> = []
    
    var hasActiveFilter: Bool {
        return searchText.isEmpty && filteredDogsUUIDs.isEmpty && filteredLogActionActionTypeIds.isEmpty && filteredFamilyMemberUserIds.isEmpty
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
}
