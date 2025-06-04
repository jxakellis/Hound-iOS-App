//
//  TriggersRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum TriggersRequest {
    
    static var baseURL: URL { DogsRequest.baseURL.appendingPathComponent("/dogTriggers") }
    
    /// Returns an array of reminder trigger bodies under the key "dogTriggers".
    private static func createTriggersBody(
        forDogUUID: UUID,
        forDogTriggers: [Trigger]
    ) -> [String: [[String: CompatibleDataTypeForJSON?]]] {
        var triggerBodies: [[String: CompatibleDataTypeForJSON?]] = []
        for forTrigger in forDogTriggers {
            triggerBodies.append(
                forTrigger.createBody(forDogUUID: forDogUUID)
            )
        }
        let body: [String: [[String: CompatibleDataTypeForJSON?]]] = [
            KeyConstant.dogTriggers.rawValue: triggerBodies
        ]
        return body
    }
    
}

extension TriggersRequest {
    
    // MARK: - Public Functions
    
    /**
     If query is successful, combines client-side and server-side dogTriggers and returns (trigger, .successResponse).
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse).
     */
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forTrigger: Trigger,
        completionHandler: @escaping (
            Trigger?,
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        let body: [String: CompatibleDataTypeForJSON?] =
        forTrigger.createBody(forDogUUID: forDogUUID)
        
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
                let override = forTrigger.copy() as? Trigger
                completionHandler(
                    Trigger(
                        fromBody: triggerBody,
                        triggerToOverride: override
                    ),
                    responseStatus,
                    error
                )
                return
            }
            
            // Either no response or no new, updated information from the Hound server
            completionHandler(
                forTrigger,
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
        forDogTriggers: [Trigger],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be triggers to actually create
        guard forDogTriggers.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createTriggersBody(
            forDogUUID: forDogUUID,
            forDogTriggers: forDogTriggers
        )
        
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body
        ) { responseBody, responseStatus, error in
            // As long as we got a response from the server, it no longers needs synced. Success or failure
            if responseStatus != .noResponse {
                forDogTriggers.forEach { trigger in
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
                // If we got no response, then mark the triggers to be updated later
                forDogTriggers.forEach { trigger in
                    trigger.offlineModeComponents
                        .updateInitialAttemptedSyncDate(
                            forInitialAttemptedSyncDate: Date()
                        )
                }
            }
            else if let bodies = triggersBody {
                // For each body, get the UUID and id. We use the uuid to locate the reminder so we can assign it its id
                bodies.forEach { body in
                    guard let id = body[KeyConstant.triggerId.rawValue] as? Int,
                          let uuidString = body[KeyConstant.triggerUUID.rawValue] as? String,
                          let uuid = UUID.fromString(forUUIDString: uuidString)
                    else {
                        return
                    }
                    
                    forDogTriggers.first(where: { $0.triggerUUID == uuid })?.triggerId = id
                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func update(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forDogTriggers: [Trigger],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be reminders to actually update
        guard forDogTriggers.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createTriggersBody(forDogUUID: forDogUUID, forDogTriggers: forDogTriggers)
        
        return RequestUtils.genericPutRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body
        ) { _, responseStatus, error in
            // As long as we got a response from the server, it no longers needs synced. Success or failure
            if responseStatus != .noResponse {
                forDogTriggers.forEach { trigger in
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
                forDogTriggers.forEach { trigger in
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
        forTriggerUUIDs: [UUID],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be reminders to actually delete
        guard forTriggerUUIDs.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body: [String: [[String: CompatibleDataTypeForJSON?]]] = {
            var triggerBodies: [[String: CompatibleDataTypeForJSON?]] = []
            for forUUID in forTriggerUUIDs {
                var entry: [String: CompatibleDataTypeForJSON?] = [:]
                entry[KeyConstant.dogUUID.rawValue] = forDogUUID.uuidString
                entry[KeyConstant.triggerUUID.rawValue] = forUUID.uuidString
                triggerBodies.append(entry)
            }
            return [KeyConstant.dogTriggers.rawValue: triggerBodies]
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
                forTriggerUUIDs.forEach { uuid in
                    OfflineModeManager.shared
                        .addDeletedObjectToQueue(forObject:
                                                    OfflineModeDeletedTrigger(
                                                        dogUUID: forDogUUID,
                                                        triggerUUID: uuid,
                                                        deletedDate: Date()))
                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
}
