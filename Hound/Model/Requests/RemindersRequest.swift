//
//  RemindersRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RemindersRequest {
    
    static var baseURL: URL { DogsRequest.baseURL.appendingPathComponent("/reminders") }
    
    /// Returns an array of reminder bodies under the key "reminders". E.g. { reminders : [{reminder1}, {reminder2}] }
    private static func createRemindersBody(forDogId dogId: Int, forReminders reminders: [Reminder]) -> [String: [[String: Any]]] {
        var remindersArray: [[String: Any]] = []
        for reminder in reminders {
            remindersArray.append(reminder.createBody(forDogId: dogId))
        }
        let body: [String: [[String: Any]]] = [KeyConstant.reminders.rawValue: remindersArray]
        return body
    }
    
}

extension RemindersRequest {
    
    // MARK: - Public Functions
    
    /**
     If query is successful, automatically combines client-side and server-side reminders and returns (reminder, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Reminder?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = reminder.createBody(forDogId: dogId)
        
        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    if let reminderBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                        completionHandler(Reminder(forReminderBody: reminderBody, overrideReminder: reminder.copy() as? Reminder), responseStatus, error)
                    }
                    else {
                        completionHandler(nil, responseStatus, error)
                    }
                case .failureResponse:
                    completionHandler(nil, responseStatus, error)
                case .noResponse:
                    completionHandler(nil, responseStatus, error)
                }
            }
    }
    
    /**
     If query is successful, automatically combines client-side and server-side reminders returns (reminder, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Reminder?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = createRemindersBody(forDogId: dogId, forReminders: [reminder])
        
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]], let reminderBody = remindersBody.first {
                        // We can't do the same processing here as with dogs or logs. We must create a new reminder from the body and return it. This is because create for dogs/logs simply returns an id where as create for reminders returns an array of reminder properties (the reason for this difference is so you can quickly create multiple reminders in one query).
                        let reminder = Reminder(forReminderBody: reminderBody, overrideReminder: reminder)
                        
                        completionHandler(reminder, responseStatus, error)
                    }
                    else {
                        completionHandler(nil, responseStatus, error)
                    }
                case .failureResponse:
                    completionHandler(nil, responseStatus, error)
                case .noResponse:
                    completionHandler(nil, responseStatus, error)
                }
            }
    }
    
    /**
     If query is successful, automatically client-side and server-side reminders and returns (reminders, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([Reminder]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = createRemindersBody(forDogId: dogId, forReminders: reminders)
        
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]] {
                        // iterate over the remindersBody body. When constructing each reminder, attempt to find a corresponding reminder for each reminderBody. Only return reminders from remindersBody where the reminder can be constructed
                        let createdReminders: [Reminder] = remindersBody.enumerated().compactMap { index, reminderBody in
                            // the reminders array and the remindersBody should be 1:1, if they aren't then a nil overrideReminder is passed. Additionally, if the Reminder can't be constucted from the reminderBody, then nil is returned and compactMap doesn't include the entry.
                            return Reminder(forReminderBody: reminderBody, overrideReminder: reminders.safeIndex(index))
                        }
                        
                        completionHandler(createdReminders, responseStatus, error)
                    }
                    else {
                        completionHandler(nil, responseStatus, error)
                    }
                case .failureResponse:
                    completionHandler(nil, responseStatus, error)
                case .noResponse:
                    completionHandler(nil, responseStatus, error)
                }
            }
    }
    
    /**
     If query is successful, automatically invokes clearTimers() for the reminder and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return update(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: [reminder], completionHandler: completionHandler)
    }
    
    /**
     If query is successful, automatically invokes clearTimers() for each reminder and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = createRemindersBody(forDogId: dogId, forReminders: reminders)
        
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    // successfully updated the reminders, clear the timers for all of them as timing might have changed
                    reminders.forEach { reminder in
                        reminder.clearTimers()
                    }
                    completionHandler(true, responseStatus, error)
                case .failureResponse:
                    completionHandler(false, responseStatus, error)
                case .noResponse:
                    completionHandler(false, responseStatus, error)
                }
            }
    }
    
    /**
     If query is successful, automatically invokes clearTimers() for the reminder and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return delete(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: [reminder], completionHandler: completionHandler)
    }
    
    /**
     If query is successful, automatically invokes clearTimers() for each reminder and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = createRemindersBody(forDogId: dogId, forReminders: reminders)
        
        return RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    // successfully deleted the reminders, clear the timers for all of them as no longer needs timers
                    reminders.forEach { reminder in
                        reminder.clearTimers()
                    }
                    completionHandler(true, responseStatus, error)
                case .failureResponse:
                    completionHandler(false, responseStatus, error)
                case .noResponse:
                    completionHandler(false, responseStatus, error)
                }
            }
    }
}
