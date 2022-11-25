//
//  OneTimeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class OneTimeComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = OneTimeComponents()
        copy.oneTimeDate = self.oneTimeDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        oneTimeDate = aDecoder.decodeObject(forKey: KeyConstant.oneTimeDate.rawValue) as? Date ?? oneTimeDate
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(oneTimeDate, forKey: KeyConstant.oneTimeDate.rawValue)
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(date: Date) {
        self.init()
        self.oneTimeDate = date
    }
    
    // MARK: - Properties
    
    /// The Date that the alarm should fire
    var oneTimeDate: Date = Date()
}
