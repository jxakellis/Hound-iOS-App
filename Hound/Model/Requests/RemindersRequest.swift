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
    private static func createRemindersBody(forDogUUID: UUID, forReminders: [Reminder]) -> [String: [[String: CompatibleDataTypeForJSON?]]] {
        var reminderBodies: [[String: CompatibleDataTypeForJSON?]] = []
        for forReminder in forReminders {
            reminderBodies.append(forReminder.createBody(forDogUUID: forDogUUID))
        }
        let body: [String: [[String: CompatibleDataTypeForJSON?]]] = [KeyConstant.reminders.rawValue: reminderBodies]
        return body
    }
    
}

extension RemindersRequest {
    
    // MARK: - Public Functions
    
    /**
     If query is successful, automatically combines client-side and server-side reminders and returns (reminder, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminder: Reminder,
        completionHandler: @escaping (Reminder?, ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: [String: CompatibleDataTypeForJSON?] = forReminder.createBody(forDogUUID: forDogUUID)
        
        return RequestUtils.genericGetRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
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
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(forType: .dogManagerGet)
                }
                else if let reminderBody = remindersBody?.first {
                    // If we got a logBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Reminder(fromReminderBody: reminderBody, reminderToOverride: forReminder.copy() as? Reminder), responseStatus, error)
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
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminders: [Reminder],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = createRemindersBody(forDogUUID: forDogUUID, forReminders: forReminders)
        
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
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
                        forReminder.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
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
                        
                        // Successfully synced the object with the server, so no need for the offline mode indicator anymore
                        forReminder?.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
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
    @discardableResult static func update(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminders: [Reminder],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = createRemindersBody(forDogUUID: forDogUUID, forReminders: forReminders)
        
        return RequestUtils.genericPutRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
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
                        forReminder.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                    }
                }
                else {
                    forReminders.forEach { forReminder in
                        // Successfully synced the object with the server, so no need for the offline mode indicator anymore
                        forReminder.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
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
    @discardableResult static func delete(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminderUUIDs: [UUID],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        
        let body: [String: [[String: CompatibleDataTypeForJSON?]]] = {
            var reminderBodies: [[String: CompatibleDataTypeForJSON?]] = []
            
            for forReminderUUID in forReminderUUIDs {
                var reminderBody: [String: CompatibleDataTypeForJSON?] = [:]
                reminderBody[KeyConstant.dogUUID.rawValue] = forDogUUID.uuidString
                reminderBody[KeyConstant.reminderUUID.rawValue] = forReminderUUID.uuidString
                reminderBodies.append(reminderBody)
            }
        
            return [
                KeyConstant.reminders.rawValue: reminderBodies
            ]
        }()
        
        return RequestUtils.genericDeleteRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the reminder to be deleted later
                    forReminderUUIDs.forEach { forReminderUUID in
                        OfflineModeManager.shared.addDeletedObjectToQueue(forObject: OfflineModeDeletedReminder(dogUUID: forDogUUID, reminderUUID: forReminderUUID, deletedDate: Date()))
                    }
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
