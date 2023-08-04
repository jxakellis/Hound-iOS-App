//
//  LogsRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/1/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum LogsRequest {

    /// Need dogId for any request so we can't append '/logs' until we have dogId
    static var baseURLWithoutParams: URL { DogsRequest.baseURLWithoutParams }

    /**
     If query is successful, automatically combines client-side and server-side logs and returns (log, .successResponse)
     If query isn't successful, returns (nil, .failureResponse) or (nil, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Log?, ResponseStatus) -> Void) -> Progress? {
        let url = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(log.logId)")

        return RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let logBody = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    completionHandler(Log(forLogBody: logBody, overrideLog: log.copy() as? Log), responseStatus)
                }
                else {
                    completionHandler(nil, responseStatus)
                }
            case .failureResponse:
                completionHandler(nil, responseStatus)
            case .noResponse:
                completionHandler(nil, responseStatus)
            }
        }
    }

    /**
     If query is successful, automatically assigns logId to log and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func create(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        let url = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/")
        let body = log.createBody()

        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url,
            forBody: body) { responseBody, responseStatus in
            switch responseStatus {
            case .successResponse:
                if let logId = responseBody?[KeyConstant.result.rawValue] as? Int {
                    log.logId = logId
                    completionHandler(true, responseStatus)
                }
                else {
                    completionHandler(false, responseStatus)
                }
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }

    }

    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(invokeErrorManager: Bool, forDogId dogId: Int, forLog log: Log, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        let url: URL = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(log.logId)")
        let body = log.createBody()

        // make put request, assume body valid as constructed with function
        return RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url,
            forBody: body) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }

    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, forDogId dogId: Int, forLogId logId: Int, completionHandler: @escaping (Bool, ResponseStatus) -> Void) -> Progress? {
        let url = baseURLWithoutParams.appendingPathComponent("/\(dogId)/logs/\(logId)")

        return RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: url) { _, responseStatus in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus)
            case .failureResponse:
                completionHandler(false, responseStatus)
            case .noResponse:
                completionHandler(false, responseStatus)
            }
        }
    }
}
