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

    static var baseURL: URL { RequestUtils.baseURL.appendingPathComponent("/user")}
    /**
     If query is successful, automatically sets up UserInformation and UserConfiguration and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
     */
    @discardableResult static func get(invokeErrorManager: Bool, completionHandler: @escaping (Bool, String?, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericGetRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: [:]) { responseBody, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                // attempt to extract body and userId
                if let result = responseBody?[KeyConstant.result.rawValue] as? [String: PrimativeTypeProtocol?] {
                    let familyId = result[KeyConstant.familyId.rawValue] as? String
                    UserInformation.setup(fromBody: result)
                    UserConfiguration.setup(fromBody: result)

                    completionHandler(UserInformation.userId != nil, familyId, .successResponse, error)
                }
                else {
                    completionHandler(false, nil, .failureResponse, error)
                }
            case .failureResponse:
                completionHandler(false, nil, .failureResponse, error)
            case .noResponse:
                completionHandler(false, nil, .noResponse, error)
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
            forURL: baseURL,
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
    @discardableResult static func update(invokeErrorManager: Bool, forBody: [String: PrimativeTypeProtocol?], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericPutRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: forBody) { _, responseStatus, error in
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
    @discardableResult static func delete(invokeErrorManager: Bool, forBody: [String: PrimativeTypeProtocol?] = [:], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        RequestUtils.genericDeleteRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: forBody) { _, responseStatus, error in
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
