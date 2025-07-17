//
//  TypesRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/1/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum GlobalTypesRequest {

    static var baseURL: URL { RequestUtils.baseURL.appendingPathComponent("/globalTypes")}
    /**
     If query is successful, automatically sets up UserInformation and UserConfiguration and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func get(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        RequestUtils.genericGetRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: [:]) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    completionHandler(responseStatus, error)
                    return
                }
                
                if let result = responseBody?[KeyConstant.result.rawValue] as? JSONResponseBody {
                    GlobalTypes.shared = GlobalTypes(fromBody: result)
                }
                
                guard GlobalTypes.shared != nil else {
                    completionHandler(.failureResponse, error)
                    return
                }
                
                completionHandler(responseStatus, error)
        }
    }
}
