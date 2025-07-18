//
//  DogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/21/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = DogManager()
        for dog in dogs {
            if let dogCopy = dog.copy() as? Dog {
                copy.dogs.append(dogCopy)
            }
        }
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        let decodedDogs: [Dog]? = aDecoder.decodeOptionalObject(forKey: KeyConstant.dogs.rawValue)
        dogs = decodedDogs ?? dogs
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogs, forKey: KeyConstant.dogs.rawValue)
    }
    
    // MARK: - Properties
    
    /// This dogManager is typically used for persistence. If we are passing a dogManager through area of code not easily navigated by view controllers
    static var globalDogManager: DogManager?
    
    /// Stores all the dogs. This is get only to make sure integrite of dogs added is kept
    private(set) var dogs: [Dog] = []
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    /// initializes, sets dogs to []
    /// Provide an array of dictionary literal of dog properties to instantiate dogs. Provide a dogManager to have the dogs add themselves into, update themselves in, or delete themselves from.
    convenience init?(fromDogBodies: [JSONResponseBody], dogManagerToOverride: DogManager?) {
        self.init()
        self.addDogs(forDogs: dogManagerToOverride?.dogs ?? [])
        
        for fromBody in fromDogBodies {
            // Don't pull these properties from overrideDog. A valid fromBody needs to provide this itself
            let dogId: Int? = fromBody[KeyConstant.dogId.rawValue] as? Int
            let dogUUID: UUID? = UUID.fromString(forUUIDString: fromBody[KeyConstant.dogUUID.rawValue] as? String)
            let dogIsDeleted: Bool? = fromBody[KeyConstant.dogIsDeleted.rawValue] as? Bool
            
            guard dogId != nil, let dogUUID = dogUUID, let dogIsDeleted = dogIsDeleted else {
                // couldn't construct essential components to intrepret dog
                continue
            }
            
            guard dogIsDeleted == false else {
                DogIconManager.removeIcon(forDogUUID: dogUUID)
                removeDog(forDogUUID: dogUUID)
                continue
            }
            
            if let dog = Dog(fromBody: fromBody, dogToOverride: findDog(forDogUUID: dogUUID)) {
                addDog(forDog: dog)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns true if ANY the dogs present has at least 1 CREATED reminder
    var hasCreatedReminder: Bool {
        for dog in dogs where dog.dogReminders.dogReminders.isEmpty == false {
            return true
        }
        return false
    }
    
    // MARK: - Functions
    
    /// Returns reference of a dog with the given dogUUID
    func findDog(forDogUUID: UUID) -> Dog? {
        dogs.first(where: { $0.dogUUID == forDogUUID })
    }
    
    /// Helper function allows us to use the same logic for addDog and addDogs and allows us to only sort at the end. Without this function, addDogs would invoke addDog repeadly and sortDogs() with each call.
    func addDogWithoutSorting(forDog: Dog) {
        
        // removes any existing dogs that have the same dogUUID as they would cause problems.
        dogs.removeAll { dog in
            return dog.dogUUID == forDog.dogUUID
        }
        
        dogs.append(forDog)
    }
    
    /// Checks to see if a dog is already present. If its dogUUID is, then is removes the old dog and replaces it with the new.
    func addDog(forDog dog: Dog) {
        
        addDogWithoutSorting(forDog: dog)
        
        dogs.sort(by: { $0 <= $1 })
    }
    
    /// Adds array of dogs with addDog(forDog: Dog) repition  (but only sorts once at the end to be more efficent)
    func addDogs(forDogs: [Dog]) {
        for dog in forDogs {
            addDogWithoutSorting(forDog: dog)
        }
        
        dogs.sort(by: { $0 <= $1 })
    }
    
    /// Returns true if it removed at least one dog with the same dogUUID
    @discardableResult func removeDog(forDogUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        dogs.removeAll { dog in
            guard dog.dogUUID == forDogUUID else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
    
    /// Returns an array of tuples [[(dogUUID, log)]]. This array has all of the logs for all of the dogs grouped what unique day/month/year they occured on, first element is furthest in the future and last element is the oldest.
    func logsForDogUUIDsGroupedByDate(forFilter: LogsFilter) -> [[(UUID, Log)]] {
        var dogUUIDLogPairs: [(UUID, Log)] = []
        
        for dog in dogs {
            if forFilter.filteredDogsUUIDs.count >= 1 && forFilter.filteredDogsUUIDs.contains(dog.dogUUID) == false {
                // We are filtering by dogs and this is not one of them, therefore, this dog is no available
                continue
            }
            
            var numberOfLogsAdded = 0
            for log in dog.dogLogs.dogLogs {
                // in total, we can only have maximumNumberOfLogs. This means that 1/2 of that limit could be from one dog, 1/4 from second dog, and 1/4 from a third dog OR all of that limit could be from one dog. Therefore, we must add maximumNumberOfLogs of logs for each dog, then eliminate excess at a later stage
                guard numberOfLogsAdded <= LogsTableVC.logsDisplayedLimit else {
                    break
                }
                
                if forFilter.filteredLogActionActionTypeIds.count >= 1 && forFilter.filteredLogActionActionTypeIds.contains(log.logActionTypeId) == false {
                    // We are filtering by log actions and this is not one of them, therefore, this log action is not available
                    continue
                }
                if forFilter.filteredFamilyMemberUserIds.count >= 1 && forFilter.filteredFamilyMemberUserIds.contains(log.userId) == false {
                    // We are filtering by family members and this is not one of them, therefore, this family member is no available
                    continue
                }
                if forFilter.isStartDateEnabled,
                   let startDate = forFilter.startDate,
                   log.logStartDate < startDate {
                    continue
                }
                if forFilter.isEndDateEnabled, let endDate = forFilter.endDate, let logEndDate = log.logEndDate, logEndDate > endDate {
                    continue
                }
                if forFilter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
                    log.matchesSearchText(forFilter.searchText) == false {
                    // Search text provided but log doesn't match it
                    continue
                }
                
                dogUUIDLogPairs.append((dog.dogUUID, log))
                numberOfLogsAdded += 1
            }
        }
        
        dogUUIDLogPairs.sort(by: { $0.1 <= $1.1 })
        
        // Splice the chronologically sorted array so that it doesn't exceed maximumNumberOfLogs elements. This will be the maximumNumberOfLogs most recent logs as the array is sorted chronologically
        dogUUIDLogPairs = dogUUIDLogPairs.count > LogsTableVC.logsDisplayedLimit
        ? Array(dogUUIDLogPairs[..<LogsTableVC.logsDisplayedLimit])
        : dogUUIDLogPairs
        
        // dogUUIDLogPairs grouped separated into different array element depending on their day, month, and year
        var logsForDogUUIDsGroupedByDate: [[(UUID, Log)]] = []
        
        // we will be going from oldest logs to newest logs (by logStartDate)
        for (dogUUID, log) in dogUUIDLogPairs {
            let logDay = Calendar.current.component(.day, from: log.logStartDate)
            let logMonth = Calendar.current.component(.month, from: log.logStartDate)
            let logYear = Calendar.current.component(.year, from: log.logStartDate)
            
            let containsDateCombination = {
                // dogUUIDLogPairs is sorted chronologically, which means everything is added in chronological order to logsForDogUUIDsGroupedByDate.
                guard let lastDateGroup = logsForDogUUIDsGroupedByDate.last, let (_, logFromLastDateGroup) = lastDateGroup.last else {
                    return false
                }
                
                let lastDay = Calendar.current.component(.day, from: logFromLastDateGroup.logStartDate)
                let lastMonth = Calendar.current.component(.month, from: logFromLastDateGroup.logStartDate)
                let lastYear = Calendar.current.component(.year, from: logFromLastDateGroup.logStartDate)
                
                // check to see if that day, month, year comboination is already present
                return lastDay == logDay && lastMonth == logMonth && lastYear == logYear
            }()
            
            if containsDateCombination {
                // there is already a tuple with the same day, month, and year, so we want to add this dogUUID/log combo to the array attached to that tuple
                logsForDogUUIDsGroupedByDate[logsForDogUUIDsGroupedByDate.count - 1].append((dogUUID, log))
            }
            else {
                // in the master array, there is not a matching tuple with the specified day, month, and year, so we should add an element that contains the day, month, and year plus this log since its logStartDate is on this day, month, and year
                logsForDogUUIDsGroupedByDate.append(([(dogUUID, log)]))
            }
        }
        
        return logsForDogUUIDsGroupedByDate
    }
    
    /// Iterates through all dogs for a given array of dogUUIDs. Finds all reminders for each of those dogs where the reminder is enabled, its reminderActionType matches, and its reminderCustomActionName matches.
    func matchingReminders(forDogUUIDs: [UUID], forLogActionType: LogActionType, forLogCustomActionName: String?) -> [(UUID, Reminder)] {
        var allMatchingReminders: [(UUID, Reminder)] = []
        
        // Find the dogs that are currently selected
        let dogs = dogs.filter { dog in
            forDogUUIDs.contains(dog.dogUUID)
        }
        
        // Search through all of the dogs currently selected. For each dog, find the matching reminders
        for dog in dogs {
            let matchingReminders = dog.matchingReminders(forLogActionType: forLogActionType, forLogCustomActionName: forLogCustomActionName)
            
            // We found any reminders that match, map them with their dogUUID to return them
            allMatchingReminders += matchingReminders.map({ reminder in
                (dog.dogUUID, reminder)
            })
        }
        
        return allMatchingReminders
    }
}
