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
    @discardableResult static func get(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Log?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        var body: [String: Any] = log.createBody(forDogId: dogId)
        
        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    if let logBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                        completionHandler(Log(forLogBody: logBody, overrideLog: log.copy() as? Log), responseStatus, error)
                    }
                    else {
                        completionHandler(nil, responseStatus, error)
                    }
                case .failureResponse:
                    completionHandler(nil, responseStatus, error)
                case .noResponse:
                    completionHandler(nil, responseStatus, error)
                }
            }
    }
    
    /**
     If query is successful, automatically assigns logId to log and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = log.createBody(forDogId: dogId)
        
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { responseBody, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    if let logId = responseBody?[KeyConstant.result.rawValue] as? Int {
                        log.logId = logId
                        completionHandler(true, responseStatus, error)
                    }
                    else {
                        completionHandler(false, responseStatus, error)
                    }
                case .failureResponse:
                    completionHandler(false, responseStatus, error)
                case .noResponse:
                    completionHandler(false, responseStatus, error)
                }
            }
        
    }
    
    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body = log.createBody(forDogId: dogId)
        
        // make put request, assume body valid as constructed with function
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    completionHandler(true, responseStatus, error)
                case .failureResponse:
                    completionHandler(false, responseStatus, error)
                case .noResponse:
                    completionHandler(false, responseStatus, error)
                }
            }
    }
    
    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        var body: [String: Any] = [:]
        body[KeyConstant.dogId.rawValue] = dogId
        body[KeyConstant.logId.rawValue] = logId
        
        return RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                switch responseStatus {
                case .successResponse:
                    completionHandler(true, responseStatus, error)
                case .failureResponse:
                    completionHandler(false, responseStatus, error)
                case .noResponse:
                    completionHandler(false, responseStatus, error)
                }
            }
    }
}
