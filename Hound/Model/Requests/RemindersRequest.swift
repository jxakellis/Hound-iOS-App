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
    private static func createRemindersBody(forDogId dogId: Int, forReminders reminders: [Reminder]) -> [String: [[String: Any?]]] {
        var remindersArray: [[String: Any?]] = []
        for reminder in reminders {
            remindersArray.append(reminder.createBody(forDogId: dogId))
        }
        let body: [String: [[String: Any?]]] = [KeyConstant.reminders.rawValue: remindersArray]
        return body
    }
    
}

extension RemindersRequest {
    
    // MARK: - Public Functions
    
    /**
     If query is successful, automatically combines client-side and server-side reminders and returns (reminder, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, forDogId: Int, forReminder: Reminder, completionHandler: @escaping (Reminder?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body: [String: Any?] = forReminder.createBody(forDogId: forDogId)
        
        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                let remindersBody: [[String: Any?]]? = {
                    if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [[String: Any?]] {
                        return remindersBody
                    }
                    else if let reminderBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any?] {
                        return [reminderBody]
                    }
                    else {
                        return nil
                    }
                }()
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then do nothing. This is because a get request will be made by the offline manager, so that anything updated while offline will be synced.
                }
                else if let reminderBody = remindersBody?.first {
                    // If we got a logBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Reminder(forReminderBody: reminderBody, overrideReminder: forReminder.copy() as? Reminder), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(forReminder, responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically client-side and server-side reminders and returns (reminders, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId: Int, forReminders: [Reminder], completionHandler: @escaping (ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = createRemindersBody(forDogId: forDogId, forReminders: forReminders)
        
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                let remindersBody: [[String: Any?]]? = {
                    if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [[String: Any?]] {
                        return remindersBody
                    }
                    else if let reminderBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any?] {
                        return [reminderBody]
                    }
                    else {
                        return nil
                    }
                }()
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the reminders to be updated later
                    forReminders.forEach { forReminder in
                        forReminder.offlineSyncComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                    }
                }
                else if let remindersBody = remindersBody {
                    remindersBody.forEach { reminderBody in
                        // For each reminderBody, get the reminderUUID and reminderId. We use the reminderUUID to locate the reminder so we can assign it its reminderId
                        guard let reminderId = reminderBody[KeyConstant.reminderId.rawValue] as? Int, let reminderUUID = UUID.fromString(forUUIDString: reminderBody[KeyConstant.reminderUUID.rawValue] as? String) else {
                            return
                        }
                        
                        let forReminder = forReminders.first { forReminder in
                            return forReminder.reminderUUID == reminderUUID
                        }
                        
                        forReminder?.reminderId = reminderId
                        
                    }
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically invokes clearTimers() for each reminder and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId: Int, forReminders: [Reminder], completionHandler: @escaping (ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = createRemindersBody(forDogId: forDogId, forReminders: forReminders)
        
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the reminders to be updated later
                    forReminders.forEach { forReminder in
                        forReminder.offlineSyncComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                    }
                }
                
                // Updated the reminders, clear the timers for all of them as timing might have changed
                forReminders.forEach { forReminder in
                    forReminder.clearTimers()
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically invokes clearTimers() for each reminder and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId: Int, forReminders: [Reminder], completionHandler: @escaping (ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = createRemindersBody(forDogId: forDogId, forReminders: forReminders)
        
        return RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the log to be updated later
                    // TODO add reminders to queue to be deleted
                }
                
                // Updated the reminders, clear the timers for all of them as timing might have changed
                forReminders.forEach { forReminder in
                    forReminder.clearTimers()
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
