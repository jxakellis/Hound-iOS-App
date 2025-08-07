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
        let decodedDogs: [Dog]? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogs.rawValue)
        dogs = decodedDogs ?? dogs
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogs, forKey: Constant.Key.dogs.rawValue)
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
        self.addDogs(dogs: dogManagerToOverride?.dogs ?? [])
        
        for fromBody in fromDogBodies {
            // Don't pull these properties from overrideDog. A valid fromBody needs to provide this itself
            let dogId: Int? = fromBody[Constant.Key.dogId.rawValue] as? Int
            let dogUUID: UUID? = UUID.fromString(UUIDString: fromBody[Constant.Key.dogUUID.rawValue] as? String)
            let dogIsDeleted: Bool? = fromBody[Constant.Key.dogIsDeleted.rawValue] as? Bool
            
            guard dogId != nil, let dogUUID = dogUUID, let dogIsDeleted = dogIsDeleted else {
                // couldn't construct essential components to intrepret dog
                continue
            }
            
            guard dogIsDeleted == false else {
                DogIconManager.removeIcon(dogUUID: dogUUID)
                removeDog(dogUUID: dogUUID)
                continue
            }
            
            if let dog = Dog(fromBody: fromBody, dogToOverride: findDog(dogUUID: dogUUID)) {
                addDog(dog: dog)
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
    func findDog(dogUUID: UUID) -> Dog? {
        dogs.first(where: { $0.dogUUID == dogUUID })
    }
    
    /// Helper function allows us to use the same logic for addDog and addDogs and allows us to only sort at the end. Without this function, addDogs would invoke addDog repeadly and sortDogs() with each call.
    func addDogWithoutSorting(dog: Dog) {
        
        // removes any existing dogs that have the same dogUUID as they would cause problems.
        dogs.removeAll { d in
            return d.dogUUID == dog.dogUUID
        }
        
        dogs.append(dog)
    }
    
    /// Checks to see if a dog is already present. If its dogUUID is, then is removes the old dog and replaces it with the new.
    func addDog(dog: Dog) {
        
        addDogWithoutSorting(dog: dog)
        
        dogs.sort(by: { $0 <= $1 })
    }
    
    /// Adds array of dogs with addDog(dog: Dog) repition  (but only sorts once at the end to be more efficent)
    func addDogs(dogs: [Dog]) {
        for dog in dogs {
            addDogWithoutSorting(dog: dog)
        }
        
        self.dogs.sort(by: { $0 <= $1 })
    }
    
    /// Returns true if it removed at least one dog with the same dogUUID
    @discardableResult func removeDog(dogUUID: UUID) -> Bool {
        var didRemoveObject = false
        
        dogs.removeAll { d in
            guard d.dogUUID == dogUUID else {
                return false
            }
            
            didRemoveObject = true
            return true
        }
        
        return didRemoveObject
    }
    
    /// Returns an array of tuples [[(dogUUID, log)]]. This array has all of the logs for all of the dogs grouped by the unique day/month/year they occurred on.
    ///
    /// The previous implementation collected every matching log and performed an additional sort before grouping. For large
    /// datasets this required sorting many more elements than were ultimately displayed. The logic below performs a k-way
    /// merge across each dog's already‑sorted logs and only materializes up to `limit` entries. This
    /// drastically reduces the amount of work when the total log count is high while keeping the result deterministic and
    /// free of cache invalidation concerns.
    func allLogsGroupedByDate(filter: LogsFilter, sort: LogsSort, limit: Int) -> [[(UUID, Log)]] {
        // Prepare sequences of sorted logs for all dogs that pass the dog filter
        typealias DogLogSequence = (uuid: UUID, logs: [Log], index: Int)
        var sequences: [DogLogSequence] = []

        for dog in dogs {
            if filter.filteredDogsUUIDs.isEmpty == false && filter.filteredDogsUUIDs.contains(dog.dogUUID) == false {
                continue
            }

            let sortedLogs = dog.dogLogs.sortedDogLogs(dateType: sort.dateType, sortDirection: sort.sortDirection)
            sequences.append((uuid: dog.dogUUID, logs: sortedLogs, index: 0))
        }

        // Helper to evaluate whether a log passes all of the provided filters
        func logPassesFilter(_ log: Log) -> Bool {
            if filter.filteredLogActionActionTypeIds.isEmpty == false &&
                filter.filteredLogActionActionTypeIds.contains(log.logActionTypeId) == false {
                return false
            }

            if filter.filteredFamilyMemberUserIds.isEmpty == false &&
                filter.filteredFamilyMemberUserIds.contains(log.logCreatedBy) == false {
                return false
            }

            if let timeRangeField = filter.timeRangeField {
                if filter.isFromDateEnabled, let fromDate = filter.timeRangeFromDate,
                   timeRangeField.dateForDateType(log) <= fromDate { return false }

                if filter.isToDateEnabled, let toDate = filter.timeRangeToDate,
                   timeRangeField.dateForDateType(log) >= toDate { return false }
            }
        
            if filter.searchText.isEmpty == false && log.matchesSearchText(filter.searchText) == false {
                return false
            }

            if filter.onlyShowMyLikes {
                guard let userId = UserInformation.userId, log.likedByUserIds.contains(userId) else { return false }
            }

            return true
        }

        // Merge sequences by repeatedly selecting the next log across all dogs
        var dogUUIDLogPairs: [(UUID, Log)] = []
        dogUUIDLogPairs.reserveCapacity(limit)

        // This loop performs a k-way merge across all dogs' sorted logs, only materializing up to the display limit.
        while dogUUIDLogPairs.count < limit {
            var bestSequenceIndex: Int?

            // Find the next "best" log among all dogs, according to the sort order
            for i in sequences.indices {
                // Advance each sequence to the next log that satisfies the filters
                while sequences[i].index < sequences[i].logs.count &&
                        logPassesFilter(sequences[i].logs[sequences[i].index]) == false {
                    sequences[i].index += 1
                }

                // If this sequence is exhausted, skip it
                guard sequences[i].index < sequences[i].logs.count else { continue }

                if let currentBest = bestSequenceIndex {
                    let currentBestLog = sequences[currentBest].logs[sequences[currentBest].index]
                    let candidateLog = sequences[i].logs[sequences[i].index]
                    // Compare logs using the requested sort field and direction
                    let comparison = sort.dateType.compare(lhs: candidateLog, rhs: currentBestLog)
                    let replace = sort.sortDirection == .ascending
                        ? (comparison == .orderedAscending)
                        : (comparison == .orderedDescending)
                    // First valid candidate found
                    if replace { bestSequenceIndex = i }
                }
                else {
                    bestSequenceIndex = i
                }
            }

            // If no more logs are available, break
            guard let sequenceIndex = bestSequenceIndex else { break }

            // Add the selected log to the result and advance its sequence
            let sequence = sequences[sequenceIndex]
            let log = sequence.logs[sequence.index]
            dogUUIDLogPairs.append((sequence.uuid, log))
            sequences[sequenceIndex].index += 1
        }

        // Group the chronologically ordered logs by day/month/year
        var allLogsGroupedByDate: [[(UUID, Log)]] = []

        for (dogUUID, log) in dogUUIDLogPairs {
            // If the last group is for the same day, append; otherwise, start a new group
            if let lastDateGroup = allLogsGroupedByDate.last,
               let (_, lastLog) = lastDateGroup.last,
               Calendar.user.isDate(sort.dateType.dateForDateType(log), inSameDayAs: sort.dateType.dateForDateType(lastLog)) {
                allLogsGroupedByDate[allLogsGroupedByDate.count - 1].append((dogUUID, log))
            }
            else {
                allLogsGroupedByDate.append([(dogUUID, log)])
            }
        }

        return allLogsGroupedByDate
    }
    
    /// Iterates through all dogs for a given array of dogUUIDs. Finds all reminders for each of those dogs where the reminder is enabled, its reminderActionType matches, and its reminderCustomActionName matches.
    func matchingReminders(dogUUIDs: [UUID], logActionType: LogActionType, logCustomActionName: String?) -> [(UUID, Reminder)] {
        var allMatchingReminders: [(UUID, Reminder)] = []
        
        // Find the dogs that are currently selected
        let dogs = dogs.filter { dog in
            dogUUIDs.contains(dog.dogUUID)
        }
        
        // Search through all of the dogs currently selected. For each dog, find the matching reminders
        for dog in dogs {
            let matchingReminders = dog.matchingReminders(logActionType: logActionType, logCustomActionName: logCustomActionName)
            
            // We found any reminders that match, map them with their dogUUID to return them
            allMatchingReminders += matchingReminders.map({ reminder in
                (dog.dogUUID, reminder)
            })
        }
        
        return allMatchingReminders
    }
}
