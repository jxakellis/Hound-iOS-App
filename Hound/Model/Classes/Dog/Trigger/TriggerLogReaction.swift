//
//  TriggerLogReaction.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class TriggerLogReaction: NSObject, NSCoding {
    
    // MARK: - NSCoding

    required convenience init?(coder aDecoder: NSCoder) {
        guard let decodedLogActionTypeId = aDecoder.decodeOptionalInteger(forKey: KeyConstant.logActionTypeId.rawValue) else {
            return nil
        }
        let decodedCustomName = aDecoder.decodeOptionalString(forKey: KeyConstant.logCustomActionName.rawValue)
        self.init(logActionTypeId: decodedLogActionTypeId, logCustomActionName: decodedCustomName)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(logActionTypeId, forKey: KeyConstant.logActionTypeId.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
    }
    
    // MARK: - Properties

    private(set) var logActionTypeId: Int = ClassConstant.LogConstant.defaultLogActionTypeId
    private(set) var logCustomActionName: String?
    
    // MARK: - Main

    init(forLogActionTypeId: Int? = nil, forLogCustomActionName: String? = nil) {
        self.logActionTypeId = forLogActionTypeId ?? logActionTypeId
        self.logCustomActionName = forLogCustomActionName ?? logCustomActionName
        super.init()
    }
    
    convenience init(fromBody: [String: Any?], toOverride: TriggerLogReaction?) {
        let logActionTypeId = fromBody[KeyConstant.logActionTypeId.rawValue] as? Int ?? toOverride?.logActionTypeId
        let logCustomActionName = fromBody[KeyConstant.logCustomActionName.rawValue] as? String ?? toOverride?.logCustomActionName
        
        self.init(forLogActionTypeId: logActionTypeId, forLogCustomActionName: logCustomActionName)
    }
    
    func createBody() -> [String: CompatibleDataTypeForJSON?] {
        var body: [String: CompatibleDataTypeForJSON?] = [:]
        body[KeyConstant.logActionTypeId.rawValue] = logActionTypeId
        body[KeyConstant.logCustomActionName.rawValue] = logCustomActionName
        return body
        
    }
    
}
