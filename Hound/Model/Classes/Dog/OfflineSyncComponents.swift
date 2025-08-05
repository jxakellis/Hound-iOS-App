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
            initialAttemptedSyncDate: self.initialAttemptedSyncDate,
            initialCreationDate: self.initialCreationDate
        )
    }
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedInitialAttemptedSyncDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponentsInitialAttemptedSyncDate.rawValue)
        let decodedInitialCreationDate: Date? = aDecoder.decodeOptionalObject(forKey: Constant.Key.offlineModeComponentsInitialCreationDate.rawValue)
        
        self.init(
            initialAttemptedSyncDate: decodedInitialAttemptedSyncDate,
            initialCreationDate: decodedInitialCreationDate
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(initialAttemptedSyncDate, forKey: Constant.Key.offlineModeComponentsInitialAttemptedSyncDate.rawValue)
        aCoder.encode(initialCreationDate, forKey: Constant.Key.offlineModeComponentsInitialCreationDate.rawValue)
    }
    
    // MARK: - Properties
    
    /// If this flag is true, the offline manager will attempt to sync this object at a later date when connectivity is restored. The values of this flag depends on whether or not initialAttemptedSyncDate is nil
    var needsSyncedWithHoundServer: Bool {
        return initialAttemptedSyncDate != nil
    }
    
    /// This is the date which the object was attempted to be synced with the Hound server but failed due to no connection. If this is set to a
    private(set) var initialAttemptedSyncDate: Date?
    /// Function used externally to manage initialAttemptedSyncDate
    func updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date?) {
        guard let initialAttemptedSyncDate = initialAttemptedSyncDate else {
            // Override initialAttemptedSyncDate to set it to nil
            self.initialAttemptedSyncDate = initialAttemptedSyncDate
            return
        }
        
        guard self.initialAttemptedSyncDate != nil else {
            // initialAttemptedSyncDate isn't nil but initialAttemptedSyncDate is, override initialAttemptedSyncDate with the value
            self.initialAttemptedSyncDate = initialAttemptedSyncDate
            return
        }
        
        // Both initialAttemptedSyncDate and initialAttemptedSyncDate aren't nil, therefore do nothing as the initialAttemptedSyncDate shouldn't be overriden with another value.
    }
    
    /// This is the date which the object was created by the user
    private(set) var initialCreationDate: Date = Date()
    
    // MARK: - Main
    
    init(
        initialAttemptedSyncDate: Date? = nil,
        initialCreationDate: Date? = nil
    ) {
        self.initialAttemptedSyncDate = initialAttemptedSyncDate ?? self.initialAttemptedSyncDate
        self.initialCreationDate = initialCreationDate ?? self.initialCreationDate
    }
}
