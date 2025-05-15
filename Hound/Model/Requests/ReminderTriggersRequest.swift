//
//  ReminderTriggersRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ReminderTriggersRequest {
    
    static var baseURL: URL { DogsRequest.baseURL.appendingPathComponent("/reminderTriggers") }
    
    /// Returns an array of reminder trigger bodies under the key "reminderTriggers".
    private static func createReminderTriggersBody(
        forDogUUID: UUID,
        forReminderTriggers: [ReminderTrigger]
    ) -> [String: [[String: CompatibleDataTypeForJSON?]]] {
        var triggerBodies: [[String: CompatibleDataTypeForJSON?]] = []
        for forTrigger in forReminderTriggers {
            triggerBodies.append(
                forTrigger.createBody(forDogUUID: forDogUUID)
            )
        }
        let body: [String: [[String: CompatibleDataTypeForJSON?]]] = [
            KeyConstant.reminderTriggers.rawValue: triggerBodies
        ]
        return body
    }
    
}

extension ReminderTriggersRequest {
    
    // MARK: - Public Functions
    
    /**
     If query is successful, combines client-side and server-side triggers and returns (trigger, .successResponse).
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse).
     */
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminderTrigger: ReminderTrigger,
        completionHandler: @escaping (
            ReminderTrigger?,
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        let body: [String: CompatibleDataTypeForJSON?] =
        forReminderTrigger.createBody(forDogUUID: forDogUUID)
        
        return RequestUtils.genericGetRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body
        ) { responseBody, responseStatus, error in
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(nil, responseStatus, error)
                return
            }
            
            // Either completed successfully or no response from the server, we can proceed as usual
            let triggersBody: [[String: Any?]]? = {
                if let array = responseBody?[KeyConstant.result.rawValue] as? [[String: Any?]] {
                    return array
                }
                else if let single = responseBody?[KeyConstant.result.rawValue] as? [String: Any?] {
                    return [single]
                }
                else {
                    return nil
                }
            }()
            
            if responseStatus == .noResponse {
                // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                OfflineModeManager.shared.didGetNoResponse(
                    forType: .dogManagerGet
                )
            }
            else if let triggerBody = triggersBody?.first {
                // If we got a triggerBody, use it. This can only happen if responseStatus != .noResponse.
                let override = forReminderTrigger.copy() as? ReminderTrigger
                completionHandler(
                    ReminderTrigger(
                        fromReminderTriggerBody: triggerBody,
                        reminderTriggerToOverride: override
                    ),
                    responseStatus,
                    error
                )
                return
            }
            
            // Either no response or no new, updated information from the Hound server
            completionHandler(
                forReminderTrigger,
                responseStatus,
                error
            )
        }
    }
    
    /**
     If query is successful, creates triggers and returns (.successResponse).
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse).
     */
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminderTriggers: [ReminderTrigger],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be reminder triggers to actually create
        guard forReminderTriggers.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createReminderTriggersBody(
            forDogUUID: forDogUUID,
            forReminderTriggers: forReminderTriggers
        )
        
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body
        ) { responseBody, responseStatus, error in
            // As long as we got a response from the server, it no longers needs synced. Success or failure
            if responseStatus != .noResponse {
                forReminderTriggers.forEach { trigger in
                    trigger.offlineModeComponents
                        .updateInitialAttemptedSyncDate(
                            forInitialAttemptedSyncDate: nil
                        )
                }
            }
            
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(responseStatus, error)
                return
            }
            
            // Either completed successfully or no response from the server, we can proceed as usual
            let triggersBody: [[String: Any?]]? = {
                if let array = responseBody?[KeyConstant.result.rawValue] as? [[String: Any?]] {
                    return array
                }
                else if let single = responseBody?[KeyConstant.result.rawValue] as? [String: Any?] {
                    return [single]
                }
                else {
                    return nil
                }
            }()
            
            if responseStatus == .noResponse {
                // If we got no response, then mark the reminder triggers to be updated later
                forReminderTriggers.forEach { trigger in
                    trigger.offlineModeComponents
                        .updateInitialAttemptedSyncDate(
                            forInitialAttemptedSyncDate: Date()
                        )
                }
            }
            else if let bodies = triggersBody {
                // For each body, get the UUID and id. We use the uuid to locate the reminder so we can assign it its id
                bodies.forEach { body in
                    guard let id = body[KeyConstant.reminderTriggerId.rawValue] as? Int,
                          let uuidString = body[KeyConstant.reminderTriggerUUID.rawValue] as? String,
                          let uuid = UUID.fromString(forUUIDString: uuidString)
                    else {
                        return
                    }
                    
                    forReminderTriggers.first(where: { $0.reminderTriggerUUID == uuid })?.reminderTriggerId = id
                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func update(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminderTriggers: [ReminderTrigger],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be reminders to actually update
        guard forReminderTriggers.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createReminderTriggersBody(forDogUUID: forDogUUID, forReminderTriggers: forReminderTriggers)
        
        return RequestUtils.genericPutRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body
        ) { _, responseStatus, error in
            // As long as we got a response from the server, it no longers needs synced. Success or failure
            if responseStatus != .noResponse {
                forReminderTriggers.forEach { trigger in
                    trigger.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
                }
            }
            
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(responseStatus, error)
                return
            }
            
            if responseStatus == .noResponse {
                // If we got no response, then mark the reminders to be updated later
                forReminderTriggers.forEach { trigger in
                    trigger.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func delete(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forReminderTriggerUUIDs: [UUID],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be reminders to actually delete
        guard forReminderTriggerUUIDs.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body: [String: [[String: CompatibleDataTypeForJSON?]]] = {
            var triggerBodies: [[String: CompatibleDataTypeForJSON?]] = []
            for forUUID in forReminderTriggerUUIDs {
                var entry: [String: CompatibleDataTypeForJSON?] = [:]
                entry[KeyConstant.dogUUID.rawValue] = forDogUUID.uuidString
                entry[KeyConstant.reminderTriggerUUID.rawValue] = forUUID.uuidString
                triggerBodies.append(entry)
            }
            return [KeyConstant.reminderTriggers.rawValue: triggerBodies]
        }()
        
        return RequestUtils.genericDeleteRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body
        ) { _, responseStatus, error in
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(responseStatus, error)
                return
            }
            
            // Either completed successfully or no response from the server, we can proceed as usual
            
            if responseStatus == .noResponse {
                // If we got no response, then mark the reminder to be deleted later
                // TODO RT make offline manager support this
                //                forReminderTriggerUUIDs.forEach { uuid in
                //                    OfflineModeManager.shared
                //                        .addDeletedObjectToQueue(
                //                            forObject: OfflineModeDeletedReminderTrigger(
                //                                dogUUID: forDogUUID,
                //                                reminderTriggerUUID: uuid,
                //                                deletedDate: Date()
                //                            )
                //                        )
                //                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
}
