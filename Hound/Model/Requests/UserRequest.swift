//
//  UserRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/28/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation
import KeychainSwift

/// Static word needed to conform to protocol. Enum preferred to a class as you can't instance an enum that is all static
enum UserRequest {

    static var baseURLWithoutParams: URL { RequestUtils.baseURLWithoutParams.appendingPathComponent("/user")}
    // UserRequest baseURL with the userId URL param appended on
    static var baseURLWithUserId: URL { UserRequest.baseURLWithoutParams.appendingPathComponent("/\(UserInformation.userId ?? VisualConstant.TextConstant.unknownHash)") }

    /**
     If query is successful, automatically sets up UserInformation and UserConfiguration and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithoutParams) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                // attempt to extract body and userId
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: Any] {
                    UserInformation.setup(fromBody: result)
                    UserConfiguration.setup(fromBody: result)

                    completionHandler(UserInformation.userId != nil, .successResponse, error)
                }
                else {
                    completionHandler(false, .failureResponse, error)
                }
            case .failureResponse:
                completionHandler(false, .failureResponse, error)
            case .noResponse:
                completionHandler(false, .noResponse, error)
            }
        }
    }

    /**
     Creates a user's account on the server
     If query is successful, automatically sets up UserInformation.userId and returns (true, .successResponse, requestId, responseId)
     If query isn't successful, returns (false, .failureResponse, requestId, responseId) or (false, .noResponse, requestId, responseId)
     */
    @discardableResult static func create(invokeErrorManager: Bool, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithoutParams,
            forBody: UserConfiguration.createBody(addingOntoBody: UserInformation.createBody(addingOntoBody: nil))) { responseBody, responseStatus, error in

            switch responseStatus {
            case .successResponse:
                if let userId = responseBody?[KeyConstant.result.rawValue] as? String {
                    UserInformation.userId = userId
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
    @discardableResult static func update(invokeErrorManager: Bool, body: [String: Any], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithUserId,
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
     If query is successful, automatically invokes PersistenceManager.clearStorageToReloginToAccount() and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func delete(invokeErrorManager: Bool, body: [String: Any] = [:], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURLWithUserId,
            forBody: body) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                PersistenceManager.clearStorageToReloginToAccount()
                completionHandler(true, responseStatus, error)
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }
}
