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
        copy.dogNeedsSyncedByOfflineManager = self.dogNeedsSyncedByOfflineManager
        copy.dogName = self.dogName
        copy.dogIcon = self.dogIcon?.copy() as? UIImage
        copy.dogReminders = self.dogReminders.copy() as? DogReminderManager ?? DogReminderManager()
        copy.dogLogs = self.dogLogs.copy() as? DogLogManager ?? DogLogManager()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogId: Int? = aDecoder.decodeInteger(forKey: KeyConstant.dogId.rawValue)
        let decodedDogUUID: UUID? = {
            guard let dogUUIDString = aDecoder.decodeObject(forKey: KeyConstant.dogUUID.rawValue) as? String else {
                return nil
            }
            
            return UUID(uuidString: dogUUIDString)
        }()
        let decodedDogNeedsSyncedByOfflineManager = aDecoder.decodeBool(forKey: KeyConstant.dogNeedsSyncedByOfflineManager.rawValue)
        let decodedDogName = aDecoder.decodeObject(forKey: KeyConstant.dogName.rawValue) as? String
        let decodedDogReminders = aDecoder.decodeObject(forKey: KeyConstant.dogReminders.rawValue) as? DogReminderManager
        let decodedDogLogs = aDecoder.decodeObject(forKey: KeyConstant.dogLogs.rawValue) as? DogLogManager
        
        do {
            try self.init(
                forDogId: decodedDogId,
                forDogUUID: decodedDogUUID,
                forDogNeedsSyncedByOfflineManager: decodedDogNeedsSyncedByOfflineManager,
                forDogName: decodedDogName,
                forDogReminders: decodedDogReminders,
                forDogLogs: decodedDogLogs
            )
        }
        catch {
            try! self.init(
                forDogId: decodedDogId,
                forDogUUID: decodedDogUUID,
                forDogNeedsSyncedByOfflineManager: decodedDogNeedsSyncedByOfflineManager,
                forDogName: dogName,
                forDogReminders: decodedDogReminders,
                forDogLogs: decodedDogLogs
            ) // swiftlint:disable:this force_try
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: KeyConstant.dogId.rawValue)
        aCoder.encode(dogUUID.uuidString, forKey: KeyConstant.dogUUID.rawValue)
        aCoder.encode(dogNeedsSyncedByOfflineManager, forKey: KeyConstant.dogNeedsSyncedByOfflineManager.rawValue)
        aCoder.encode(dogName, forKey: KeyConstant.dogName.rawValue)
        aCoder.encode(dogReminders, forKey: KeyConstant.dogReminders.rawValue)
        aCoder.encode(dogLogs, forKey: KeyConstant.dogLogs.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Dog, rhs: Dog) -> Bool {
        guard let lhsDogId = lhs.dogId else {
            guard let rhsDogId = rhs.dogId else {
                return lhs.dogUUID.uuidString <= rhs.dogUUID.uuidString
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
    
    /// This flag is false by default. It is updated to true when it is unsuccessfully synced with the server. If this flag is false, the offline manager will attempt to sync this object at a later date when connectivity is restored.
    var dogNeedsSyncedByOfflineManager: Bool = false
    
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
    
    // MARK: - Main
    
    init(
        forDogId: Int? = nil,
        forDogUUID: UUID? = nil,
        forDogNeedsSyncedByOfflineManager: Bool? = nil,
        forDogName: String? = nil,
        forDogReminders: DogReminderManager? = nil,
        forDogLogs: DogLogManager? = nil
    ) throws {
        self.dogId = forDogId ?? dogId
        self.dogUUID = forDogUUID ?? dogUUID
        self.dogNeedsSyncedByOfflineManager = forDogNeedsSyncedByOfflineManager ?? dogNeedsSyncedByOfflineManager
        self.dogIcon = DogIconManager.getIcon(forDogUUID: dogUUID)
        try changeDogName(forDogName: forDogName)
        self.dogReminders = forDogReminders ?? dogReminders
        self.dogLogs = forDogLogs ?? dogLogs
    }
    
    /// Provide a dictionary literal of dog properties to instantiate dog. Optionally, provide a dog to override with new properties from dogBody.
    convenience init?(forDogBody dogBody: [String: Any], overrideDog: Dog?) {
        // Don't pull dogId or dogIsDeleted from overrideDog. A valid dogBody needs to provide this itself
        let dogId: Int? = dogBody[KeyConstant.dogId.rawValue] as? Int
        let dogUUID: UUID? = {
            guard let uuidString = dogBody[KeyConstant.dogUUID.rawValue] as? String else {
                return nil
            }
            
            return UUID(uuidString: uuidString)
        }()
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
            guard let reminderBodies = dogBody[KeyConstant.reminders.rawValue] as? [[String: Any]] else {
                return nil
            }
            
            return DogReminderManager(fromReminderBodies: reminderBodies, overrideDogReminderManager: overrideDog?.dogReminders)
        }()
        
        let dogLogs: DogLogManager? = {
            guard let logBodies = dogBody[KeyConstant.logs.rawValue] as? [[String: Any]] else {
                return nil
            }
            
            return DogLogManager(fromLogBodies: logBodies, overrideDogLogManager: overrideDog?.dogLogs)
        }()
        
        do {
            try self.init(
                forDogId: dogId,
                forDogUUID: dogUUID,
                forDogNeedsSyncedByOfflineManager: nil,
                forDogName: dogName,
                forDogReminders: dogReminders,
                forDogLogs: dogLogs
            )
        }
        catch {
            try! self.init(
                forDogId: dogId,
                forDogUUID: dogUUID,
                forDogNeedsSyncedByOfflineManager: nil,
                forDogName: self.dogName,
                forDogReminders: dogReminders,
                forDogLogs: dogLogs
            ) // swiftlint:disable:this force_try
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
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.dogId.rawValue] = dogId
        body[KeyConstant.dogName.rawValue] = dogName
        return body
    }
}
