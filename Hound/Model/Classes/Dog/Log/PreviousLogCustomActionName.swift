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
        let decodedLogActionTypeId = aDecoder.decodeObject(forKey: KeyConstant.logActionTypeId.rawValue) as? Int ?? ClassConstant.LogConstant.defaultLogActionTypeId
        let decodedLogCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.logCustomActionName.rawValue) as? String ?? ""
        
        self.init(logActionTypeId: decodedLogActionTypeId, logCustomActionName: decodedLogCustomActionName)
    }

    func encode(with aCoder: NSCoder) {
        // IMPORTANT ENCODING INFORMATION. DO NOT ENCODE NIL FOR PRIMATIVE TYPES. If encoding a data type which requires a decoding function other than decodeObject (e.g. decodeObject, decodeDouble...), the value that you encode CANNOT be nil. If nil is encoded, then one of these custom decoding functions trys to decode it, a cascade of erros will happen that results in a completely default dog being decoded.
        
        aCoder.encode(logActionTypeId, forKey: KeyConstant.logActionTypeId.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
    }

    // MARK: - Properties
    
    private(set) var logActionTypeId: Int
    private(set) var logCustomActionName: String
    
    // MARK: - Main
    
    init(logActionTypeId: Int, logCustomActionName: String) {
        self.logActionTypeId = logActionTypeId
        self.logCustomActionName = logCustomActionName
        super.init()
    }
    
}
