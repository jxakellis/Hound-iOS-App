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
    
    /// Dogs that the user's has selected to filter by. If empty, all logs by all dogs are included. Otherwise, only logs with their dogId in this array are included
    private(set) var filterDogs: [Dog] = [] {
        didSet {
            filterDogs.sort(by: { $0 <= $1})
            storedAvailableDogs = nil
        }
    }
    
    /// Increases efficiency by storing this result. Only invalidate if the filters are updated
    private var storedAvailableDogs: [Dog]?
    /// All the dogs that it is currently possible for a user to filter by (given the other filters currently applied).
    var availableDogs: [Dog] {
        if let storedAvailableDogs = storedAvailableDogs {
            return storedAvailableDogs
        }
        
        var availableDogIds: Set<Int> = []
        for dog in dogManager.dogs {
            for log in dog.dogLogs.logs {
                if (filterLogActions.count >= 1 && filterLogActions.contains(where: { $0 == log.logAction}) == false) {
                    // We are filtering by log actions and this is not one of them, therefore, this log action is not available
                    continue
                }
                if (filterFamilyMembers.count >= 1 && filterFamilyMembers.contains(where: { $0.userId == log.userId}) == false) {
                    // We are filtering by family members and this is not one of them, therefore, this family member is no available
                    continue
                }
                
                // This dog is available because it exists for some log action / family member currently filtered by
                availableDogIds.insert(dog.dogId)
                // We can break here as we only need this to trigger once for a given dog
                break
            }
        }
        
        var availableDogs: [Dog] = []
        availableDogIds.forEach { availableDogId in
            guard let dog = dogManager.findDog(forDogId: availableDogId) else {
                return
            }
            
            availableDogs.append(dog)
        }
        
        availableDogs.sort()
        storedAvailableDogs = availableDogs
        return availableDogs
    }
    
    /// Log actions that the user's has selected to filter by. If empty, all logs by all log actions are included. Otherwise, only logs with their log action in this array are included
    private(set) var filterLogActions: [LogAction] = [] {
        didSet {
            filterLogActions.sort(by: { $0 <= $1})
            storedAvailableLogActions = nil
        }
    }
    
    /// Increases efficiency by storing this result. Only invalidate if the filters are updated
    private var storedAvailableLogActions: [LogAction]?
    /// All the log actions that it is currently possible for a user to filter by (given the other filters currently applied).
    var availableLogActions: [LogAction] {
        if let storedAvailableLogActions = storedAvailableLogActions {
            return storedAvailableLogActions
        }
        
        var availableLogActions: Set<LogAction> = []
        for dog in dogManager.dogs {
            if (filterDogs.count >= 1 && filterDogs.contains(where: {$0.dogId == dog.dogId}) == false) {
                // We are filtering by dogs and this is not one of them, therefore, this dog is no available
                continue
            }
            
            for log in dog.dogLogs.logs {
                if (filterFamilyMembers.count >= 1 && filterFamilyMembers.contains(where: { $0.userId == log.userId}) == false) {
                    // We are filtering by family members and this is not one of them, therefore, this family member is no available
                    continue
                }
                
                // This log action is available because it exists for some dog / family member currently filtered by
                availableLogActions.insert(log.logAction)
            }
        }
        
        storedAvailableLogActions = Array(availableLogActions).sorted()
        return storedAvailableLogActions ?? Array(availableLogActions).sorted()
        
    }
    
    /// Family members that the user's has selected to filter by. If empty, all logs by all familyMembers are included. Otherwise, only logs with their familyMembers in this array are included
    private(set) var filterFamilyMembers: [FamilyMember] = [] {
        didSet {
            filterFamilyMembers.sort(by: { $0 <= $1})
            storedAvailableFamilyMembers = nil
        }
    }
    
    /// Increases efficiency by storing this result. Only invalidate if the filters are updated
    private var storedAvailableFamilyMembers: [FamilyMember]?
    /// All the family members that it is currently possible for a user to filter by (given the other filters currently applied).
    var availableFamilyMembers: [FamilyMember] {
        if let storedAvailableFamilyMembers = storedAvailableFamilyMembers {
            return storedAvailableFamilyMembers
        }
        
        var availableFamilyMemberUserIds: Set<String> = []
        for dog in dogManager.dogs {
            if (filterDogs.count >= 1 && filterDogs.contains(where: {$0.dogId == dog.dogId}) == false) {
                // We are filtering by dogs and this is not one of them, therefore, this dog is no available
                continue
            }
            
            for log in dog.dogLogs.logs {
                if (filterLogActions.count >= 1 && filterLogActions.contains(where: { $0 == log.logAction}) == false) {
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
    
    // MARK: - Main
    
    init(forDogManager: DogManager) {
        super.init()
        apply(forDogManager: dogManager)
    }
    
    func apply(forDogManager: DogManager) {
        dogManager = forDogManager
        apply(forFilterDogs: filterDogs)
        apply(forFilterLogActions: filterLogActions)
        apply(forFilterFamilyMembers: filterFamilyMembers)
    }
    
    /// If we want to apply a new filterDogs, then this may invalidate the other filters. This is because it could filter out logs that were previously included, making it impossible to filter by certain log actions or family members because therre are none
    func apply(forFilterDogs: [Dog]) {
        var includedLogActions: Set<LogAction> = []
        var includedFamilyMemberUserIds: Set<String> = []
        
        dogManager.dogs.forEach { dog in
            // Find all of the log actions and family members that are included
            // If forFilterDogs is empty, then include all of the dogs
            guard forFilterDogs.isEmpty || forFilterDogs.contains(where: { $0.dogId == dog.dogId }) else {
                return
            }
            
            dog.dogLogs.logs.forEach { log in
                includedLogActions.insert(log.logAction)
                includedFamilyMemberUserIds.insert(log.userId)
            }
        }
        
        // Keep all of the filter passed through by a parameter, but remove any elements from other filters that are incompatible with the new filter (i.e. they cannot exist as there is no element that would satify both of the conditions)
        filterDogs = forFilterDogs
        filterLogActions = filterLogActions.filter({ filterLogAction in
            return includedLogActions.contains(filterLogAction)
        })
        filterFamilyMembers = filterFamilyMembers.filter({ filterFamilyMember in
            return includedFamilyMemberUserIds.contains(filterFamilyMember.userId)
        })
        
        display()
    }
    
    /// If we want to apply a new filterLogActions, then this may invalidate the other filters. This is because it could filter out logs that were previously included, making it impossible to filter by certain dogs or family members because therre are none
    func apply(forFilterLogActions: [LogAction]) {
        var includedDogIds: Set<Int> = []
        var includedFamilyMemberUserIds: Set<String> = []
        
        dogManager.dogs.forEach { dog in
            // Find all of the dogs and family members that are included
            // If forFilterLogActions is empty, then include all of the dogs
            dog.dogLogs.logs.forEach { log in
                guard forFilterLogActions.isEmpty || forFilterLogActions.contains(log.logAction) else {
                    return
                }
                
                includedDogIds.insert(dog.dogId)
                includedFamilyMemberUserIds.insert(log.userId)
            }
        }
        
        // Keep all of the filter passed through by a parameter, but remove any elements from other filters that are incompatible with the new filter (i.e. they cannot exist as there is no element that would satify both of the conditions)
        filterDogs = filterDogs.filter({ filterDog in
            return includedDogIds.contains(filterDog.dogId)
        })
        
        filterLogActions = forFilterLogActions
        
        filterFamilyMembers = filterFamilyMembers.filter({ filterFamilyMember in
            return includedFamilyMemberUserIds.contains(filterFamilyMember.userId)
        })
        
        display()
    }
    
    /// If we want to apply a new filterFamilyMembers, then this may invalidate the other filters. This is because it could filter out logs that were previously included, making it impossible to filter by certain dogs or log actions because therre are none
    func apply(forFilterFamilyMembers: [FamilyMember]) {
        var includedDogIds: Set<Int> = []
        var includedLogActions: Set<LogAction> = []
        
        dogManager.dogs.forEach { dog in
            // Find all of the dogs and family members that are included
            // If forFilterFamilyMembers is empty, then include all of the family members
            dog.dogLogs.logs.forEach { log in
                guard forFilterFamilyMembers.isEmpty || forFilterFamilyMembers.contains(where: { $0.userId == log.userId}) else {
                    return
                }
                
                includedDogIds.insert(dog.dogId)
                includedLogActions.insert(log.logAction)
            }
        }
        
        // Keep all of the filter passed through by a parameter, but remove any elements from other filters that are incompatible with the new filter (i.e. they cannot exist as there is no element that would satify both of the conditions)
        filterDogs = filterDogs.filter({ filterDog in
            return includedDogIds.contains(filterDog.dogId)
        })
        
        filterLogActions = filterLogActions.filter({ filterLogAction in
            return includedLogActions.contains(filterLogAction)
        })
        
        filterFamilyMembers = forFilterFamilyMembers
        
        display()
    }
}
