//
//  UserRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum UserRequest {

    static var baseURL: URL { RequestUtils.baseURL.appendingPathComponent("/user")}
    /**
     If query is successful, automatically sets up UserInformation and UserConfiguration and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func get(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        RequestUtils.genericGetRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: [:]) { responseBody, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    completionHandler(responseStatus, error)
                    return
                }
                
                if responseStatus == .noResponse {
                    OfflineModeManager.shared.didGetNoResponse(type: .userRequestGet)
                }
                else if let result = responseBody?[Constant.Key.result.rawValue] as? JSONResponseBody {
                    UserInformation.setup(fromBody: result)
                    UserConfiguration.setup(fromBody: result)
                }
                
                completionHandler(responseStatus, error)
        }
    }

    /**
     Creates a user's account on the server
     If query is successful, automatically sets up UserInformation.userId and returns (true, .successResponse, requestId, responseId)
     If query isn't successful, returns (false, .failureResponse, requestId, responseId) or (false, .noResponse, requestId, responseId)
     */
    @discardableResult static func create(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        RequestUtils.genericPostRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: UserConfiguration.createBody(addingOntoBody: UserInformation.createBody(addingOntoBody: nil))) { responseBody, responseStatus, error in

            switch responseStatus {
            case .successResponse:
                if let userId = responseBody?[Constant.Key.result.rawValue] as? String {
                    UserInformation.userId = userId
                    completionHandler(.successResponse, error)
                }
                else {
                    completionHandler(.failureResponse, error)
                }
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }

    /**
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func update(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        body: JSONRequestBody,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        RequestUtils.genericPutRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { _, responseStatus, error in
                guard responseStatus != .failureResponse else {
                    completionHandler(responseStatus, error)
                    return
                }
                
                if responseStatus == .noResponse {
                    OfflineModeManager.shared.didGetNoResponse(type: .userRequestUpdate)
                }
                
                completionHandler(responseStatus, error)
        }
    }

    /**
     If query is successful, automatically invokes PersistenceManager.clearStorageToReloginToAccount() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        body: JSONRequestBody = [:],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        RequestUtils.genericDeleteRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            uRL: baseURL,
            body: body) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                PersistenceManager.clearStorageToReloginToAccount()
                completionHandler(responseStatus, error)
            case .failureResponse:
                completionHandler(responseStatus, error)
            case .noResponse:
                completionHandler(responseStatus, error)
            }
        }
    }
}
