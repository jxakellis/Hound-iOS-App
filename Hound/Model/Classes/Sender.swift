//
//  Sender.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/27/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Sender {
    
    let origin: AnyObject?
    var localized: AnyObject?
    
    init(origin: AnyObject, localized: AnyObject) {
        if let sender = origin as? Sender {
            self.origin = sender.origin
        }
        else {
            self.origin = origin
        }
        
        // localized cannot be sender, however we can let it pass
        if let sender = localized as? Sender {
            self.localized = sender.localized
        }
        else {
            self.localized = localized
        }
    }
    
}
