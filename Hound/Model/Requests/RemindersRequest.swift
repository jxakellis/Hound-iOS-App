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
    private static func createBody(dogUUID: UUID, reminders: [Reminder]) -> JSONRequestBody {
        let reminderBodies = reminders.map { $0.createBody(dogUUID: dogUUID) }
        
        let body: JSONRequestBody = [Constant.Key.dogReminders.rawValue: .array(
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
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        reminder: Reminder,
        completionHandler: @escaping (Reminder?, ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: JSONRequestBody = reminder.createBody(dogUUID: dogUUID)
        
        return RequestUtils.genericGetRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(nil, responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                let remindersBody: [JSONResponseBody]? = {
                    if let remindersBody = responseBody?[Constant.Key.result.rawValue] as? [JSONResponseBody] {
                        return remindersBody
                    }
                    else if let reminderBody = responseBody?[Constant.Key.result.rawValue] as? JSONResponseBody {
                        return [reminderBody]
                    }
                    else {
                        return nil
                    }
                }()
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(type: .dogManagerGet)
                }
                else if let reminderBody = remindersBody?.first {
                    // If we got a reminderBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Reminder(fromBody: reminderBody, reminderToOverride: reminder.copy() as? Reminder), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(reminder, responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically client-side and server-side reminders and returns (reminders, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func create(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        reminders: [Reminder],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        // There should be reminders to actually create
        guard reminders.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createBody(dogUUID: dogUUID, reminders: reminders)
        
        return RequestUtils.genericPostRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { responseBody, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    reminders.forEach { reminder in
                        reminder.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: nil)
                    }
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                let remindersBody: [JSONResponseBody]? = {
                    if let remindersBody = responseBody?[Constant.Key.result.rawValue] as? [JSONResponseBody] {
                        return remindersBody
                    }
                    else if let reminderBody = responseBody?[Constant.Key.result.rawValue] as? JSONResponseBody {
                        return [reminderBody]
                    }
                    else {
                        return nil
                    }
                }()
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the reminders to be updated later
                    reminders.forEach { reminder in
                        reminder.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date())
                    }
                }
                else if let remindersBody = remindersBody {
                    remindersBody.forEach { reminderBody in
                        // For each reminderBody, get the reminderUUID and reminderId. We use the reminderUUID to locate the reminder so we can assign it its reminderId
                        guard let reminderId = reminderBody[Constant.Key.reminderId.rawValue] as? Int, let reminderUUID = UUID.fromString(UUIDString: reminderBody[Constant.Key.reminderUUID.rawValue] as? String) else {
                            return
                        }
                        
                        let reminder = reminders.first { reminder in
                            return reminder.reminderUUID == reminderUUID
                        }
                        
                        reminder?.reminderId = reminderId
                    }
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func update(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        reminders: [Reminder],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        // There should be reminders to actually update
        guard reminders.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createBody(dogUUID: dogUUID, reminders: reminders)
        
        return RequestUtils.genericPutRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { _, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    reminders.forEach { reminder in
                        reminder.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: nil)
                    }
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the reminders to be updated later
                    reminders.forEach { reminder in
                        reminder.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date())
                    }
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func delete(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        reminderUUIDs: [UUID],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        // There should be reminders to actually delete
        guard reminderUUIDs.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body: JSONRequestBody = {
            var reminderBodies: [JSONRequestBody] = []
            
            for reminderUUID in reminderUUIDs {
                var reminderBody: JSONRequestBody = [:]
                reminderBody[Constant.Key.dogUUID.rawValue] = .string(dogUUID.uuidString)
                reminderBody[Constant.Key.reminderUUID.rawValue] = .string(reminderUUID.uuidString)
                reminderBodies.append(reminderBody)
            }
        
            return [Constant.Key.dogReminders.rawValue: .array(reminderBodies.map { .object($0.compactMapValues { $0 }) })]
        }()
        
        return RequestUtils.genericDeleteRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the reminder to be deleted later
                    reminderUUIDs.forEach { reminderUUID in
                        OfflineModeManager.shared.addDeletedObjectToQueue(object: OfflineModeDeletedReminder(dogUUID: dogUUID, reminderUUID: reminderUUID, deletedDate: Date()))
                    }
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
