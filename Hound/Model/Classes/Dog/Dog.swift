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
        let copy = try! Dog(forDogName: self.dogName) // swiftlint:disable:this force_try
        
        copy.dogId = self.dogId
        copy.dogUUID = self.dogUUID
        copy.dogName = self.dogName
        copy.dogIcon = self.dogIcon?.copy() as? UIImage
        copy.dogReminders = self.dogReminders.copy() as? DogReminderManager ?? DogReminderManager()
        copy.dogLogs = self.dogLogs.copy() as? DogLogManager ?? DogLogManager()
        copy.offlineSyncComponents = self.offlineSyncComponents.copy() as? OfflineSyncComponents ?? OfflineSyncComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogId: Int? = aDecoder.decodeInteger(forKey: KeyConstant.dogId.rawValue)
        let decodedDogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.dogUUID.rawValue) as? String)
        let decodedDogName = aDecoder.decodeObject(forKey: KeyConstant.dogName.rawValue) as? String
        let decodedDogReminders = aDecoder.decodeObject(forKey: KeyConstant.dogReminders.rawValue) as? DogReminderManager
        let decodedDogLogs = aDecoder.decodeObject(forKey: KeyConstant.dogLogs.rawValue) as? DogLogManager
        let decodedOfflineSyncComponents = aDecoder.decodeObject(forKey: KeyConstant.offlineSyncComponents.rawValue) as? OfflineSyncComponents
        
        do {
            try self.init(
                forDogId: decodedDogId,
                forDogUUID: decodedDogUUID,
                forDogName: decodedDogName,
                forDogReminders: decodedDogReminders,
                forDogLogs: decodedDogLogs,
                forOfflineSyncComponents: decodedOfflineSyncComponents
            )
        }
        catch {
            try! self.init( // swiftlint:disable:this force_try
                forDogId: decodedDogId,
                forDogUUID: decodedDogUUID,
                forDogName: ClassConstant.DogConstant.defaultDogName,
                forDogReminders: decodedDogReminders,
                forDogLogs: decodedDogLogs,
                forOfflineSyncComponents: decodedOfflineSyncComponents
            )
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: KeyConstant.dogId.rawValue)
        aCoder.encode(dogUUID.uuidString, forKey: KeyConstant.dogUUID.rawValue)
        aCoder.encode(dogName, forKey: KeyConstant.dogName.rawValue)
        aCoder.encode(dogReminders, forKey: KeyConstant.dogReminders.rawValue)
        aCoder.encode(dogLogs, forKey: KeyConstant.dogLogs.rawValue)
        aCoder.encode(offlineSyncComponents, forKey: KeyConstant.offlineSyncComponents.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Dog, rhs: Dog) -> Bool {
        guard let lhsDogId = lhs.dogId else {
            guard let rhsDogId = rhs.dogId else {
                // neither lhs nor rhs has a dogId. The one that was created first should come first
                return lhs.offlineSyncComponents.initialCreationDate.distance(to: rhs.offlineSyncComponents.initialCreationDate) <= 0
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
    
    private(set) var dogName: String = ClassConstant.DogConstant.defaultDogName
    func changeDogName(forDogName: String?) throws {
        guard let forDogName = forDogName, forDogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ErrorConstant.DogError.dogNameMissing()
        }
        
        dogName = String(forDogName.prefix(ClassConstant.DogConstant.dogNameCharacterLimit))
    }
    
    /// DogReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    private(set) var dogReminders: DogReminderManager = DogReminderManager()
    
    /// DogLogManager that handles all the logs for a dog
    private(set) var dogLogs: DogLogManager = DogLogManager()
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineSyncComponents: OfflineSyncComponents = OfflineSyncComponents()
    
    // MARK: - Main
    
    init(
        forDogId: Int? = nil,
        forDogUUID: UUID? = nil,
        forDogName: String? = nil,
        forDogReminders: DogReminderManager? = nil,
        forDogLogs: DogLogManager? = nil,
        forOfflineSyncComponents: OfflineSyncComponents? = nil
    ) throws {
        super.init()
        self.dogId = forDogId ?? dogId
        self.dogUUID = forDogUUID ?? dogUUID
        self.dogIcon = DogIconManager.getIcon(forDogUUID: dogUUID)
        try changeDogName(forDogName: forDogName)
        self.dogReminders = forDogReminders ?? dogReminders
        self.dogLogs = forDogLogs ?? dogLogs
        self.offlineSyncComponents = forOfflineSyncComponents ?? offlineSyncComponents
    }
    
    /// Provide a dictionary literal of dog properties to instantiate dog. Optionally, provide a dog to override with new properties from dogBody.
    convenience init?(forDogBody dogBody: [String: PrimativeTypeProtocol?], overrideDog: Dog?) {
        // Don't pull dogId or dogIsDeleted from overrideDog. A valid dogBody needs to provide this itself
        let dogId: Int? = dogBody[KeyConstant.dogId.rawValue] as? Int
        let dogUUID: UUID? = UUID.fromString(forUUIDString: dogBody[KeyConstant.dogUUID.rawValue] as? String)
        let dogIsDeleted: Bool? = dogBody[KeyConstant.dogIsDeleted.rawValue] as? Bool
        
        // The body needs an id, uuid, and isDeleted to be intrepreted as same, updated, or deleted. Otherwise, it is invalid
        guard let dogId = dogId, let dogUUID = dogUUID, let dogIsDeleted = dogIsDeleted else {
            return nil
        }
        
        guard dogIsDeleted == false else {
            return nil
        }
        
        // if the dog is the same, then we pull values from overrideDog
        // if the dog is updated, then we pull values from dogBody
        let dogName: String? = dogBody[KeyConstant.dogName.rawValue] as? String ?? overrideDog?.dogName
        
        let dogReminders: DogReminderManager? = {
            guard let reminderBodies = dogBody[KeyConstant.reminders.rawValue] as? [[String: PrimativeTypeProtocol?]] else {
                return nil
            }
            
            return DogReminderManager(fromReminderBodies: reminderBodies, overrideDogReminderManager: overrideDog?.dogReminders)
        }()
        
        let dogLogs: DogLogManager? = {
            guard let logBodies = dogBody[KeyConstant.logs.rawValue] as? [[String: PrimativeTypeProtocol?]] else {
                return nil
            }
            
            return DogLogManager(fromLogBodies: logBodies, overrideDogLogManager: overrideDog?.dogLogs)
        }()
        
        do {
            try self.init(
                forDogId: dogId,
                forDogUUID: dogUUID,
                forDogName: dogName,
                forDogReminders: dogReminders,
                forDogLogs: dogLogs,
                forOfflineSyncComponents: nil
            )
        }
        catch {
            // swiftlint:disable:next force_try
            try! self.init(
                forDogId: dogId,
                forDogUUID: dogUUID,
                forDogName: ClassConstant.DogConstant.defaultDogName,
                forDogReminders: dogReminders,
                forDogLogs: dogLogs,
                forOfflineSyncComponents: nil
            )
        }
        
    }
}

extension Dog {
    // MARK: General
    
    /// For a given logAction and logCustomActionName, finds all enabled reminders that match these two properties. We attempt to translate LogAction into ReminderAction, but that can possibly fail, as the mapping isn't 1:1 (some LogActions have no corresponding ReminderAction), therefore in that case we return nothing
    func matchingReminders(forLogAction: LogAction, forLogCustomActionName: String?) -> [Reminder] {
        // Must have a reminder action and our conversion failed as no corresponding reminderAction exists for the logAction
        guard let reminderAction = forLogAction.matchingReminderAction else {
            return []
        }
        
        let matchingReminders = dogReminders.reminders.filter { dogReminder in
            guard dogReminder.reminderIsEnabled == true else {
                // Reminder needs to be enabled to be considered
                return false
            }
            
            guard dogReminder.reminderAction == reminderAction else {
                // Both reminderActions need to match
                return false
            }
            
            // If the reminderAction can have customActionName, then the customActionName need to also match.
            return (dogReminder.reminderAction != .medicine && dogReminder.reminderAction != .custom)
            || (dogReminder.reminderCustomActionName == forLogCustomActionName)
        }
        
        return matchingReminders
    }
    
    // MARK: Request
    /// Returns an array literal of the dog's properties (does not include nested properties, e.g. logs or reminders). This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: PrimativeTypeProtocol?] {
        var body: [String: PrimativeTypeProtocol?] = [:]
        body[KeyConstant.dogUUID.rawValue] = dogUUID.uuidString
        body[KeyConstant.dogName.rawValue] = dogName
        return body
    }
}
