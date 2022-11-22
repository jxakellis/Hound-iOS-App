//
//  LogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsRequest {
    
    /// Need dogId for any request so we can't append '/logs' until we have dogId
    static var baseURLWithoutParams: URL { return DogsRequest.baseURLWithoutParams}
    
    // MARK: - Private Functions
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalGet(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int?, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        let URLWithParams: URL
        
        // looking for single log
        if let logId = logId {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId)")
        }
        // don't necessarily need a logId, no logId specifys that you want all logs for a dog
        else {
            URLWithParams = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs")
        }
        
        // make get request
        return InternalRequestUtils.genericGetRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
    
    /**
     completionHandler returns response data: logId for the created log and the ResponseStatus
     */
    private static func internalCreate(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        let body = log.createBody()
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/")
        
        // make post request, assume body valid as constructed with method
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalUpdate(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        let body = log.createBody()
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(log.logId)")
        
        // make put request, assume body valid as constructed with method
        return InternalRequestUtils.genericPutRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams, forBody: body) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
    }
    
    /**
     completionHandler returns response data: dictionary of the body and the ResponseStatus
     */
    private static func internalDelete(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        let URLWithParams: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId)")
        
        // make delete request
        return InternalRequestUtils.genericDeleteRequest(invokeErrorManager: invokeErrorManager, forURL: URLWithParams) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
        
    }
    
}

extension LogsRequest {
    
    // MARK: - Public Functions
    
    /**
     completionHandler returns a log and response status. If the query is successful and the log isn't deleted, then the log is returned. Otherwise, nil is returned.
     */
    @discardableResult static func get(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Log?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return LogsRequest.internalGet(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLogId: log.logId) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                if let logBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    completionHandler(Log(forLogBody: logBody, overrideLog: log.copy() as? Log), responseStatus, responseError)
                }
                else {
                    completionHandler(nil, responseStatus, responseError)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus, responseError)
            case .noResponse:
                completionHandler(nil, responseStatus, responseError)
            }
        }
    }
    
    /**
     completionHandler returns a possible logId and the ResponseStatus.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Int?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return LogsRequest.internalCreate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLog: log) { responseBody, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                if let logId = responseBody?[KeyConstant.result.rawValue] as? Int {
                    completionHandler(logId, responseStatus, responseError)
                }
                else {
                    completionHandler(nil, responseStatus, responseError)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus, responseError)
            case .noResponse:
                completionHandler(nil, responseStatus, responseError)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        
        return LogsRequest.internalUpdate(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLog: log) { _, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus, responseError)
            case .failureResponse:
                completionHandler(false, responseStatus, responseError)
            case .noResponse:
                completionHandler(false, responseStatus, responseError)
            }
        }
    }
    
    /**
     completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful.
     If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
     */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return LogsRequest.internalDelete(invokeErrorManager: invokeErrorManager, forDogId: dogId, forLogId: logId) { _, responseStatus, responseError in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus, responseError)
            case .failureResponse:
                completionHandler(false, responseStatus, responseError)
            case .noResponse:
                completionHandler(false, responseStatus, responseError)
            }
        }
    }
}
