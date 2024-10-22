//
//  AlertRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/18/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum AlertRequest {
    static var baseURL: URL { UserRequest.baseURL.appendingPathComponent("/alert")}

    /**
     Invoke function when user is terminating Hound. Sends query to Hound server that sends APN to user, warning against terminating the app
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: [:]) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                completionHandler(responseStatus, error)
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }
}
