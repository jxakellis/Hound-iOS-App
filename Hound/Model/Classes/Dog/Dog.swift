//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Dog: NSObject, NSCoding, NSCopying, Comparable {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dog()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.dogId = self.dogId
        copy.dogUUID = self.dogUUID
        copy.dogName = self.dogName
        copy.dogCreated = self.dogCreated
        copy.dogCreatedBy = self.dogCreatedBy
        copy.dogLastModified = self.dogLastModified
        copy.dogLastModifiedBy = self.dogLastModifiedBy
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
        let decodedDogCreated: Date? = (aDecoder.decodeOptionalString(forKey: Constant.Key.dogCreated.rawValue)?.formatISO8601IntoDate())
        let decodedDogCreatedBy: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.dogCreatedBy.rawValue) ?? Constant.Class.Log.defaultUserId
        let decodedDogLastModified: Date? = (aDecoder.decodeOptionalString(forKey: Constant.Key.dogLastModified.rawValue)?.formatISO8601IntoDate())
        let decodedDogLastModifiedBy: String? = aDecoder.decodeOptionalString(forKey: Constant.Key.dogLastModifiedBy.rawValue)
        let decodedDogReminders: DogReminderManager? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogReminders.rawValue)
        let decodedDogLogs: DogLogManager? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogLogs.rawValue)
        let decodedDogTriggers: DogTriggerManager? = aDecoder.decodeOptionalObject(forKey: Constant.Key.dogTriggers.rawValue)
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponents.rawValue)
        self.init(
            dogId: decodedDogId,
            dogUUID: decodedDogUUID,
            dogName: decodedDogName,
            dogCreated: decodedDogCreated,
            dogCreatedBy: decodedDogCreatedBy,
            dogLastModified: decodedDogLastModified,
            dogLastModifiedBy: decodedDogLastModifiedBy,
            dogReminders: decodedDogReminders,
            dogLogs: decodedDogLogs,
            dogTriggers: decodedDogTriggers,
            offlineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let dogId = dogId {
            aCoder.encode(dogId, forKey: Constant.Key.dogId.rawValue)
        }
        aCoder.encode(dogUUID.uuidString, forKey: Constant.Key.dogUUID.rawValue)
        aCoder.encode(dogCreated.ISO8601FormatWithFractionalSeconds(), forKey: Constant.Key.dogCreated.rawValue)
        if let dogCreatedBy = dogCreatedBy {
            aCoder.encode(dogCreatedBy, forKey: Constant.Key.dogCreatedBy.rawValue)
        }
        if let dogLastModified = dogLastModified {
            aCoder.encode(dogLastModified.ISO8601FormatWithFractionalSeconds(), forKey: Constant.Key.dogLastModified.rawValue)
        }
        if let dogLastModifiedBy = dogLastModifiedBy {
            aCoder.encode(dogLastModifiedBy, forKey: Constant.Key.dogLastModifiedBy.rawValue)
        }
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

    private(set) var dogCreated: Date = Date()
    private(set) var dogCreatedBy: String? = Constant.Class.Log.defaultUserId
    private(set) var dogLastModified: Date?
    private(set) var dogLastModifiedBy: String?

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
        dogId: Int? = nil,
        dogUUID: UUID? = nil,
        dogName: String? = nil,
        dogCreated: Date? = nil,
        dogCreatedBy: String? = nil,
        dogLastModified: Date? = nil,
        dogLastModifiedBy: String? = nil,
        dogReminders: DogReminderManager? = nil,
        dogLogs: DogLogManager? = nil,
        dogTriggers: DogTriggerManager? = nil,
        offlineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.dogId = dogId ?? self.dogId
        self.dogUUID = dogUUID ?? self.dogUUID
        changeDogName(forDogName: dogName)
        self.dogCreated = dogCreated ?? self.dogCreated
        self.dogCreatedBy = dogCreatedBy ?? self.dogCreatedBy
        self.dogLastModified = dogLastModified ?? self.dogLastModified
        self.dogLastModifiedBy = dogLastModifiedBy ?? self.dogLastModifiedBy
        self.dogIcon = DogIconManager.getIcon(forDogUUID: dogUUID ?? self.dogUUID)
        self.dogReminders = dogReminders ?? self.dogReminders
        self.dogLogs = dogLogs ?? self.dogLogs
        self.dogLogs.parentDog = self
        self.dogTriggers = dogTriggers ?? self.dogTriggers
        self.offlineModeComponents = offlineModeComponents ?? self.offlineModeComponents
    }
    
    /// Provide a dictionary literal of dog properties to instantiate dog. Optionally, provide a dog to override with new properties from fromBody.
    convenience init?(fromBody: JSONResponseBody, dogToOverride: Dog?) {
        // Don't pull dogId or dogIsDeleted from dogToOverride. A valid fromBody needs to provide this itself
        let dogId: Int? = fromBody[Constant.Key.dogId.rawValue] as? Int
        let dogUUID: UUID? = UUID.fromString(forUUIDString: fromBody[Constant.Key.dogUUID.rawValue] as? String)
        let dogCreated: Date? = (fromBody[Constant.Key.dogCreated.rawValue] as? String)?.formatISO8601IntoDate()
        let dogIsDeleted: Bool? = fromBody[Constant.Key.dogIsDeleted.rawValue] as? Bool
        
        guard let dogId = dogId, let dogUUID = dogUUID, let dogCreated = dogCreated,  let dogIsDeleted = dogIsDeleted else {
            return nil
        }
        
        guard dogIsDeleted == false else {
            return nil
        }
        
        let dogLastModified: Date? = (fromBody[Constant.Key.dogLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer update takes precedence over our update
        if let dogToOverride = dogToOverride, let initialAttemptedSyncDate = dogToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= dogLastModified ?? dogCreated {
            self.init(
                dogId: dogToOverride.dogId,
                dogUUID: dogToOverride.dogUUID,
                dogName: dogToOverride.dogName,
                dogCreated: dogToOverride.dogCreated,
                dogCreatedBy: dogToOverride.dogCreatedBy,
                dogLastModified: dogToOverride.dogLastModified,
                dogLastModifiedBy: dogToOverride.dogLastModifiedBy,
                dogReminders: dogToOverride.dogReminders,
                dogLogs: dogToOverride.dogLogs,
                dogTriggers: dogToOverride.dogTriggers,
                offlineModeComponents: dogToOverride.offlineModeComponents
            )
            return
        }

        // if the dog is the same, then we pull values from dogToOverride
        // if the dog is updated, then we pull values from fromBody
        let dogCreatedBy: String? = fromBody[Constant.Key.dogCreatedBy.rawValue] as? String ?? dogToOverride?.dogCreatedBy
        let dogLastModifiedBy: String? = fromBody[Constant.Key.dogLastModifiedBy.rawValue] as? String ?? dogToOverride?.dogLastModifiedBy
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
        
        self.init(
            dogId: dogId,
            dogUUID: dogUUID,
            dogName: dogName,
            dogCreated: dogCreated,
            dogCreatedBy: dogCreatedBy,
            dogLastModified: dogLastModified,
            dogLastModifiedBy: dogLastModifiedBy,
            dogReminders: dogReminders,
            dogLogs: dogLogs,
            dogTriggers: dogTriggers,
            // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
            offlineModeComponents: nil
        )
        
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
        body[Constant.Key.dogCreated.rawValue] = .string(dogCreated.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.dogCreatedBy.rawValue] = .string(dogCreatedBy)
        body[Constant.Key.dogLastModified.rawValue] = .string(dogLastModified?.ISO8601FormatWithFractionalSeconds())
        body[Constant.Key.dogLastModifiedBy.rawValue] = .string(dogLastModifiedBy)
        return body
    }
}
