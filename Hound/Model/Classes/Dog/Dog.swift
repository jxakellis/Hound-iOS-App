//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Dog: NSObject, NSCoding, NSCopying, Comparable, DogLogManagerDelegate {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = try! Dog(forDogName: self.dogName) // swiftlint:disable:this force_try
        
        copy.dogId = self.dogId
        copy.dogUUID = self.dogUUID
        copy.dogName = self.dogName
        copy.dogIcon = self.dogIcon?.copy() as? UIImage
        copy.dogReminders = self.dogReminders.copy() as? DogReminderManager ?? DogReminderManager()
        copy.dogLogs = self.dogLogs.copy() as? DogLogManager ?? DogLogManager(forDelegate: nil)
        copy.dogLogs.delegate = self
        copy.dogTriggers = self.dogTriggers.copy() as? DogTriggerManager ?? DogTriggerManager()
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogId: Int? = aDecoder.decodeOptionalInteger(forKey: KeyConstant.dogId.rawValue)
        let decodedDogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeOptionalString(forKey: KeyConstant.dogUUID.rawValue))
        let decodedDogName: String? = aDecoder.decodeOptionalString(forKey: KeyConstant.dogName.rawValue)
        let decodedDogReminders: DogReminderManager? = aDecoder.decodeOptionalObject(forKey: KeyConstant.dogReminders.rawValue)
        let decodedDogLogs: DogLogManager? = aDecoder.decodeOptionalObject(forKey: KeyConstant.dogLogs.rawValue)
        let decodedDogTriggers: DogTriggerManager? = aDecoder.decodeOptionalObject(forKey: KeyConstant.dogTriggers.rawValue)
        let decodedOfflineModeComponents: OfflineModeComponents? = aDecoder.decodeOptionalObject(forKey: KeyConstant.offlineModeComponents.rawValue)
        do {
            try self.init(
                forDogId: decodedDogId,
                forDogUUID: decodedDogUUID,
                forDogName: decodedDogName,
                forDogReminders: decodedDogReminders,
                forDogLogs: decodedDogLogs,
                forDogTriggers: decodedDogTriggers,
                forOfflineModeComponents: decodedOfflineModeComponents
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
                forOfflineModeComponents: decodedOfflineModeComponents
            )
        }
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        if let dogId = dogId {
            aCoder.encode(dogId, forKey: KeyConstant.dogId.rawValue)
        }
        aCoder.encode(dogUUID.uuidString, forKey: KeyConstant.dogUUID.rawValue)
        aCoder.encode(dogName, forKey: KeyConstant.dogName.rawValue)
        aCoder.encode(dogReminders, forKey: KeyConstant.dogReminders.rawValue)
        aCoder.encode(dogLogs, forKey: KeyConstant.dogLogs.rawValue)
        aCoder.encode(dogTriggers, forKey: KeyConstant.dogTriggers.rawValue)
        aCoder.encode(offlineModeComponents, forKey: KeyConstant.offlineModeComponents.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: Dog, rhs: Dog) -> Bool {
        guard let lhsDogId = lhs.dogId else {
            guard rhs.dogId != nil else {
                // Neither have an id
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
    
    // MARK: - DogLogManagerDelegate
    
    func didAddLogs(forLogs logs: [Log]) {
        logs.forEach { log in
            var activatedTriggers = dogTriggers.matchingActivatedTriggers(forLog: log)
            
            activatedTriggers.forEach { activatedTrigger in
                let executionDate = activatedTrigger.nextReminderDate(afterLog: log)
                let resultReminderActionTypeId = activatedTrigger.resultReminderActionTypeId
                
            }
        }
        
        // TODO TRIGGERS check log against triggers
    }
    
    // MARK: - Properties
    
    var dogId: Int?
    
    var dogUUID: UUID = UUID()
    
    var dogIcon: UIImage?
    
    private(set) var dogName: String = ClassConstant.DogConstant.defaultDogName
    
    /// DogReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    private(set) var dogReminders: DogReminderManager = DogReminderManager()
    
    /// DogLogManager that handles all the logs for a dog. forDelegate is set to nil, as it is set in the init method
    private(set) var dogLogs: DogLogManager = DogLogManager(forDelegate: nil)
    
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
        forOfflineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.dogId = forDogId ?? dogId
        self.dogUUID = forDogUUID ?? dogUUID
        self.dogIcon = DogIconManager.getIcon(forDogUUID: dogUUID)
        self.dogReminders = forDogReminders ?? dogReminders
        self.dogLogs = forDogLogs ?? dogLogs
        self.dogLogs.delegate = self
        self.dogTriggers = forDogTriggers ?? dogTriggers
        self.offlineModeComponents = forOfflineModeComponents ?? offlineModeComponents
    }
    
    convenience init(
        forDogId: Int? = nil,
        forDogUUID: UUID? = nil,
        forDogName: String? = nil,
        forDogReminders: DogReminderManager? = nil,
        forDogLogs: DogLogManager? = nil,
        forDogTriggers: DogTriggerManager? = nil,
        forOfflineModeComponents: OfflineModeComponents? = nil
    ) throws {
        self.init(forDogId: forDogId, forDogUUID: forDogUUID, forDogReminders: forDogReminders, forDogLogs: forDogLogs, forDogTriggers: forDogTriggers, forOfflineModeComponents: forOfflineModeComponents)
        try changeDogName(forDogName: forDogName)
    }
    
    /// Provide a dictionary literal of dog properties to instantiate dog. Optionally, provide a dog to override with new properties from fromBody.
    convenience init?(fromBody: [String: Any?], dogToOverride: Dog?) {
        // Don't pull dogId or dogIsDeleted from dogToOverride. A valid fromBody needs to provide this itself
        let dogId: Int? = fromBody[KeyConstant.dogId.rawValue] as? Int
        let dogUUID: UUID? = UUID.fromString(forUUIDString: fromBody[KeyConstant.dogUUID.rawValue] as? String)
        let dogLastModified: Date? = (fromBody[KeyConstant.dogLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let dogIsDeleted: Bool? = fromBody[KeyConstant.dogIsDeleted.rawValue] as? Bool
        
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
                    forOfflineModeComponents: nil
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
                    forOfflineModeComponents: nil
                )
            }
            return
        }
        
        // if the dog is the same, then we pull values from dogToOverride
        // if the dog is updated, then we pull values from fromBody
        let dogName: String? = fromBody[KeyConstant.dogName.rawValue] as? String ?? dogToOverride?.dogName
        
        let dogReminders: DogReminderManager? = {
            guard let reminderBodies = fromBody[KeyConstant.dogReminders.rawValue] as? [[String: Any?]] else {
                return nil
            }
            
            return DogReminderManager(fromReminderBodies: reminderBodies, dogReminderManagerToOverride: dogToOverride?.dogReminders)
        }()
        
        let dogLogs: DogLogManager? = {
            guard let logBodies = fromBody[KeyConstant.dogLogs.rawValue] as? [[String: Any?]] else {
                return nil
            }
            
            // forDelegate is set to nil, as it is set in the init method
            return DogLogManager(fromLogBodies: logBodies, dogLogManagerToOverride: dogToOverride?.dogLogs, forDelegate: nil)
        }()
        
        let dogTriggers: DogTriggerManager? = {
            guard let triggerBodies = fromBody[KeyConstant.dogTriggers.rawValue] as? [[String: Any?]] else {
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
                forOfflineModeComponents: nil
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
                forOfflineModeComponents: nil
            )
        }
        
    }
    
    // MARK: - Function
    
    func changeDogName(forDogName: String?) throws {
        guard let forDogName = forDogName, forDogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ErrorConstant.DogError.dogNameMissing()
        }
        
        dogName = String(forDogName.prefix(ClassConstant.DogConstant.dogNameCharacterLimit))
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
    func createBody() -> [String: CompatibleDataTypeForJSON?] {
        var body: [String: CompatibleDataTypeForJSON?] = [:]
        body[KeyConstant.dogId.rawValue] = dogId
        body[KeyConstant.dogUUID.rawValue] = dogUUID.uuidString
        body[KeyConstant.dogName.rawValue] = dogName
        return body
    }
}
