//
//  reminderTrigger.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class ReminderTrigger: NSObject, NSCoding, NSCopying, Comparable {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ReminderTrigger()
        // IMPORTANT: The setter method for properties may modify values. We want to clone exactly what is stored, so access stored properties directly.
        copy.reminderTriggerId = self.reminderTriggerId
        copy.reminderTriggerUUID = self.reminderTriggerUUID
        copy.userId = self.userId
        copy.logActionsToReactTo = self.logActionsToReactTo
        copy.storedReminderTriggerCustomName = self.storedReminderTriggerCustomName
        copy.reminderTriggerDelay = self.reminderTriggerDelay
        copy.offlineModeComponents = self.offlineModeComponents.copy() as? OfflineModeComponents ?? OfflineModeComponents()
        
        return copy
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedReminderTriggerId = aDecoder.decodeObject(
            forKey: KeyConstant.reminderTriggerId.rawValue
        ) as? Int
        let decodedReminderTriggerUUID = UUID.fromString(
            forUUIDString: aDecoder.decodeObject(
                forKey: KeyConstant.reminderTriggerUUID.rawValue
            ) as? String
        )
        let decodedUserId = aDecoder.decodeObject(
            forKey: KeyConstant.userId.rawValue
        ) as? String
        let decodedLogActionsToReactTo = (aDecoder.decodeObject(
            forKey: KeyConstant.logActionsToReactTo.rawValue
        ) as? [String])?.compactMap { LogAction(internalValue: $0) }
        let decodedReminderTriggerCustomName = aDecoder.decodeObject(
            forKey: KeyConstant.reminderTriggerCustomName.rawValue
        ) as? String
        let decodedReminderTriggerDelay = aDecoder.decodeObject(
            forKey: KeyConstant.reminderTriggerDelay.rawValue
        ) as? Double
        let decodedOfflineModeComponents = aDecoder.decodeObject(
            forKey: KeyConstant.offlineModeComponents.rawValue
        ) as? OfflineModeComponents
        
        self.init(
            forReminderTriggerId: decodedReminderTriggerId,
            forReminderTriggerUUID: decodedReminderTriggerUUID,
            forUserId: decodedUserId,
            forLogActionsToReactTo: decodedLogActionsToReactTo,
            forReminderTriggerCustomName: decodedReminderTriggerCustomName,
            forReminderTriggerDelay: decodedReminderTriggerDelay,
            forOfflineModeComponents: decodedOfflineModeComponents
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(reminderTriggerId, forKey: KeyConstant.reminderTriggerId.rawValue)
        aCoder.encode(reminderTriggerUUID.uuidString, forKey: KeyConstant.reminderTriggerUUID.rawValue)
        aCoder.encode(userId, forKey: KeyConstant.userId.rawValue)
        let actionValues = logActionsToReactTo.map { $0.internalValue }
        aCoder.encode(actionValues, forKey: KeyConstant.logActionsToReactTo.rawValue)
        aCoder.encode(storedReminderTriggerCustomName, forKey: KeyConstant.reminderTriggerCustomName.rawValue)
        aCoder.encode(reminderTriggerDelay, forKey: KeyConstant.reminderTriggerDelay.rawValue)
        aCoder.encode(offlineModeComponents, forKey: KeyConstant.offlineModeComponents.rawValue)
    }
    
    // MARK: - Comparable
    
    static func < (lhs: ReminderTrigger, rhs: ReminderTrigger) -> Bool {
        guard lhs.reminderTriggerDelay != rhs.reminderTriggerDelay else {
            // If same reminderTriggerDelay, then one with lesser id comes first
            guard let lhsReminderTriggerId = lhs.reminderTriggerId else {
                guard rhs.reminderTriggerId != nil else {
                    // Neither have an id
                    return lhs.reminderTriggerUUID.uuidString <= rhs.reminderTriggerUUID.uuidString
                }
                
                // lhs doesn't have a id but rhs does. rhs should come first
                return false
            }
            
            guard let rhsReminderTriggerId = rhs.reminderTriggerId else {
                // lhs has a id but rhs doesn't. lhs should come first
                return true
            }
            
            return lhsReminderTriggerId <= rhsReminderTriggerId
        }
        // Returning true means item1 comes before item2, false means item2 before item1
        
        return lhs.reminderTriggerDelay <= rhs.reminderTriggerDelay
    }
    
    // MARK: - Properties
    
    /// The reminderTriggerId given to this reminderTrigger from the Hound database
    var reminderTriggerId: Int?
    
    /// The UUID of this dynamic log that is generated locally upon creation. Useful in identifying the dynamic log before/in the process of creating it
    var reminderTriggerUUID: UUID = UUID()
    
    /// The userId of the user that created this log
    var userId: String = ClassConstant.LogConstant.defaultUserId
    
    var logActionsToReactTo: [LogAction] = []
    
    private var storedReminderTriggerCustomName: String = ""
    var reminderTriggerCustomName: String {
        get {
            return storedReminderTriggerCustomName
        }
        set {
            // TODO DR this should be a diff constant
            storedReminderTriggerCustomName = String((newValue.trimmingCharacters(in: .whitespacesAndNewlines)).prefix(ClassConstant.LogConstant.logCustomActionNameCharacterLimit))
        }
    }
    
    // TODO RT make this an actual constant
    private(set) var reminderTriggerDelay: Double = 1.0
    
    /// Components that are used to track an object to determine whether it was synced with the Hound server and whether it needs to be when the device comes back online
    private(set) var offlineModeComponents: OfflineModeComponents = OfflineModeComponents()
    
    // MARK: - Main
    
    init(
        forReminderTriggerId: Int? = nil,
        forReminderTriggerUUID: UUID? = nil,
        forUserId: String? = nil,
        forLogActionsToReactTo: [LogAction]? = nil,
        forReminderTriggerCustomName: String? = nil,
        forReminderTriggerDelay: Double? = nil,
        forOfflineModeComponents: OfflineModeComponents? = nil
    ) {
        super.init()
        self.reminderTriggerId = forReminderTriggerId ?? reminderTriggerId
        self.reminderTriggerUUID = forReminderTriggerUUID ?? reminderTriggerUUID
        self.userId = forUserId ?? self.userId
        self.logActionsToReactTo = forLogActionsToReactTo ?? self.logActionsToReactTo
        self.reminderTriggerCustomName = forReminderTriggerCustomName ?? self.reminderTriggerCustomName
        self.reminderTriggerDelay = forReminderTriggerDelay ?? self.reminderTriggerDelay
        self.offlineModeComponents = forOfflineModeComponents ?? self.offlineModeComponents
        
    }
    
    /// Provide a dictionary literal of reminder trigger properties to instantiate reminder trigger. Optionally, provide a reminder trigger to override with new properties from fromReminderTriggerBody.
    convenience init?(fromReminderTriggerBody: [String: Any?], reminderTriggerToOverride: ReminderTrigger?) {
        // Don't pull reminderTriggerId or reminderTriggerIsDeleted from reminderTriggerToOverride. A valid fromReminderTriggerBody needs to provide this itself
        let reminderTriggerId = fromReminderTriggerBody[KeyConstant.reminderTriggerId.rawValue] as? Int
        let reminderTriggerUUID = UUID.fromString(forUUIDString: fromReminderTriggerBody[KeyConstant.reminderTriggerUUID.rawValue] as? String)
        // TODO RT make sure last modified and deleted are properly implemented on server side functions
        let reminderTriggerLastModified = (fromReminderTriggerBody[KeyConstant.reminderTriggerLastModified.rawValue] as? String)?.formatISO8601IntoDate()
        let reminderIsDeleted = fromReminderTriggerBody[KeyConstant.reminderTriggerIsDeleted.rawValue] as? Bool
        
        // The body needs an id, uuid, and isDeleted to be intrepreted as same, updated, or deleted. Otherwise, it is invalid
        guard let reminderTriggerId = reminderTriggerId, let reminderTriggerUUID = reminderTriggerUUID, let reminderTriggerLastModified = reminderTriggerLastModified, let reminderIsDeleted = reminderIsDeleted else {
            return nil
        }
        
        guard reminderIsDeleted == false else {
            // The reminder trigger has been deleted. Doesn't matter if our offline mode made any changes
            return nil
        }
        
        // If we have pulled an update from the server which is more outdated than our local change, then ignore the data from the server. Otherwise, the newer server update takes precedence over our offline update
        if let reminderTriggerToOverride = reminderTriggerToOverride, let initialAttemptedSyncDate = reminderTriggerToOverride.offlineModeComponents.initialAttemptedSyncDate, initialAttemptedSyncDate >= reminderTriggerLastModified {
            self.init(
                forReminderTriggerId: reminderTriggerToOverride.reminderTriggerId,
                forReminderTriggerUUID: reminderTriggerToOverride.reminderTriggerUUID,
                forUserId: reminderTriggerToOverride.userId,
                forLogActionsToReactTo: reminderTriggerToOverride.logActionsToReactTo,
                forReminderTriggerCustomName: reminderTriggerToOverride.reminderTriggerCustomName,
                forReminderTriggerDelay: reminderTriggerToOverride.reminderTriggerDelay,
                forOfflineModeComponents: reminderTriggerToOverride.offlineModeComponents
            )
            return
        }
        
        // if the reminder trigger is the same, then we pull values from reminderTriggerToOverride
        // if the reminder trigger is updated, then we pull values from fromReminderTriggerBody
        let userId = fromReminderTriggerBody[KeyConstant.userId.rawValue] as? String ?? reminderTriggerToOverride?.userId
        
        let logActionsToReactTo = {
            // TODO RT what happens if this is an empty array? is logActionStrings nil or just empty
            let logActionStrings = fromReminderTriggerBody[KeyConstant.logActionsToReactTo.rawValue] as? [String]
            
            guard let logActionStrings = logActionStrings else {
                return nil
            }
            
            return logActionStrings.filter { LogAction(internalValue: $0) != nil }.map { LogAction(internalValue: $0)! } // swiftlint:disable:this force_unwrapping
        }() ?? reminderTriggerToOverride?.logActionsToReactTo
        
        let reminderTriggerCustomName: String? = fromReminderTriggerBody[KeyConstant.reminderTriggerCustomName.rawValue] as? String ?? reminderTriggerToOverride?.reminderTriggerCustomName
        
        let reminderTriggerDelay: Double? = fromReminderTriggerBody[KeyConstant.reminderTriggerDelay.rawValue] as? Double ?? reminderTriggerToOverride?.reminderTriggerDelay
        
        self.init(
            forReminderTriggerId: reminderTriggerId,
            forReminderTriggerUUID: reminderTriggerUUID,
            forUserId: userId,
            forLogActionsToReactTo: logActionsToReactTo,
            forReminderTriggerCustomName: reminderTriggerCustomName,
            forReminderTriggerDelay: reminderTriggerDelay,
            // Verified that the update from the server happened more recently than our local changes, so no need to offline sync anymore
            forOfflineModeComponents: nil
        )
    }
    
    // MARK: - Functions
    
    /// Returns an array literal of the reminder triggers's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody(forDogUUID: UUID) -> [String: CompatibleDataTypeForJSON?] {
        var body: [String: CompatibleDataTypeForJSON?] = [:]
        body[KeyConstant.dogUUID.rawValue] = forDogUUID.uuidString
        body[KeyConstant.reminderTriggerId.rawValue] = reminderTriggerId
        body[KeyConstant.reminderTriggerUUID.rawValue] = reminderTriggerUUID.uuidString
        body[KeyConstant.userId.rawValue] = userId
        body[KeyConstant.logActionsToReactTo.rawValue] = logActionsToReactTo.map { logActionToReactTo in logActionToReactTo.internalValue }
        body[KeyConstant.reminderTriggerCustomName.rawValue] = reminderTriggerCustomName
        body[KeyConstant.reminderTriggerDelay.rawValue] = reminderTriggerDelay
        return body
        
    }
}
