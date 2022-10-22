//
//  RemindersRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum RemindersRequest {
    
    /// Need dog id for any request so we can't append '/reminders' until we have dogId
    static var baseURLWithoutParams: URL { return DogsRequest.baseURLWithoutParams }
    
    // MARK: - Private Functions
    
    /**
       completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalGet(invokeErrorManager: Bool, forDogId dogId: Int, forReminderId reminderId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL
        
        if let reminderId = reminderId {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/\(reminderId)")
        }
        // don't necessarily need a reminderId, no reminderId specifys that you want all reminders for a dog
        else {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders")
        }
        
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /// Returns an array of reminder bodies under the key "reminders". E.g. { reminders : [{reminder1}, {reminder2}] }
    private static func createRemindersBody(reminders: [Reminder]) -> [String: [[String: Any]]] {
        var remindersArray: [[String: Any]] = []
        for reminder in reminders {
            remindersArray.append(reminder.createBody())
        }
        let body: [String: [[String: Any]]] = [KeyConstant.reminders.rawValue: remindersArray]
        return body
    }
    
    /**
    completionHandler returns response data: created reminder with reminderId and the ResponseStatus
    */
    private static func internalCreate(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        
        let body = createRemindersBody(reminders: reminders)
        
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalUpdate(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        
        let body = createRemindersBody(reminders: reminders)
        
        return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /// Returns an array of reminder bodies under the key ."reminders" E.g. { reminders : [{reminder1}, {reminder2}] }
    private static func createReminderIdsBody(forReminders reminders: [Reminder]) -> [String: [[String: Any]]] {
        var reminderIdsArray: [[String: Any]] = []
        for reminder in reminders {
            reminderIdsArray.append(reminder.createIdBody())
        }
        let body: [String: [[String: Any]]] = [KeyConstant.reminders.rawValue: reminderIdsArray]
        return body
    }
    
    /**
    completionHandler returns response data: dictionary of the body and the ResponseStatus
    */
    private static func internalDelete(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/reminders/")
        let body = createReminderIdsBody(forReminders: reminders)
        
        return InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
}

extension RemindersRequest {
    
    // MARK: - Public Functions
    
    /**
    completionHandler returns a reminder and response status. If the query is successful and the reminder isn't deleted, then the reminder is returned. Otherwise, nil is returned.
    */
    @discardableResult static func get(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Reminder?, ResponseStatus) -> Void) -> Progress? {
        
        return RemindersRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminderId: reminder.reminderId) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let reminderBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    completionHandler(Reminder(forReminderBody: reminderBody, overrideReminder: reminder), responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
    completionHandler returns a possible reminder and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Reminder?, ResponseStatus) -> Void) -> Progress? {
        
        return RemindersRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: [reminder]) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]], let reminderBody = remindersBody.first {
                    let reminder = Reminder(forReminderBody: reminderBody, overrideReminder: reminder)
                    
                    completionHandler(reminder, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
    completionHandler returns a possible array of reminders and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping ([Reminder]?, ResponseStatus) -> Void) -> Progress? {
        
        return RemindersRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: reminders) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [[String: Any]] {
                    // iterate over the remindersBody body. When constructing each reminder, attempt to find a corresponding reminder for each reminderBody. Only return reminders from remindersBody where the reminder can be constructed
                    let createdReminders: [Reminder] = remindersBody.enumerated().compactMap { (index, reminderBody) in
                        // the reminders array and the remindersBody should be 1:1, if they aren't then a nil overrideReminder is passed. Additionally, if the Reminder can't be constucted from the reminderBody, then nil is returned and compactMap doesn't include the entry.
                        return Reminder(forReminderBody: reminderBody, overrideReminder: reminders[safeIndex: index])
                    }
                    
                    completionHandler(createdReminders, responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }
    
    /**
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     Upon successful completion, invokes clearTimers() for each reminder
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        
        return RemindersRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: [reminder]) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // successfully updated the reminder, clear the timers for all of them as timing might have changed
                reminder.clearTimers()
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     Upon successful completion, invokes clearTimers() for each reminder
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        
        return RemindersRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: reminders) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // successfully updated the reminders, clear the timers for all of them as timing might have changed
                reminders.forEach { reminder in
                    reminder.clearTimers()
                }
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     Upon successful completion, invokes clearTimers() for each reminder
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forReminder reminder: Reminder, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return RemindersRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: [reminder]) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // successfully deleted the reminder, clear the timers for it as no longer needs timer
                reminder.clearTimers()
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
    
    /**
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     Upon successful completion, invokes clearTimers() for each reminder
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forReminders reminders: [Reminder], completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        return RemindersRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId, forReminders: reminders) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                // successfully deleted the reminders, clear the timers for all of them as no longer needs timers
                reminders.forEach { reminder in
                    reminder.clearTimers()
                }
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
