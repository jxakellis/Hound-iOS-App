//
//  AlertRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/18/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum AlertRequest {
    
    static var baseURLWithoutParams: URL { return UserRequest.baseURLWithUserId.appendingPathComponent("/alert")}
    
    // MARK: - Private Functions
    
    /**
    completionHandler returns a response data: dictionary of the body and the ResponseStatus
    */
    private static func internalCreate(completionHandler: @escaping ([String: Any]?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return InternalRequestUtils.genericPostRequest(invokeErrorManager: false, forURL: baseURLWithoutParams.appendingPathComponent("/terminate"), forBody: [:]) { responseBody, responseStatus, responseError in
            completionHandler(responseBody, responseStatus, responseError)
        }
    }
}

extension AlertRequest {
    
    // MARK: - Public Functions
    
    /**
    Invoke function when the user is terminating the app. Sends a query to the server to send an APN to the user, warning against terminating the app
    completionHandler returns a Bool and the ResponseStatus, indicating whether or not the request was successful
    If invokeErrorManager is true, then will send an error to ErrorManager that alerts the user.
    */
    @discardableResult static func create(completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return AlertRequest.internalCreate { _, responseStatus, responseError in
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
