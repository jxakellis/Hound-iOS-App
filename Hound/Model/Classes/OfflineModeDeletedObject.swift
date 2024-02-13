//
//  OfflineModeDeletedObject.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/11/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

class OfflineModeDeletedObject {
    var deletedDate: Date
    init(deletedDate: Date) {
        self.deletedDate = deletedDate
    }
}

final class OfflineModeDeletedDog: OfflineModeDeletedObject {
    var dogUUID: UUID
    init(dogUUID: UUID, deletedDate: Date) {
        self.dogUUID = dogUUID
        super.init(deletedDate: deletedDate)
    }
}

final class OfflineModeDeletedReminder: OfflineModeDeletedObject {
    var dogUUID: UUID
    var reminderUUID: UUID
    init(dogUUID: UUID, reminderUUID: UUID, deletedDate: Date) {
        self.dogUUID = dogUUID
        self.reminderUUID = reminderUUID
        super.init(deletedDate: deletedDate)
    }
}

final class OfflineModeDeletedLog: OfflineModeDeletedObject {
    var dogUUID: UUID
    var logUUID: UUID
    init(dogUUID: UUID, logUUID: UUID, deletedDate: Date) {
        self.dogUUID = dogUUID
        self.logUUID = logUUID
        super.init(deletedDate: deletedDate)
    }
}
