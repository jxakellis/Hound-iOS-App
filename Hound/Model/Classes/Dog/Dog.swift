//
//  Dog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Dog: NSObject, NSCoding, NSCopying {

    // MARK: - NSCopying

    func copy(with zone: NSZone? = nil) -> Any {
        guard let copy = try? Dog(dogName: self.dogName) else {
            return Dog()
        }

        copy.dogId = self.dogId
        copy.dogName = self.dogName
        copy.dogIcon = self.dogIcon?.copy() as? UIImage
        copy.dogReminders = self.dogReminders.copy() as? ReminderManager ?? ReminderManager()
        copy.dogLogs = self.dogLogs.copy() as? LogManager ?? LogManager()
        return copy
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        super.init()
        dogId = aDecoder.decodeInteger(forKey: KeyConstant.dogId.rawValue)
        // shift dogId of 0 to proper placeholder of -1
        dogId = dogId >= 1 ? dogId : -1

        dogName = aDecoder.decodeObject(forKey: KeyConstant.dogName.rawValue) as? String ?? dogName
        dogLogs = aDecoder.decodeObject(forKey: KeyConstant.dogLogs.rawValue) as? LogManager ?? dogLogs
        dogReminders = aDecoder.decodeObject(forKey: KeyConstant.dogReminders.rawValue) as? ReminderManager ?? dogReminders
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: KeyConstant.dogId.rawValue)
        aCoder.encode(dogName, forKey: KeyConstant.dogName.rawValue)
        aCoder.encode(dogLogs, forKey: KeyConstant.dogLogs.rawValue)
        aCoder.encode(dogReminders, forKey: KeyConstant.dogReminders.rawValue)
    }

    // MARK: - Properties

    var dogId: Int = ClassConstant.DogConstant.defaultDogId

    var dogIcon: UIImage?

    private(set) var dogName: String = ClassConstant.DogConstant.defaultDogName
    func changeDogName(forDogName: String?) throws {
        guard let forDogName = forDogName else {
            throw ErrorConstant.DogError.dogNameNil()
        }

        guard forDogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw ErrorConstant.DogError.dogNameBlank()
        }

        guard forDogName.count <= ClassConstant.DogConstant.dogNameCharacterLimit else {
            throw ErrorConstant.DogError.dogNameCharacterLimitExceeded()
        }

        dogName = forDogName
    }

    /// ReminderManager that handles all specified reminders for a dog, e.g. being taken to the outside every time interval or being fed.
    var dogReminders: ReminderManager = ReminderManager()

    /// LogManager that handles all the logs for a dog
    var dogLogs: LogManager = LogManager()

    // MARK: - Main

    override init() {
        super.init()
    }

    convenience init(
        dogId: Int = ClassConstant.DogConstant.defaultDogId,
        dogName: String? = ClassConstant.DogConstant.defaultDogName) throws {
            self.init()

            self.dogId = dogId
            try changeDogName(forDogName: dogName)
            self.dogIcon = DogIconManager.getIcon(forDogId: dogId)
        }

    /// Provide a dictionary literal of dog properties to instantiate dog. Optionally, provide a dog to override with new properties from dogBody.
    convenience init?(forDogBody dogBody: [String: Any], overrideDog: Dog?) {
        // Don't pull dogId or dogIsDeleted from overrideDog. A valid dogBody needs to provide this itself
        let dogId: Int? = dogBody[KeyConstant.dogId.rawValue] as? Int
        let dogIsDeleted: Bool? = dogBody[KeyConstant.dogIsDeleted.rawValue] as? Bool

        // a dog body needs a dogId and dogIsDeleted to be intrepreted as same, updated, or deleted
        guard let dogId = dogId, let dogIsDeleted = dogIsDeleted else {
            // couldn't construct essential components to intrepret dog
            return nil
        }

        guard dogIsDeleted == false else {
            // the dog has been deleted
            // no need to process reminders or logs
            return nil
        }

        // if the dog is the same, then we pull values from overrideDog
        // if the dog is updated, then we pull values from dogBody
        let dogName: String? = dogBody[KeyConstant.dogName.rawValue] as? String ?? overrideDog?.dogName

        // no properties should be nil. Either a complete dogBody should be provided (i.e. no previousDogManagerSynchronization was used in query) or a potentially partial dogBody (i.e. previousDogManagerSynchronization used in query) should be passed with an overrideDogManager
        guard let dogName = dogName else {
            // halt and don't do anything more, reached an invalid state
            return nil
        }

        do {
            try self.init(dogId: dogId, dogName: dogName)
        }
        catch {
            try! self.init(dogId: dogId) // swiftlint:disable:this force_try
        }

        if let reminderBodies = dogBody[KeyConstant.reminders.rawValue] as? [[String: Any]] {
            self.dogReminders = ReminderManager(fromReminderBodies: reminderBodies, overrideReminderManager: overrideDog?.dogReminders)
        }
        if let logBodies = dogBody[KeyConstant.logs.rawValue] as? [[String: Any]] {
            self.dogLogs = LogManager(fromLogBodies: logBodies, overrideLogManager: overrideDog?.dogLogs)
        }
    }
}

extension Dog {
    // MARK: - Request

    /// Returns an array literal of the dog's properties (does not include nested properties, e.g. logs or reminders). This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.dogId.rawValue] = dogId
        body[KeyConstant.dogName.rawValue] = dogName
        return body
    }
}
