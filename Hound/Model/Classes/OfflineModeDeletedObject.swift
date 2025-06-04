//
//  OfflineModeDeletedObject.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/11/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

class OfflineModeDeletedObject: NSObject, NSCoding {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDeletedDate: Date? = aDecoder.decodeObject(forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue) as? Date
        
        self.init(
            deletedDate: decodedDeletedDate ?? Date()
        )
    }
    
    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(deletedDate, forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue)
    }
    
    // MARK: - Equatable
    
    /// Two OfflineModeDeletedObject are only equal if they are subclasses of OfflineModeDeletedObject whp's overriden == method says they are equal
    override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? OfflineModeDeletedObject else {
            return false
        }
        
        guard type(of: self) == type(of: rhs) else {
            return false
        }
        
        if let lhs = self as? OfflineModeDeletedDog, let rhs = rhs as? OfflineModeDeletedDog {
            return lhs == rhs
        }
        else if let lhs = self as? OfflineModeDeletedReminder, let rhs = rhs as? OfflineModeDeletedReminder {
            return lhs == rhs
        }
        else if let lhs = self as? OfflineModeDeletedLog, let rhs = rhs as? OfflineModeDeletedLog {
            return lhs == rhs
        }
        else if let lhs = self as? OfflineModeDeletedTrigger, let rhs = rhs as? OfflineModeDeletedTrigger {
            return lhs == rhs
        }
        
        return false
    }
    
    // MARK: - Properties
    
    var deletedDate: Date
    
    // MARK: - Main
    
    init(deletedDate: Date) {
        self.deletedDate = deletedDate
    }
}

final class OfflineModeDeletedDog: OfflineModeDeletedObject {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.dogUUID.rawValue) as? String)
        let decodedDeletedDate: Date? = aDecoder.decodeObject(forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue) as? Date
        
        self.init(
            dogUUID: decodedDogUUID ?? VisualConstant.TextConstant.unknownUUID,
            deletedDate: decodedDeletedDate ?? Date()
        )
    }
    
    override func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogUUID.uuidString, forKey: KeyConstant.dogUUID.rawValue)
        aCoder.encode(deletedDate, forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue)
    }
    
    // MARK: - Equatable
    
    override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? OfflineModeDeletedDog else {
            return false
        }
        
        return self.dogUUID == rhs.dogUUID
    }
    
    // MARK: - Properties
    
    var dogUUID: UUID
    
    // MARK: - Main
    
    init(dogUUID: UUID, deletedDate: Date) {
        self.dogUUID = dogUUID
        super.init(deletedDate: deletedDate)
    }
}

final class OfflineModeDeletedReminder: OfflineModeDeletedObject {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.dogUUID.rawValue) as? String)
        let decodedReminderUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.reminderUUID.rawValue) as? String)
        let decodedDeletedDate: Date? = aDecoder.decodeObject(forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue) as? Date
        
        self.init(
            dogUUID: decodedDogUUID ?? VisualConstant.TextConstant.unknownUUID,
            reminderUUID: decodedReminderUUID ?? VisualConstant.TextConstant.unknownUUID,
            deletedDate: decodedDeletedDate ?? Date()
        )
    }
    
    override func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogUUID.uuidString, forKey: KeyConstant.dogUUID.rawValue)
        aCoder.encode(reminderUUID.uuidString, forKey: KeyConstant.reminderUUID.rawValue)
        aCoder.encode(deletedDate, forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue)
    }
    
    // MARK: - Equatable
    
    override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? OfflineModeDeletedReminder else {
            return false
        }
        
        return self.dogUUID == rhs.dogUUID && self.reminderUUID == rhs.reminderUUID
    }
    
    // MARK: - Properties
    
    var dogUUID: UUID
    var reminderUUID: UUID
    
    // MARK: - Main
    
    init(dogUUID: UUID, reminderUUID: UUID, deletedDate: Date) {
        self.dogUUID = dogUUID
        self.reminderUUID = reminderUUID
        super.init(deletedDate: deletedDate)
    }
}

final class OfflineModeDeletedLog: OfflineModeDeletedObject {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.dogUUID.rawValue) as? String)
        let decodedLogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.logUUID.rawValue) as? String)
        let decodedDeletedDate: Date? = aDecoder.decodeObject(forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue) as? Date
        
        self.init(
            dogUUID: decodedDogUUID ?? VisualConstant.TextConstant.unknownUUID,
            logUUID: decodedLogUUID ?? VisualConstant.TextConstant.unknownUUID,
            deletedDate: decodedDeletedDate ?? Date()
        )
    }
    
    override func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogUUID.uuidString, forKey: KeyConstant.dogUUID.rawValue)
        aCoder.encode(logUUID.uuidString, forKey: KeyConstant.logUUID.rawValue)
        aCoder.encode(deletedDate, forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue)
    }
    
    // MARK: - Equatable
    
    override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? OfflineModeDeletedLog else {
            return false
        }
        
        return self.dogUUID == rhs.dogUUID && self.logUUID == rhs.logUUID
    }
    
    // MARK: - Properties
    
    var dogUUID: UUID
    var logUUID: UUID
    
    // MARK: - Main
    
    init(dogUUID: UUID, logUUID: UUID, deletedDate: Date) {
        self.dogUUID = dogUUID
        self.logUUID = logUUID
        super.init(deletedDate: deletedDate)
    }
}

final class OfflineModeDeletedTrigger: OfflineModeDeletedObject {
    
    // MARK: - NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        let decodedDogUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.dogUUID.rawValue) as? String)
        let decodedTriggerUUID: UUID? = UUID.fromString(forUUIDString: aDecoder.decodeObject(forKey: KeyConstant.triggerUUID.rawValue) as? String)
        let decodedDeletedDate: Date? = aDecoder.decodeObject(forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue) as? Date
        
        self.init(
            dogUUID: decodedDogUUID ?? VisualConstant.TextConstant.unknownUUID,
            triggerUUID: decodedTriggerUUID ?? VisualConstant.TextConstant.unknownUUID,
            deletedDate: decodedDeletedDate ?? Date()
        )
    }
    
    override func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(dogUUID.uuidString, forKey: KeyConstant.dogUUID.rawValue)
        aCoder.encode(triggerUUID.uuidString, forKey: KeyConstant.triggerUUID.rawValue)
        aCoder.encode(deletedDate, forKey: KeyConstant.offlineModeDeletedObjectDeletedDate.rawValue)
    }
    
    // MARK: - Equatable
    
    override func isEqual(_ rhs: Any?) -> Bool {
        guard let rhs = rhs as? OfflineModeDeletedTrigger else {
            return false
        }
        
        return self.dogUUID == rhs.dogUUID && self.triggerUUID == rhs.triggerUUID
    }
    
    // MARK: - Properties
    
    var dogUUID: UUID
    var triggerUUID: UUID
    
    // MARK: - Main
    
    init(dogUUID: UUID, triggerUUID: UUID, deletedDate: Date) {
        self.dogUUID = dogUUID
        self.triggerUUID = triggerUUID
        super.init(deletedDate: deletedDate)
    }
}
