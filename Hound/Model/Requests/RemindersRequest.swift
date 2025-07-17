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
    private static func createBody(forDogUUID: UUID, forReminders: [Reminder]) -> JSONRequestBody {
        let reminderBodies = forReminders.map { $0.createBody(forDogUUID: forDogUUID) }
        
        let body: JSONRequestBody = [KeyConstant.dogReminders.rawValue: .array(
            reminderBodies.map { .object($0.compactMapValues { $0 }) }
        )]
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
        let body: JSONRequestBody = forReminder.createBody(forDogUUID: forDogUUID)
        
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
                let remindersBody: [JSONResponseBody]? = {
                    if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [JSONResponseBody] {
                        return remindersBody
                    }
                    else if let reminderBody = responseBody?[KeyConstant.result.rawValue] as? JSONResponseBody {
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
                    // If we got a reminderBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Reminder(fromBody: reminderBody, reminderToOverride: forReminder.copy() as? Reminder), responseStatus, error)
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
        // There should be reminders to actually create
        guard forReminders.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createBody(forDogUUID: forDogUUID, forReminders: forReminders)
        
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    forReminders.forEach { forReminder in
                        forReminder.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
                    }
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                let remindersBody: [JSONResponseBody]? = {
                    if let remindersBody = responseBody?[KeyConstant.result.rawValue] as? [JSONResponseBody] {
                        return remindersBody
                    }
                    else if let reminderBody = responseBody?[KeyConstant.result.rawValue] as? JSONResponseBody {
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
                        
                        forReminder?.reminderId = reminderId
                    }
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func update(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminders: [Reminder],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        // There should be reminders to actually update
        guard forReminders.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createBody(forDogUUID: forDogUUID, forReminders: forReminders)
        
        return RequestUtils.genericPutRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    forReminders.forEach { forReminder in
                        forReminder.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
                    }
                }
                
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
                
                completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func delete(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminderUUIDs: [UUID],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        // There should be reminders to actually delete
        guard forReminderUUIDs.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body: JSONRequestBody = {
            var reminderBodies: [JSONRequestBody] = []
            
            for forReminderUUID in forReminderUUIDs {
                var reminderBody: JSONRequestBody = [:]
                reminderBody[KeyConstant.dogUUID.rawValue] = .string(forDogUUID.uuidString)
                reminderBody[KeyConstant.reminderUUID.rawValue] = .string(forReminderUUID.uuidString)
                reminderBodies.append(reminderBody)
            }
        
            return [KeyConstant.dogReminders.rawValue: .array(reminderBodies.map { .object($0.compactMapValues { $0 }) } )]
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
