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
        dogs = aDecoder.decodeObject(forKey: KeyConstant.dogs.rawValue) as? [Dog] ?? dogs
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogs, forKey: KeyConstant.dogs.rawValue)
    }
    // MARK: - Properties
    
    /// Stores all the dogs. This is get only to make sure integrite of dogs added is kept
    private(set) var dogs: [Dog] = []
    
    /// Returns true if ANY the dogs present has at least 1 CREATED reminder
    var hasCreatedReminder: Bool {
        for dog in dogs where dog.dogReminders.reminders.isEmpty == false {
            return true
        }
        return false
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    /// initalizes, sets dogs to []
    /// Provide an array of dictionary literal of dog properties to instantiate dogs. Provide a dogManager to have the dogs add themselves into, update themselves in, or delete themselves from.
    convenience init?(forDogBodies dogBodies: [[String: Any]], overrideDogManager: DogManager?) {
        self.init()
        self.addDogs(forDogs: overrideDogManager?.dogs ?? [])
        
        for dogBody in dogBodies {
            // Don't pull dogId or dogIsDeleted from overrideDog. A valid dogBody needs to provide this itself
            let dogId: Int? = dogBody[KeyConstant.dogId.rawValue] as? Int
            let dogIsDeleted: Bool? = dogBody[KeyConstant.dogIsDeleted.rawValue] as? Bool
            
            guard let dogId = dogId, let dogIsDeleted = dogIsDeleted else {
                // couldn't construct essential components to intrepret dog
                continue
            }
            
            guard dogIsDeleted == false else {
                DogIconManager.removeIcon(forDogId: dogId)
                removeDog(forDogId: dogId)
                continue
            }
            
            if let dog = Dog(forDogBody: dogBody, overrideDog: findDog(forDogId: dogId)) {
                addDog(forDog: dog)
            }
        }
    }
    
    // MARK: - Functions
    
    /// Returns reference of a dog with the given dogId
    func findDog(forDogId dogId: Int) -> Dog? {
        return dogs.first(where: { $0.dogId == dogId })
    }
    
    /// Helper function allows us to use the same logic for addDog and addDogs and allows us to only sort at the end. Without this function, addDogs would invoke addDog repeadly and sortDogs() with each call.
    func addDogWithoutSorting(forDog newDog: Dog, shouldOverrideDogWithSamePlaceholderId: Bool) {
        
        // removes any existing dogs that have the same dogId as they would cause problems.
        dogs.removeAll { oldDog in
            guard oldDog.dogId == newDog.dogId else {
                return false
            }
            
            guard (shouldOverrideDogWithSamePlaceholderId == true) || (shouldOverrideDogWithSamePlaceholderId == false && oldDog.dogId >= 0) else {
                return false
            }
            
            oldDog.dogReminders.reminders.forEach { oldReminder in
                // check to see if the new dog has a corresponding old reminder
                guard let newReminder = newDog.dogReminders.findReminder(forReminderId: oldReminder.reminderId) else {
                    return
                }
                
                // if oldReminder's timers don't reference newReminder's timers, then oldReminder's timer is invalidated and removed.
                oldReminder.reminderAlarmTimer = newReminder.reminderAlarmTimer
                oldReminder.reminderDisableIsSkippingTimer = newReminder.reminderDisableIsSkippingTimer
            }
            
            return true
        }
        
        // check to see if we are dealing with a placeholder id dog
        if newDog.dogId < 0 {
            // If there are multiple dogs with placeholder ids, set the new dog's placeholder id to the lowest possible, therefore no overlap.
            var lowestDogId = Int.max
            dogs.forEach { dog in
                if dog.dogId < lowestDogId {
                    lowestDogId = dog.dogId
                }
            }
            
            // the lowest dog is is <0 so there are other placeholder dogs, that means we should set our new dog to a placeholder id that is 1 below the lowest (making this dog the new lowest)
            if lowestDogId < 0 {
                newDog.dogId = lowestDogId - 1
            }
        }
        
        dogs.append(newDog)
    }
    
    /// Checks to see if a dog is already present. If its dogId is, then is removes the old dog and replaces it with the new. However, if the dogs have placeholderIds and shouldOverrideDogWithSamePlaceholderId is false, then the newDog's placeholderId is shifted to a different placeholderId and both dogs are retained.
    func addDog(forDog dog: Dog, shouldOverrideDogWithSamePlaceholderId: Bool = false) {
        
        addDogWithoutSorting(forDog: dog, shouldOverrideDogWithSamePlaceholderId: shouldOverrideDogWithSamePlaceholderId)
        
        sortDogs()
    }
    
    /// Adds array of dogs with addDog(forDog: Dog) repition  (but only sorts once at the end to be more efficent)
    func addDogs(forDogs: [Dog]) {
        for dog in forDogs {
            addDogWithoutSorting(forDog: dog, shouldOverrideDogWithSamePlaceholderId: false)
        }
        
        sortDogs()
    }
    
    /// Sorts the dogs based upon their dogId
    private func sortDogs() {
        dogs.sort { dog1, dog2 in
            return dog1.dogId <= dog2.dogId
        }
    }
    
    /// Removes a dog with the given dogId
    func removeDog(forDogId dogId: Int) {
        
        // don't clearTimers() for reminders. we can't be sure what is invoking this function and we don't want to accidentily invalidate the timers. Therefore, leave the timers in place. If the timers are left over and after the dog/reminders are deleted, then they will fail the server query willShowAlarm and be disregarded. If the timers are still valid, then all continues as normal
        
        dogs.removeAll { dog in
            return dog.dogId == dogId
        }
    }
    
    /// Invokes clearTimers() for each reminder of each dog
    func clearTimers() {
        dogs.forEach { dog in
            dog.dogReminders.reminders.forEach { reminder in
                reminder.clearTimers()
            }
        }
    }
    
}

