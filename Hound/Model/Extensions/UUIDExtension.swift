//
//  UUIDExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension UUID {
    static func fromString(forUUIDString: String?) -> UUID? {
        guard let forUUIDString = forUUIDString else {
            return nil
        }
        
        return UUID(uuidString: forUUIDString)
    }
}
