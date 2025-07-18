//
//  LogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsRequest {
    
    static var baseURL: URL { DogsRequest.baseURL.appendingPathComponent("/logs") }
    
    /**
     If query is successful, automatically combines client-side and server-side logs and returns (log, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forLog: Log,
        completionHandler: @escaping (Log?, ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: JSONRequestBody = forLog.createBody(forDogUUID: forDogUUID)
        
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
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(forType: .dogManagerGet)
                }
                else if let logBody = responseBody?[KeyConstant.result.rawValue] as? JSONResponseBody {
                    // If we got a logBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Log(fromBody: logBody, logToOverride: forLog.copy() as? Log), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(forLog, responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically assigns logId to log and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forLog: Log,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = forLog.createBody(forDogUUID: forDogUUID)
        
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    forLog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the log to be updated later
                    forLog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                }
                else if let logId = responseBody?[KeyConstant.result.rawValue] as? Int {
                    // If we got a logId, use it. This can only happen if responseStatus != .noResponse.
                    forLog.logId = logId
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forLog: Log,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = forLog.createBody(forDogUUID: forDogUUID)
        
        // make put request, assume body valid as constructed with function
        return RequestUtils.genericPutRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    forLog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: nil)
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the log to be updated later
                    forLog.offlineModeComponents.updateInitialAttemptedSyncDate(forInitialAttemptedSyncDate: Date())
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forDogUUID: UUID,
        forLogUUID: UUID,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        var body: JSONRequestBody = [:]
        body[KeyConstant.dogUUID.rawValue] = .string(forDogUUID.uuidString)
        body[KeyConstant.logUUID.rawValue] = .string(forLogUUID.uuidString)
        
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
                    // If we got no response, then mark the log to be deleted later
                    OfflineModeManager.shared.addDeletedObjectToQueue(forObject: OfflineModeDeletedLog(dogUUID: forDogUUID, logUUID: forLogUUID, deletedDate: Date()))
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
