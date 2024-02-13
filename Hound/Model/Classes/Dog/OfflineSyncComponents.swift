//
//  OfflineModeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/9/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class OfflineModeComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        return OfflineModeComponents(
            forInitialAttemptedSyncDate: self.initialAttemptedSyncDate,
            forInitialCreationDate: self.initialCreationDate
        )
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedInitialAttemptedSyncDate = aDecoder.decodeObject(forKey: KeyConstant.offlineModeComponentsInitialAttemptedSyncDate.rawValue) as? Date
        let decodedInitialCreationDate = aDecoder.decodeObject(forKey: KeyConstant.offlineModeComponentsInitialCreationDate.rawValue) as? Date
        
        self.init(
            forInitialAttemptedSyncDate: decodedInitialAttemptedSyncDate,
            forInitialCreationDate: decodedInitialCreationDate
        )
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(initialAttemptedSyncDate, forKey: KeyConstant.offlineModeComponentsInitialAttemptedSyncDate.rawValue)
    }
    
    // MARK: - Properties
    
    /// If this flag is true, the offline manager will attempt to sync this object at a later date when connectivity is restored. The values of this flag depends on whether or not initialAttemptedSyncDate is nil
    var needsSyncedWithHoundServer: Bool {
        return initialAttemptedSyncDate != nil
    }
    
    /// This is the date which the object was attempted to be synced with the Hound server but failed due to no connection. If this is set to a
    private(set) var initialAttemptedSyncDate: Date?
    /// Function used externally to manage initialAttemptedSyncDate
    func updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date?) {
        guard let forInitialAttemptedSyncDate = forInitialAttemptedSyncDate else {
            // Override initialAttemptedSyncDate to set it to nil
            initialAttemptedSyncDate = forInitialAttemptedSyncDate
            return
        }
        
        guard initialAttemptedSyncDate != nil else {
            // forInitialAttemptedSyncDate isn't nil but initialAttemptedSyncDate is, override initialAttemptedSyncDate with the value
            initialAttemptedSyncDate = forInitialAttemptedSyncDate
            return
        }
        
        // Both forInitialAttemptedSyncDate and initialAttemptedSyncDate aren't nil, therefore do nothing as the initialAttemptedSyncDate shouldn't be overriden with another value.
    }
    
    /// This is the date which the object was created by the user
    private(set) var initialCreationDate: Date = Date()
    
    // MARK: - Main
    
    init(
        forInitialAttemptedSyncDate: Date? = nil,
        forInitialCreationDate: Date? = nil
    ) {
        self.initialAttemptedSyncDate = forInitialAttemptedSyncDate ?? initialAttemptedSyncDate
        self.initialCreationDate = forInitialCreationDate ?? initialCreationDate
    }
}
