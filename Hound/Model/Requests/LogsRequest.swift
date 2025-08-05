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
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        log: Log,
        completionHandler: @escaping (Log?, ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: JSONRequestBody = log.createBody(dogUUID: dogUUID)
        
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
                
                if responseStatus == .noResponse {
                    // If we got no response from a get request, then communicate to OfflineModeManager so it will sync the dogManager from the server when it begins to sync
                    OfflineModeManager.shared.didGetNoResponse(type: .dogManagerGet)
                }
                else if let logBody = responseBody?[Constant.Key.result.rawValue] as? JSONResponseBody {
                    // If we got a logBody, use it. This can only happen if responseStatus != .noResponse.
                    completionHandler(Log(fromBody: logBody, logToOverride: log.copy() as? Log), responseStatus, error)
                    return
                }
                
                // Either no response or no new, updated information from the Hound server
                completionHandler(log, responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically assigns logId to log and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        log: Log,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = log.createBody(dogUUID: dogUUID)
        
        return RequestUtils.genericPostRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { responseBody, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    log.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: nil)
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                // Either completed successfully or no response from the server, we can proceed as usual
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the log to be updated later
                    log.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date())
                }
                else if let logId = responseBody?[Constant.Key.result.rawValue] as? Int {
                    // If we got a logId, use it. This can only happen if responseStatus != .noResponse.
                    log.logId = logId
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        log: Log,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body = log.createBody(dogUUID: dogUUID)
        
        // make put request, assume body valid as constructed with function
        return RequestUtils.genericPutRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { _, responseStatus, error in
                // As long as we got a response from the server, it no longers needs synced. Success or failure
                if responseStatus != .noResponse {
                    log.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: nil)
                }
                
                guard responseStatus != .failureResponse else {
                    // If there was a failureResponse, there was something purposefully wrong with the request
                    completionHandler(responseStatus, error)
                    return
                }
                
                if responseStatus == .noResponse {
                    // If we got no response, then mark the log to be updated later
                    log.offlineModeComponents.updateInitialAttemptedSyncDate(initialAttemptedSyncDate: Date())
                }
                
                completionHandler(responseStatus, error)
        }
    }
    
    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        dogUUID: UUID,
        logUUID: UUID,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        var body: JSONRequestBody = [:]
        body[Constant.Key.dogUUID.rawValue] = .string(dogUUID.uuidString)
        body[Constant.Key.logUUID.rawValue] = .string(logUUID.uuidString)
        
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
                    // If we got no response, then mark the log to be deleted later
                    OfflineModeManager.shared.addDeletedObjectToQueue(object: OfflineModeDeletedLog(dogUUID: dogUUID, logUUID: logUUID, deletedDate: Date()))
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
