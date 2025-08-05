//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO dogCreated, dogCreatedBy, dogLastModified, dogLastModifiedBy

final class Dog: NSObject, NSCoding, NSCopying, Comparable {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = try! Dog(forDogName: self.dogName) // swiftlint:disable:this force_try
        
        copy.dogId = self.dogId
        copy.dogUUID = self.dogUUID
        copy.dogName = self.dogName
        copy.dogIcon = self.dogIcon?.copy() as? UIImage
        copy.dogReminders = self.dogReminders.copy() as? DogReminderManager ?? DogReminderManager()
        copy.dogLogs = self.dogLogs.copy() as? DogLogManager ?? DogLogManager(forParentDog: nil)
        copy.dogLogs.parentDog = copy
        copy.dogTriggers = self.dogTriggers.copy() as? DogTriggerManager ?? DogTriggerManager()
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogId: Int? = aDecoder.decodeOptionalInteger(forKey: Constant.Key.dogId.rawValue)
        let decodedDogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeOptionalString(forKey: Constant.Key.dogUUID.rawValue))
        let decodedDogName: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.dogName.rawValue)
        let decodedDogReminders: DogReminderManager? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogReminders.rawValue)
        let decodedDogLogs: DogLogManager? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogLogs.rawValue)
        let decodedDogTriggers: DogTriggerManager? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogTriggers.rawValue)
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponents.rawValue)
        do {
            try self.init(
                forDogId: decodedDogId,
                forDogUUID: decodedDogUUID,
                forDogName: decodedDogName,
                forDogReminders: decodedDogReminders,
                forDogLogs: decodedDogLogs,
                forDogTriggers: decodedDogTriggers,
                offlineModeComponents: decodedOfflineModeComponents
            )
        }
        catch {
            // dogName made last init fail, so init without the dog name
            self.init(
                forDogId: decodedDogId,
                forDogUUID: decodedDogUUID,
                forDogReminders: decodedDogReminders,
                forDogLogs: decodedDogLogs,
                forDogTriggers: decodedDogTriggers,
                offlineModeComponents: decodedOfflineModeComponents
            )
        }
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let dogId = dogId {
            aCoder.encode(dogId, forKey: Constant.Key.dogId.rawValue)
        }
        aCoder.encode(dogUUID.uuidString, forKey: Constant.Key.dogUUID.rawValue)
        aCoder.encode(dogName, forKey: Constant.Key.dogName.rawValue)
        aCoder.encode(dogReminders, forKey: Constant.Key.dogReminders.rawValue)
        aCoder.encode(dogLogs, forKey: Constant.Key.dogLogs.rawValue)
        aCoder.encode(dogTriggers, forKey: Constant.Key.dogTriggers.rawValue)
        aCoder.encode(offlineModeComponents, forKey: Constant.Key.offlineModeComponents.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Dog, rhs: Dog) -> Bool {
        guard let lhsDogId = lhs.dogId else {
            guard rhs.dogId != nil else {
                // Neither have an id
                let compare = lhs.dogName.localizedCaseInsensitiveCompare(rhs.dogName)
                if compare == .orderedAscending {
                    return true
                }
                if compare == .orderedDescending {
                    return false
                }
                
                return lhs.dogUUID.uuidString < rhs.dogUUID.uuidString
            }
            
            // lhs doesn't have a dogId but rhs does. rhs should come first
            return false
        }
        
        guard let rhsDogId = rhs.dogId else {
            // lhs has a dogId but rhs doesn't. lhs should come first
            return true
        }
        
        return lhsDogId <= rhsDogId
    }
    
    // MARK: - Properties
    
    var dogId: Int?
    
    var dogUUID: UUID = UUID()
    
    var dogIcon: UIImage?
    
    private(set) var dogName: String = Constant.Class.Dog.defaultDogName
    
    /// DogReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    private(set) var dogReminders: DogReminderManager = DogReminderManager()
    
    /// DogLogManager that handles all the logs for a dog. forDelegate is set to nil, as it is set in the init method
    private(set) var dogLogs: DogLogManager = DogLogManager(forParentDog: nil)
    
    /// DogTriggerManager that handles all the dogTriggers for a dog
    private(set) var dogTriggers: DogTriggerManager = DogTriggerManager()
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        forDogId: Int? = nil,
        forDogUUID: UUID? = nil,
        forDogReminders: DogReminderManager? = nil,
        forDogLogs: DogLogManager? = nil,
        forDogTriggers: DogTriggerManager? = nil,
        offlineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.dogId = forDogId ?? dogId
        self.dogUUID = forDogUUID ?? dogUUID
        self.dogIcon = DogIconManager.getIcon(forDogUUID: dogUUID)
        self.dogReminders = forDogReminders ?? dogReminders
        self.dogLogs = forDogLogs ?? dogLogs
        self.dogLogs.parentDog = self
        self.dogTriggers = forDogTriggers ?? dogTriggers
        self.offlineModeComponents = offlineModeComponents ?? self.offlineModeComponents
    }
    
    convenience init(
        forDogId: Int? = nil,
        forDogUUID: UUID? = nil,
        forDogName: String? = nil,
        forDogReminders: DogReminderManager? = nil,
        forDogLogs: DogLogManager? = nil,
        forDogTriggers: DogTriggerManager? = nil,
        offlineModeComponents: OfflineModeComponents? = nil
    ) throws {
        self.init(forDogId: forDogId, forDogUUID: forDogUUID, forDogReminders: forDogReminders, forDogLogs: forDogLogs, forDogTriggers: forDogTriggers, offlineModeComponents: offlineModeComponents)
        changeDogName(forDogName: forDogName)
    }
    
    /// Provide a dictionary literal of dog properties to instantiate dog. Optionally, provide a dog to override with new properties from fromBody.
    convenience init?(fromBody: JSONResponseBody, dogToOverride: Dog?) {
        // Don't pull dogId or dogIsDeleted from dogToOverride. A valid fromBody needs to provide this itself
        let dogId: Int? = fromBody[Constant.Key.dogId.rawValue] as? Int
        let dogUUID: UUID? = UUID.fromString(forUUIDString: fromBody[Constant.Key.dogUUID.rawValue] as? String)
        let dogLastModified: Date? = (fromBody[Constant.Key.dogLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let dogIsDeleted: Bool? = fromBody[Constant.Key.dogIsDeleted.rawValue] as? Bool
        
        // The body needs an id, uuid, and isDeleted to be intrepreted as same, updated, or deleted. Otherwise, it is invalid
        guard let dogId = dogId, let dogUUID = dogUUID, let dogLastModified = dogLastModified, let dogIsDeleted = dogIsDeleted else {
            return nil
        }
        
        guard dogIsDeleted == false else {
            // The dog has been deleted. Doesn't matter if our offline mode made any changes
            return nil
        }
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer update takes precedence over our update
        if let dogToOverride = dogToOverride, let initialAttemptedSyncDate = dogToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= dogLastModified {
            do {
                try self.init(
                    forDogId: dogToOverride.dogId,
                    forDogUUID: dogToOverride.dogUUID,
                    forDogName: dogToOverride.dogName,
                    forDogReminders: dogToOverride.dogReminders,
                    forDogLogs: dogToOverride.dogLogs,
                    forDogTriggers: dogToOverride.dogTriggers,
                    // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
                    offlineModeComponents: nil
                )
            }
            catch {
                // dogName made last init fail, so init without the dog name
                self.init(
                    forDogId: dogToOverride.dogId,
                    forDogUUID: dogToOverride.dogUUID,
                    forDogReminders: dogToOverride.dogReminders,
                    forDogLogs: dogToOverride.dogLogs,
                    forDogTriggers: dogToOverride.dogTriggers,
                    // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
                    offlineModeComponents: nil
                )
            }
            return
        }
        
        // if the dog is the same, then we pull values from dogToOverride
        // if the dog is updated, then we pull values from fromBody
        let dogName: String? = fromBody[Constant.Key.dogName.rawValue] as? String ?? dogToOverride?.dogName
        
        let dogReminders: DogReminderManager? = {
            guard let reminderBodies = fromBody[Constant.Key.dogReminders.rawValue] as? [JSONResponseBody] else {
                return nil
            }
            
            return DogReminderManager(fromReminderBodies: reminderBodies, dogReminderManagerToOverride: dogToOverride?.dogReminders)
        }()
        
        let dogLogs: DogLogManager? = {
            guard let logBodies = fromBody[Constant.Key.dogLogs.rawValue] as? [JSONResponseBody] else {
                return nil
            }
            
            // forDelegate is set to nil, as it is set in the init method
            return DogLogManager(fromLogBodies: logBodies, dogLogManagerToOverride: dogToOverride?.dogLogs, forParentDog: nil)
        }()
        
        let dogTriggers: DogTriggerManager? = {
            guard let triggerBodies = fromBody[Constant.Key.dogTriggers.rawValue] as? [JSONResponseBody] else {
                return nil
            }
            
            return DogTriggerManager(fromTriggerBodies: triggerBodies, dogTriggerManagerToOverride: dogToOverride?.dogTriggers)
        }()
        
        do {
            try self.init(
                forDogId: dogId,
                forDogUUID: dogUUID,
                forDogName: dogName,
                forDogReminders: dogReminders,
                forDogLogs: dogLogs,
                forDogTriggers: dogTriggers,
                // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
                offlineModeComponents: nil
            )
        }
        catch {
            // dogName made last init fail, so init without the dog name
            self.init(
                forDogId: dogId,
                forDogUUID: dogUUID,
                forDogReminders: dogReminders,
                forDogLogs: dogLogs,
                forDogTriggers: dogTriggers,
                // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
                offlineModeComponents: nil
            )
        }
        
    }
    
    // MARK: - Function
    
    @discardableResult
    func changeDogName(forDogName: String?) -> Bool {
        guard let forDogName = forDogName, forDogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return false
        }
        
        dogName = String(forDogName.prefix(Constant.Class.Dog.dogNameCharacterLimit))
        return true
    }
    
    /// For a given logActionType and logCustomActionName, finds all enabled reminders that match these two properties. We attempt to translate LogActionType into ReminderActionType, but that can possibly fail, as the mapping isn't 1:1 (some LogActionTypes have no corresponding ReminderActionType), therefore in that case we return nothing
    func matchingReminders(forLogActionType: LogActionType, forLogCustomActionName: String?) -> [Reminder] {
        // Must have a reminder action and our conversion failed as no corresponding reminderActionType exists for the logActionType
        guard let associatedReminderActionType = forLogActionType.associatedReminderActionType else {
            return []
        }
        
        let matchingReminders = dogReminders.dogReminders.filter { dogReminder in
            guard dogReminder.reminderIsEnabled == true else {
                // Reminder needs to be enabled to be considered
                return false
            }
            
            guard dogReminder.reminderActionTypeId == associatedReminderActionType.reminderActionTypeId else {
                // Both reminderActionTypes need to match
                return false
            }
            
            // If the reminderActionType can have customActionName, then the customActionName need to also match.
            return associatedReminderActionType.allowsCustom == false
            || (dogReminder.reminderCustomActionName == forLogCustomActionName)
        }
        
        return matchingReminders
    }
    
    /// Returns an array literal of the dog's properties (does not include nested properties, e.g. logs or reminders). This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> JSONRequestBody {
        var body: JSONRequestBody = [:]
        body[Constant.Key.dogId.rawValue] = .int(dogId)
        body[Constant.Key.dogUUID.rawValue] = .string(dogUUID.uuidString)
        body[Constant.Key.dogName.rawValue] = .string(dogName)
        return body
    }
}
