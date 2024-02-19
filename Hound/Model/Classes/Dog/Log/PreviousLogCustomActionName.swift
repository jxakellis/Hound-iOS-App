//
//  PreviousLogCustomActionName.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

class PreviousLogCustomActionName: NSObject, NSCoding {

    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        let decodedLogAction = LogAction(internalValue: aDecoder.decodeObject(forKey: KeyConstant.logAction.rawValue) as? String ?? ClassConstant.LogConstant.defaultLogAction.internalValue) ?? ClassConstant.LogConstant.defaultLogAction
        let decodedLogCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.logCustomActionName.rawValue) as? String ?? ""
        
        self.init(logAction: decodedLogAction, logCustomActionName: decodedLogCustomActionName)
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeInteger, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        aCoder.encode(logAction.internalValue, forKey: KeyConstant.logAction.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
    }

    // MARK: - Properties
    
    private(set) var logAction: LogAction
    private(set) var logCustomActionName: String
    
    // MARK: - Main
    
    init(logAction: LogAction, logCustomActionName: String) {
        self.logAction = logAction
        self.logCustomActionName = logCustomActionName
        super.init()
    }
    
}
