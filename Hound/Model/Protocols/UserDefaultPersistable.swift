//
//  UserDefaultPersistable.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/14/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

protocol UserDefaultPersistable {
    static func persist(toUserDefaults: UserDefaults)
    static func load(fromUserDefaults: UserDefaults)
}
