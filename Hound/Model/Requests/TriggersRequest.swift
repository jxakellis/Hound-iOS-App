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
    private static func createBody(
        dogUUID: UUID,
        dogTriggers: [Trigger]
    ) -> JSONRequestBody {
        let triggerBodies = dogTriggers.map { $0.createBody(dogUUID: dogUUID) }
        
        let body: JSONRequestBody = [Constant.Key.dogTriggers.rawValue: .array(
            triggerBodies.map { .object($0.compactMapValues { $0 }) }
        )]
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
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        trigger: Trigger,
        completionHandler: @escaping (
            Trigger?,
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        let body: JSONRequestBody = trigger.createBody(dogUUID: dogUUID)
        
        return RequestUtils.genericGetRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body
        ) { responseBody, responseStatus, error in
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(nil, responseStatus, error)
                return
            }
            
            // Either completed successfully or no response from the server, we can proceed as usual
            let triggersBody: [JSONResponseBody]? = {
                if let array = responseBody?[Constant.Key.result.rawValue] as? [JSONResponseBody] {
                    return array
                }
                else if let single = responseBody?[Constant.Key.result.rawValue] as? JSONResponseBody {
                    return [single]
                }
                else {
                    return nil
                }
            }()
            
            if responseStatus == .noResponse {
                // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                OfflineModeManager.shared.didGetNoResponse(
                    type: .dogManagerGet
                )
            }
            else if let triggerBody = triggersBody?.first {
                // If we got a triggerBody, use it. This can only happen if responseStatus != .noResponse.
                let override = trigger.copy() as? Trigger
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
                trigger,
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
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        dogTriggers: [Trigger],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be triggers to actually create
        guard dogTriggers.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createBody(
            dogUUID: dogUUID,
            dogTriggers: dogTriggers
        )
        
        return RequestUtils.genericPostRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body
        ) { responseBody, responseStatus, error in
            // As long as we got a response from the server, it no longers needs synced. Success or failure
            if responseStatus != .noResponse {
                dogTriggers.forEach { trigger in
                    trigger.offlineModeComponents
                        .updateInitialAttemptedSyncDate(
                            initialAttemptedSyncDate: nil
                        )
                }
            }
            
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(responseStatus, error)
                return
            }
            
            // Either completed successfully or no response from the server, we can proceed as usual
            let triggersBody: [JSONResponseBody]? = {
                if let array = responseBody?[Constant.Key.result.rawValue] as? [JSONResponseBody] {
                    return array
                }
                else if let single = responseBody?[Constant.Key.result.rawValue] as? JSONResponseBody {
                    return [single]
                }
                else {
                    return nil
                }
            }()
            
            if responseStatus == .noResponse {
                // If we got no response, then mark the triggers to be updated later
                dogTriggers.forEach { trigger in
                    trigger.offlineModeComponents
                        .updateInitialAttemptedSyncDate(
                            initialAttemptedSyncDate: Date()
                        )
                }
            }
            else if let bodies = triggersBody {
                // For each body, get the UUID and id. We use the uuid to locate the reminder so we can assign it its id
                bodies.forEach { body in
                    guard let id = body[Constant.Key.triggerId.rawValue] as? Int,
                          let uuidString = body[Constant.Key.triggerUUID.rawValue] as? String,
                          let uuid = UUID.fromString(UUIDString: uuidString)
                    else {
                        return
                    }
                    
                    dogTriggers.first(where: { $0.triggerUUID == uuid })?.triggerId = id
                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func update(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        dogTriggers: [Trigger],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be reminders to actually update
        guard dogTriggers.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body = createBody(dogUUID: dogUUID, dogTriggers: dogTriggers)
        
        return RequestUtils.genericPutRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body
        ) { _, responseStatus, error in
            // As long as we got a response from the server, it no longers needs synced. Success or failure
            if responseStatus != .noResponse {
                dogTriggers.forEach { trigger in
                    trigger.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: nil)
                }
            }
            
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(responseStatus, error)
                return
            }
            
            if responseStatus == .noResponse {
                // If we got no response, then mark the reminders to be updated later
                dogTriggers.forEach { trigger in
                    trigger.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date())
                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
    
    @discardableResult static func delete(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        triggerUUIDs: [UUID],
        completionHandler: @escaping (
            ResponseStatus,
            HoundError?
        ) -> Void
    ) -> Progress? {
        // There should be reminders to actually delete
        guard triggerUUIDs.count >= 1 else {
            completionHandler(.successResponse, nil)
            return nil
        }
        
        let body: JSONRequestBody = {
            var triggerBodies: [JSONRequestBody] = []
            for UUID in triggerUUIDs {
                var entry: JSONRequestBody = [:]
                entry[Constant.Key.dogUUID.rawValue] = .string(dogUUID.uuidString)
                entry[Constant.Key.triggerUUID.rawValue] = .string(UUID.uuidString)
                triggerBodies.append(entry)
            }
            return [Constant.Key.dogTriggers.rawValue: .array(
                triggerBodies.map { .object($0.compactMapValues { $0 }) }
            )]
        }()
        
        return RequestUtils.genericDeleteRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body
        ) { _, responseStatus, error in
            guard responseStatus != .failureResponse else {
                // If there was a failureResponse, there was something purposefully wrong with the request
                completionHandler(responseStatus, error)
                return
            }
            
            // Either completed successfully or no response from the server, we can proceed as usual
            
            if responseStatus == .noResponse {
                triggerUUIDs.forEach { uuid in
                    OfflineModeManager.shared
                        .addDeletedObjectToQueue(object:
                                                    OfflineModeDeletedTrigger(
                                                        dogUUID: dogUUID,
                                                        triggerUUID: uuid,
                                                        deletedDate: Date()))
                }
            }
            
            completionHandler(responseStatus, error)
        }
    }
}