extension DogManager {
    
    /// Returns an array of tuples [[(dogId, log)]]. This array has all of the logs for all of the dogs grouped what unique day/month/year they occured on, first element is furthest in the future and last element is the oldest. Optionally filters by the dogId and logAction provides
    func logsForDogIdsGroupedByDate(forLogsFilter logsFilter: [Int: [LogAction]]) -> [[(Int, Log)]] {
        
        var dogIdLogPairs: [(Int, Log)] = []
        
        // no filter was provided, so we add all logs of all dogs
        if logsFilter.isEmpty {
            for dog in dogs {
                var numberOfLogsAdded = 0
                for log in dog.dogLogs.logs {
                    // in total, we can only have maximumNumberOfLogs. This means that 1/2 of that limit could be from one dog, 1/4 from second dog, and 1/4 from a third dog OR all of that limit could be from one dog. Therefore, we must add maximumNumberOfLogs of logs for each dog, then eliminate excess at a later stage
                    guard numberOfLogsAdded <= LogsTableViewController.logsDisplayedLimit else {
                        break
                    }
                    
                    dogIdLogPairs.append((dog.dogId, log))
                    numberOfLogsAdded += 1
                }
            }
        }
        // a filter was provided
        else {
            for dog in dogs {
                // We only want dogs that are specifide in the logsFilter
                guard let dogFilter = logsFilter[dog.dogId] else {
                    continue
                }
                var numberOfLogsAdded = 0
                for log in dog.dogLogs.logs {
                    // in total, we can only have maximumNumberOfLogs. This means that 1/2 of that limit could be from one dog, 1/4 from second dog, and 1/4 from a third dog OR all of that limit could be from one dog. Therefore, we must add maximumNumberOfLogs of logs for each dog, then eliminate excess at a later stage
                    guard numberOfLogsAdded <= LogsTableViewController.logsDisplayedLimit else {
                        break
                    }
                    
                    // the filter had the dogId stored, specifiying this dog, and had the logAction stored, specifying all logs of this logAction type. This means we can append the log
                    guard dogFilter.contains(log.logAction) else {
                        continue
                    }
                    
                    dogIdLogPairs.append((dog.dogId, log))
                    numberOfLogsAdded += 1
                }
            }
        }
        
        // Sort this array chronologically (newest at index 0)
        dogIdLogPairs.sort { tuple1, tuple2 in
            let (dogId1, log1) = tuple1
            let (dogId2, log2) = tuple2
            // If same logDate, then one with lesser dogId comes first
            guard log1.logDate != log2.logDate else {
                return dogId1 <= dogId2
            }
            
            // If the distance is less than zero, than means log1 is further in the future and log2 is further in the past
            return log1.logDate.distance(to: log2.logDate) <= 0
        }
        
        // Splice the chronologically sorted array so that it doesn't exceed maximumNumberOfLogs elements. This will be the maximumNumberOfLogs most recent logs as the array is sorted chronologically
        dogIdLogPairs = dogIdLogPairs.count > LogsTableViewController.logsDisplayedLimit
        ? Array(dogIdLogPairs[..<LogsTableViewController.logsDisplayedLimit])
        : dogIdLogPairs
        
        // dogIdLogPairs grouped separated into different array element depending on their day, month, and year
        var logsForDogIdsGroupedByDate: [[(Int, Log)]] = []
        
        // we will be going from oldest logs to newest logs (by logDate)
        for (dogId, log) in dogIdLogPairs {
            let logDay = Calendar.localCalendar.component(.day, from: log.logDate)
            let logMonth = Calendar.localCalendar.component(.month, from: log.logDate)
            let logYear = Calendar.localCalendar.component(.year, from: log.logDate)
            
            let containsDateCombination = {
                // dogIdLogPairs is sorted chronologically, which means everything is added in chronological order to logsForDogIdsGroupedByDate.
                guard let lastDateGroup = logsForDogIdsGroupedByDate.last, let (_, logFromLastDateGroup) = lastDateGroup.last else {
                    return false
                }
                
                let lastDay = Calendar.localCalendar.component(.day, from: logFromLastDateGroup.logDate)
                let lastMonth = Calendar.localCalendar.component(.month, from: logFromLastDateGroup.logDate)
                let lastYear = Calendar.localCalendar.component(.year, from: logFromLastDateGroup.logDate)
                
                // check to see if that day, month, year comboination is already present
                return lastDay == logDay && lastMonth == logMonth && lastYear == logYear
            }()
            
            // there is already a tuple with the same day, month, and year, so we want to add this dogId/log combo to the array attached to that tuple
            if containsDateCombination {
                logsForDogIdsGroupedByDate[logsForDogIdsGroupedByDate.count - 1].append((dogId, log))
                
            }
            // in the master array, there is not a matching tuple with the specified day, month, and year, so we should add an element that contains the day, month, and year plus this log since its logDate is on this day, month, and year
            else {
                logsForDogIdsGroupedByDate.append(([(dogId, log)]))
            }
        }
        
        return logsForDogIdsGroupedByDate
    }
}
