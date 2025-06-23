//
//  PreviousReminderCustomActionName.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

class PreviousReminderCustomActionName: NSObject, NSCoding {

    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        guard
            let decodedReminderActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.reminderActionTypeId.rawValue),
            let decodedReminderCustomActionName = aDecoder.decodeOptionalString(forKey: KeyConstant.reminderCustomActionName.rawValue)
        else {
            return nil
        }
        self.init(reminderActionTypeId: decodedReminderActionTypeId, reminderCustomActionName: decodedReminderCustomActionName)
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(reminderActionTypeId, forKey: KeyConstant.reminderActionTypeId.rawValue)
        aCoder.encode(reminderCustomActionName, forKey: KeyConstant.reminderCustomActionName.rawValue)
    }

    // MARK: - Properties
    
    private(set) var reminderActionTypeId: Int
    private(set) var reminderCustomActionName: String
    
    // MARK: - Main
    
    init(reminderActionTypeId: Int, reminderCustomActionName: String) {
        self.reminderActionTypeId = reminderActionTypeId
        self.reminderCustomActionName = reminderCustomActionName
        super.init()
    }
    
}
