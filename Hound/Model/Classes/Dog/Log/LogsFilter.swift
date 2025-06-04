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
    
    private var dogManager: DogManager = DogManager()
    
    /// Dogs that the user's has selected to filter by. If empty, all logs by all dogs are included. Otherwise, only logs with their dogUUID in this array are included
    private(set) var filterDogs: [Dog] = [] {
        didSet {
            filterDogs.sort(by: { $0 <= $1})
            storedAvailableDogs = nil
        }
    }
    
    /// Increases efficiency by storing this result. Only invalidate if the filters are updated
    private var storedAvailableDogs: [Dog]?
    
    /// Log actions that the user's has selected to filter by. If empty, all logs by all log actions are included. Otherwise, only logs with their log action in this array are included
    private(set) var filterLogActions: [LogActionType] = [] {
        didSet {
            filterLogActions.sort(by: { $0 <= $1})
            storedAvailableLogActions = nil
        }
    }
    
    /// Increases efficiency by storing this result. Only invalidate if the filters are updated
    private var storedAvailableLogActions: [LogActionType]?
    
    /// Family members that the user's has selected to filter by. If empty, all logs by all familyMembers are included. Otherwise, only logs with their familyMembers in this array are included
    private(set) var filterFamilyMembers: [FamilyMember] = [] {
        didSet {
            filterFamilyMembers.sort(by: { $0 <= $1})
            storedAvailableFamilyMembers = nil
        }
    }
    
    /// Increases efficiency by storing this result. Only invalidate if the filters are updated
    private var storedAvailableFamilyMembers: [FamilyMember]?
    
    /// Returns true if filterDogs, filterLogActions, and filterFamilyMembers are all empty
    var isEmpty: Bool {
        return filterDogs.isEmpty && filterLogActions.isEmpty && filterFamilyMembers.isEmpty
    }
    
    // MARK: - Main
    
    init(forDogManager: DogManager) {
        super.init()
        apply(forDogManager: dogManager)
    }
    
    // MARK: - Computed Properties
    
    /// All the dogs that it is currently possible for a user to filter by (given the other filters currently applied). This means that the dog must have at least 1 log in the first place, and at least one of its logs must also be adhere to both the filters
    var availableDogs: [Dog] {
        if let storedAvailableDogs = storedAvailableDogs {
            return storedAvailableDogs
        }
        
        var availableDogUUIDs: Set<UUID> = []
        for dog in dogManager.dogs {
            for log in dog.dogLogs.dogLogs {
                if (filterLogActions.isEmpty == false && filterLogActions.contains(where: { $0 == log.logActionType}) == false) {
                    // We are filtering by log actions and this is not one of them, therefore, this log action is not available
                    continue
                }
                if (filterFamilyMembers.isEmpty == false && filterFamilyMembers.contains(where: { $0.userId == log.userId}) == false) {
                    // We are filtering by family members and this is not one of them, therefore, this family member is no available
                    continue
                }
                
                // This dog is available because it exists for some log action / family member currently filtered by
                availableDogUUIDs.insert(dog.dogUUID)
                // We can break here as we only need this to trigger once for a given dog
                break
            }
        }
        
        var availableDogs: [Dog] = []
        availableDogUUIDs.forEach { availableDogUUID in
            guard let dog = dogManager.findDog(forDogUUID: availableDogUUID) else {
                return
            }
            
            availableDogs.append(dog)
        }
        
        availableDogs.sort()
        storedAvailableDogs = availableDogs
        return availableDogs
    }
    
    /// All the log actions that it is currently possible for a user to filter by (given the other filters currently applied).
    var availableLogActions: [LogActionType] {
        if let storedAvailableLogActions = storedAvailableLogActions {
            return storedAvailableLogActions
        }
        
        var availableLogActions: Set<LogActionType> = []
        for dog in dogManager.dogs {
            if (filterDogs.isEmpty == false && filterDogs.contains(where: {$0.dogUUID == dog.dogUUID}) == false) {
                // We are filtering by dogs and this is not one of them, therefore, this dog is no available
                continue
            }
            
            for log in dog.dogLogs.dogLogs {
                if (filterFamilyMembers.isEmpty == false && filterFamilyMembers.contains(where: { $0.userId == log.userId}) == false) {
                    // We are filtering by family members and this is not one of them, therefore, this family member is no available
                    continue
                }
                
                // This log action is available because it exists for some dog / family member currently filtered by
                availableLogActions.insert(log.logActionType)
            }
        }
        
        storedAvailableLogActions = Array(availableLogActions).sorted()
        return storedAvailableLogActions ?? Array(availableLogActions).sorted()
        
    }
    
    /// All the family members that it is currently possible for a user to filter by (given the other filters currently applied).
    var availableFamilyMembers: [FamilyMember] {
        if let storedAvailableFamilyMembers = storedAvailableFamilyMembers {
            return storedAvailableFamilyMembers
        }
        
        var availableFamilyMemberUserIds: Set<String> = []
        for dog in dogManager.dogs {
            if (filterDogs.isEmpty == false && filterDogs.contains(where: {$0.dogUUID == dog.dogUUID}) == false) {
                // We are filtering by dogs and this is not one of them, therefore, this dog is no available
                continue
            }
            
            for log in dog.dogLogs.dogLogs {
                if (filterLogActions.isEmpty == false && filterLogActions.contains(where: { $0 == log.logActionType}) == false) {
                    // We are filtering by log actions and this is not one of them, therefore, this log action is not available
                    continue
                }
                
                // This family member is available because it exists for some dog / log action currently filtered by
                availableFamilyMemberUserIds.insert(log.userId)
            }
        }
        
        var availableFamilyMembers: [FamilyMember] = []
        availableFamilyMemberUserIds.forEach { availableFamilyMemberUserId in
            guard let familyMember = FamilyInformation.findFamilyMember(forUserId: availableFamilyMemberUserId) else {
                return
            }
            availableFamilyMembers.append(familyMember)
        }
        
        availableFamilyMembers.sort()
        storedAvailableFamilyMembers = availableFamilyMembers
        return availableFamilyMembers
    }
    
    // MARK: - Functions
    
    /// Sets all filters to empty. This means that the logs filter will no longer be filtering by anything
    func clearAll() {
        apply(forFilterDogs: [])
        apply(forFilterLogActions: [])
        apply(forFilterFamilyMembers: [])
    }
    
    /// Recalculates all the applicable filters given the new dog manager. If a filter contains invalid elements with the new dog manager, those elements are removed
    func apply(forDogManager: DogManager) {
        dogManager = forDogManager
        
        // If our current filters applied to the new dogManager would result in an empty set of logs, meaning that our filter filters our every possible element, then this filter is not valid. Therefore, clear the filter
        guard dogManager.logsForDogUUIDsGroupedByDate(forFilter: self).isEmpty == false else {
            clearAll()
            return
        }
        
        apply(forFilterDogs: filterDogs)
        apply(forFilterLogActions: filterLogActions)
        apply(forFilterFamilyMembers: filterFamilyMembers)
    }
    
    /// If we want to apply a new filterDogs, then this may invalidate the other filters. This is because it could filter out logs that were previously included, making it impossible to filter by certain log actions or family members because therre are none
    func apply(forFilterDogs: [Dog]) {
        filterDogs = forFilterDogs
        
        // If we are applying an empty filter, there are two possible cases
        // 1. the previous filter was empty as well, then nothing changes
        // 2. the previous filter wasn't empty. That means that with this new filter there are now more options. This is because a non-empty filter restricts certain elements from being included. However a empty filter restricts nothing. Therefore, all elements that are valid with a non-empty filter must be valid with an empty filter as well
        guard forFilterDogs.isEmpty == false else {
            return
        }
        
        var includedLogActions: Set<LogActionType> = []
        var includedFamilyMemberUserIds: Set<String> = []
        
        dogManager.dogs.forEach { dog in
            // Find all of the log actions and family members that are included
            // If forFilterDogs is empty, then include all of the dogs
            guard forFilterDogs.contains(where: { $0.dogUUID == dog.dogUUID }) else {
                return
            }
            
            dog.dogLogs.dogLogs.forEach { log in
                includedLogActions.insert(log.logActionType)
                includedFamilyMemberUserIds.insert(log.userId)
            }
        }
        
        // Keep all of the filter passed through by a parameter, but remove any elements from other filters that are incompatible with the new filter (i.e. they cannot exist as there is no element that would satify both of the conditions)
        filterLogActions = filterLogActions.filter({ filterLogAction in
            return includedLogActions.contains(filterLogAction)
        })
        filterFamilyMembers = filterFamilyMembers.filter({ filterFamilyMember in
            return includedFamilyMemberUserIds.contains(filterFamilyMember.userId)
        })
    }
    
    /// If we want to apply a new filterLogActions, then this may invalidate the other filters. This is because it could filter out logs that were previously included, making it impossible to filter by certain dogs or family members because therre are none
    func apply(forFilterLogActions: [LogActionType]) {
        filterLogActions = forFilterLogActions
        
        // If we are applying an empty filter, there are two possible cases
        // 1. the previous filter was empty as well, then nothing changes
        // 2. the previous filter wasn't empty. That means that with this new filter there are now more options. This is because a non-empty filter restricts certain elements from being included. However a empty filter restricts nothing. Therefore, all elements that are valid with a non-empty filter must be valid with an empty filter as well
        guard forFilterLogActions.isEmpty == false else {
            return
        }
        
        var includedDogUUIDs: Set<UUID> = []
        var includedFamilyMemberUserIds: Set<String> = []
        
        dogManager.dogs.forEach { dog in
            // Find all of the dogs and family members that are included
            // If forFilterLogActions is empty, then include all of the dogs
            dog.dogLogs.dogLogs.forEach { log in
                guard forFilterLogActions.contains(log.logActionType) else {
                    return
                }
                
                includedDogUUIDs.insert(dog.dogUUID)
                includedFamilyMemberUserIds.insert(log.userId)
            }
        }
        
        // Keep all of the filter passed through by a parameter, but remove any elements from other filters that are incompatible with the new filter (i.e. they cannot exist as there is no element that would satify both of the conditions)
        filterDogs = filterDogs.filter({ filterDog in
            return includedDogUUIDs.contains(filterDog.dogUUID)
        })
        
        filterFamilyMembers = filterFamilyMembers.filter({ filterFamilyMember in
            return includedFamilyMemberUserIds.contains(filterFamilyMember.userId)
        })
    }
    
    /// If we want to apply a new filterFamilyMembers, then this may invalidate the other filters. This is because it could filter out logs that were previously included, making it impossible to filter by certain dogs or log actions because therre are none
    func apply(forFilterFamilyMembers: [FamilyMember]) {
        filterFamilyMembers = forFilterFamilyMembers
        
        // If we are applying an empty filter, there are two possible cases
        // 1. the previous filter was empty as well, then nothing changes
        // 2. the previous filter wasn't empty. That means that with this new filter there are now more options. This is because a non-empty filter restricts certain elements from being included. However a empty filter restricts nothing. Therefore, all elements that are valid with a non-empty filter must be valid with an empty filter as well
        guard forFilterFamilyMembers.isEmpty == false else {
            return
        }
        
        var includedDogUUIDs: Set<UUID> = []
        var includedLogActions: Set<LogActionType> = []
        
        dogManager.dogs.forEach { dog in
            // Find all of the dogs and family members that are included
            // If forFilterFamilyMembers is empty, then include all of the family members
            dog.dogLogs.dogLogs.forEach { log in
                guard forFilterFamilyMembers.contains(where: { $0.userId == log.userId}) else {
                    return
                }
                
                includedDogUUIDs.insert(dog.dogUUID)
                includedLogActions.insert(log.logActionType)
            }
        }
        
        // Keep all of the filter passed through by a parameter, but remove any elements from other filters that are incompatible with the new filter (i.e. they cannot exist as there is no element that would satify both of the conditions)
        filterDogs = filterDogs.filter({ filterDog in
            return includedDogUUIDs.contains(filterDog.dogUUID)
        })
        
        filterLogActions = filterLogActions.filter({ filterLogAction in
            return includedLogActions.contains(filterLogAction)
        })
    }
}
